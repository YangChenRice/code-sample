library(tidyverse)
grp <- read.table("in_research_group.txt", header = T)
Kallisto <- read.table("TCGA.Kallisto.fullIDs.cibersort.relative.txt", 
    header = T)

Comp <- left_join(grp, Kallisto, by = c(Sample_ID = "Short_ID"))
Comp <- na.omit(Comp)

Brief <- Comp %>% group_by(Sample_ID) %>% summarize(d1_group = mean(d1_group), 
    d2_group = mean(d2_group), Cohort = first(Cohort), 
    B.cells.naive = mean(B.cells.naive), B.cells.memory = mean(B.cells.memory), 
    Plasma.cells = mean(Plasma.cells), T.cells.CD8 = mean(T.cells.CD8), 
    T.cells.CD4.naive = mean(T.cells.CD4.naive), T.cells.CD4.memory.resting = mean(T.cells.CD4.memory.resting), 
    T.cells.CD4.memory.activated = mean(T.cells.CD4.memory.activated), 
    T.cells.follicular.helper = mean(T.cells.follicular.helper), 
    T.cells.regulatory..Tregs. = mean(T.cells.regulatory..Tregs.), 
    T.cells.gamma.delta = mean(T.cells.gamma.delta), 
    NK.cells.resting = mean(NK.cells.resting), NK.cells.activated = mean(NK.cells.activated), 
    Monocytes = mean(Monocytes), Macrophages.M0 = mean(Macrophages.M0), 
    Macrophages.M1 = mean(Macrophages.M1), Macrophages.M2 = mean(Macrophages.M2), 
    Dendritic.cells.resting = mean(Dendritic.cells.resting), 
    Dendritic.cells.activated = mean(Dendritic.cells.activated), 
    Mast.cells.resting = mean(Mast.cells.resting), 
    Mast.cells.activated = mean(Mast.cells.activated), 
    Eosinophils = mean(Eosinophils), Neutrophils = mean(Neutrophils))

# cor(Brief[,-(1:4)])

Brief[Brief$d1_group == 1, 2] <- "A"
Brief[Brief$d1_group == 2, 2] <- "B"

shapiro.test(Brief$B.cells.naive)
shapiro.test(Brief$Plasma.cells)
shapiro.test(Brief$Monocytes)
## We can find all the variables in the data is not
## normal,

## But as anova method is not very sensitive to the
## normal assumption, we can do a two-way anova for
## each ingredient.


Brief$d1_group <- as.factor(Brief$d1_group)
Brief$d2_group <- as.factor(Brief$d2_group)


g_anova <- function(data) {
    result <- numeric()
    tm2 <- "d1_group+d2_group"
    for (i in 5:26) {
        tm1 <- paste0(colnames(Brief)[i], "~")
        fam <- formula(paste0(tm1, tm2))
        fit <- lm(fam, data = Brief)
        s <- anova(fit)
        
        p1 <- round(s$`Pr(>F)`[1] * 22, 4)
        p2 <- round(s$`Pr(>F)`[2] * 22, 4)
        if (p1 > 1) 
            p1 <- 1
        if (p2 > 1) 
            p2 <- 1
        p1 <- abs(log10(p1))
        p2 <- abs(log10(p2))
        p <- c(p1, p2)
        result <- rbind(result, p)
    }
    result <- as.data.frame(result)
    colnames(result) <- c("d1", "d2")
    rownames(result) <- colnames(data)[5:26]
    return(result)
}



table1 <- g_anova(Brief)
table1$cell_type <- rownames(table1)
table1 <- table1 %>% gather(1:2, key = "delta_type", 
    value = "p_value")
### First Version
pdf("Barplot0.pdf", width = 7, height = 7, paper = "special")
ggplot(table1) + geom_bar(mapping = aes(x = cell_type, 
    y = p_value, fill = delta_type), stat = "identity", 
    position = "dodge") + geom_hline(data = data.frame(type = "1.3", 
    col = "1.3"), aes(yintercept = 1.3, linetype = type, 
    colour = col), size = 0.4, show.legend = TRUE) + 
    geom_hline(data = data.frame(type = "2", col = "2"), 
        aes(yintercept = 2, linetype = type, colour = col), 
        size = 0.4, show.legend = TRUE) + scale_colour_manual(name = "Reference Line", 
    values = c(`1.3` = "black", `2` = "red")) + scale_linetype_manual(name = "Reference Line", 
    values = c(`1.3` = "dashed", `2` = "dashed")) + 
    coord_flip() + xlab("Cell Type") + ylab("FDR") + 
    labs(fill = "Delta Type") + scale_fill_discrete(labels = c(expression(Delta[1]), 
    expression(Delta[2]))) + theme(legend.text = element_text(size = 12, 
    hjust = 0.5)) + guides(fill = guide_legend(override.aes = list(linetype = c(0, 
    0))), color = guide_legend(override.aes = list(linetype = c(2, 
    2))))
dev.off()

### Final Version
pdf("Barplot.pdf", width = 7, height = 7, paper = "special")
ggplot(table1) + geom_bar(mapping = aes(x = cell_type, 
    y = p_value, fill = delta_type), width = 0.5, stat = "identity", 
    position = "dodge") + geom_hline(data = data.frame(type = "1.3", 
    col = "1.3"), aes(yintercept = 1.3, linetype = type, 
    colour = col), size = 0.4, show.legend = TRUE) + 
    geom_hline(data = data.frame(type = "2", col = "2"), 
        aes(yintercept = 2, linetype = type, colour = col), 
        size = 0.4, show.legend = TRUE) + scale_colour_manual(name = "Reference Line", 
    values = c(`1.3` = "black", `2` = "red"), labels = c(expression(group("|", 
        log[10] * 0.05, "|")), expression(group("|", 
        log[10] * 0.01, "|")))) + scale_linetype_manual(name = "Reference Line", 
    values = c(`1.3` = "dashed", `2` = "dashed"), labels = c(expression(group("|", 
        log[10] * 0.05, "|")), expression(group("|", 
        log[10] * 0.01, "|")))) + coord_flip() + xlab("Cell Type") + 
    ylab(expression(group("|", log[10] * FDR, "|"))) + 
    labs(fill = "Delta Type") + scale_fill_discrete(labels = c(expression(Delta[1]), 
    expression(Delta[2]))) + theme(legend.text = element_text(size = 12, 
    hjust = 0.5)) + guides(fill = guide_legend(override.aes = list(linetype = c(0, 
    0))), color = guide_legend(override.aes = list(linetype = c(2, 
    2))))
dev.off()

# write.table(table1,'Barplot.txt',row.names=FALSE)

## plot2

size <- Brief %>% group_by(Cohort) %>% summarize(group_size = n())

size <- subset(size, group_size >= 40)
size$Cohort <- as.character(size$Cohort)

Brief1 <- left_join(size, Brief, by = "Cohort")

### Seems need to take out T.cells.gamma.delta, which
### has so many 0's in it. Some tumor type, all zero,
### can't do an anova.
g_anova_matrix <- function(data) {
    mat <- numeric()
    tm2 <- "d1_group+d2_group"
    for (j in 1:dim(size)[1]) {
        tmpname <- size$Cohort[j]
        data_in_use <- subset(data, Cohort == tmpname)
        result1 <- numeric()
        result2 <- numeric()
        
        for (i in c(6:14, 16:27)) {
            tm1 <- paste0(colnames(data)[i], "~")
            fam <- formula(paste0(tm1, tm2))
            fit <- lm(fam, data = data_in_use)
            s <- summary(fit)
            ava <- anova(fit)
            
            coef1 <- round(s$coefficients[2, 1], 3)
            coef2 <- round(s$coefficients[3, 1], 3)
            p1 <- ava$`Pr(>F)`[1] * 21
            p2 <- ava$`Pr(>F)`[2] * 21
            if (p1 > 1) {
                p1 <- 1
            }
            if (p2 > 1) {
                p2 <- 1
            }
            coef <- c(coef1, coef2)
            p1 <- round(abs(log10(p1)), 1)
            p2 <- round(abs(log10(p2)), 1)
            p <- c(p1, p2)
            result1 <- rbind(result1, coef)
            result2 <- rbind(result2, p)
        }
        
        result1 <- as.data.frame(result1)
        result2 <- as.data.frame(result2)
        result1$cell_type <- colnames(data)[c(6:14, 
            16:27)]
        result1$tumor_type <- tmpname
        result2$cell_type <- colnames(data)[c(6:14, 
            16:27)]
        result2$tumor_type <- tmpname
        
        colnames(result1)[1:2] <- c("d1", "d2")
        result1 <- result1 %>% gather(1:2, key = "delta_type", 
            value = "coefs")
        
        colnames(result2)[1:2] <- c("p1", "p2")
        result2 <- result2 %>% gather(1:2, key = "p_type", 
            value = "FDR")
        result1 <- arrange(result1, tumor_type, cell_type, 
            delta_type)
        result2 <- arrange(result2, tumor_type, cell_type, 
            p_type)
        result <- cbind(result1, result2)
        result <- result[, -(5:7)]
        mat <- rbind(mat, result)
    }
    return(mat)
}


coef_matrix <- g_anova_matrix(Brief1)

colnames(coef_matrix)[4] <- "Main Effects"

pdf("Main_Effects1.pdf", width = 12, height = 7, paper = "special")
coef_matrix %>% ggplot() + aes(x = delta_type, y = cell_type) + 
    geom_raster(aes(fill = `Main Effects`)) + geom_text(aes(label = ifelse(FDR >= 
    2, as.character(FDR), "")), hjust = 0.5, vjust = 0.7, 
    size = 3) + facet_wrap(~tumor_type, nrow = 1) + 
    scale_fill_gradient(low = "blue", high = "yellow") + 
    xlab("Grouping Factor") + ylab("Immune Cell Type")
dev.off()

# write.table(coef_matrix,'Main_Effect1.txt',row.names=FALSE)


####### Let's do some data mining stuff

Brief$group <- rep(0, dim(Brief)[1])
for (i in 1:dim(Brief)[1]) Brief$group[i] <- paste0(Brief$d1_group[i], 
    Brief$d2_group[i])

Brief$group <- as.factor(Brief$group)
Brief$sim_group <- rep(0, dim(Brief)[1])

Brief[Brief$group == "A1", 28] <- 1
Brief[Brief$group == "A2", 28] <- 2
Brief[Brief$group == "B1", 28] <- 3
Brief[Brief$group == "B2", 28] <- 4
Brief$sim_group <- as.factor(Brief$sim_group)

index_g1 <- which(Brief$group == "A1")
index_g2 <- which(Brief$group == "A2")

index_g3 <- which(Brief$group == "B1")
index_g4 <- which(Brief$group == "B2")


## Shuffle the index
index_g1 <- sample(index_g1, length(index_g1))
index_g2 <- sample(index_g2, length(index_g2))
index_g3 <- sample(index_g3, length(index_g3))
index_g4 <- sample(index_g4, length(index_g4))

## Create 5 equally separated folds for each group
## type

id1 <- list()
folds <- cut(1:length(index_g1), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id1[[i]] <- index_g1[folds == i]
}

id2 <- list()
folds <- cut(1:length(index_g2), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id2[[i]] <- index_g2[folds == i]
}

id3 <- list()
folds <- cut(1:length(index_g3), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id3[[i]] <- index_g3[folds == i]
}

id4 <- list()
folds <- cut(1:length(index_g4), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id4[[i]] <- index_g4[folds == i]
}

id <- list()

for (i in 1:5) {
    id[[i]] <- c(id1[[i]], id2[[i]], id3[[i]], id4[[i]])
    id[[i]] <- sample(id[[i]], length(id[[i]]))
}

## Then we get the index for the group


## First Do some classification trees
## install.packages('rpart')
library(rpart)

## First, we use all the data to see if there is any
## pattern

fit <- rpart(sim_group ~ B.cells.naive + B.cells.memory + 
    Plasma.cells + T.cells.CD8 + T.cells.CD4.naive + 
    T.cells.CD4.memory.resting + T.cells.CD4.memory.activated + 
    T.cells.follicular.helper + T.cells.regulatory..Tregs. + 
    T.cells.gamma.delta + NK.cells.resting + NK.cells.activated + 
    Monocytes + Macrophages.M0 + Macrophages.M1 + Macrophages.M2 + 
    Dendritic.cells.resting + Dendritic.cells.activated + 
    Mast.cells.resting + Mast.cells.activated + Eosinophils + 
    Neutrophils, method = "class", data = Brief)

printcp(fit)  # display the results 
plotcp(fit)  # visualize cross-validation results 
summary(fit)  # detailed summary of splits

# plot tree
plot(fit, uniform = TRUE)
text(fit, use.n = TRUE, all = TRUE, cex = 0.8)

# prune the tree
pfit <- prune(fit, cp = fit$cptable[which.min(fit$cptable[, 
    "xerror"]), "CP"])

# plot the pruned tree
plot(pfit, uniform = TRUE, main = "Pruned Classification Tree for Kyphosis")
text(pfit, use.n = TRUE, all = TRUE, cex = 0.8)

## Seems the classification tree is not a good idea.

## Random forest maybe
## install.packages('randomForest')
library(randomForest)


train <- Brief[-id[[1]], ]
test <- Brief[id[[1]], ]

fit <- randomForest(sim_group ~ B.cells.naive + B.cells.memory + 
    Plasma.cells + T.cells.CD8 + T.cells.CD4.naive + 
    T.cells.CD4.memory.resting + T.cells.CD4.memory.activated + 
    T.cells.follicular.helper + T.cells.regulatory..Tregs. + 
    T.cells.gamma.delta + NK.cells.resting + NK.cells.activated + 
    Monocytes + Macrophages.M0 + Macrophages.M1 + Macrophages.M2 + 
    Dendritic.cells.resting + Dendritic.cells.activated + 
    Mast.cells.resting + Mast.cells.activated + Eosinophils + 
    Neutrophils, data = train, importance = TRUE, ntree = 1000)

varImpPlot(fit)
plot(fit)
fit$err.rate
## Very poor prediction, because samples of group1
## and 4 are small, so they are all sacrificed.

## Then we shall raise the number of samples in
## group 1 and 4 by sampling with replacement.





index_g1 <- sample(index_g1, length(index_g3), replace = TRUE)
index_g2 <- sample(index_g2, length(index_g2))
index_g3 <- sample(index_g3, length(index_g3))
index_g4 <- sample(index_g4, length(index_g2), replace = TRUE)

## Create 5 equally separated folds for each group
## type

id1 <- list()
folds <- cut(1:length(index_g1), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id1[[i]] <- index_g1[folds == i]
}

id2 <- list()
folds <- cut(1:length(index_g2), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id2[[i]] <- index_g2[folds == i]
}

id3 <- list()
folds <- cut(1:length(index_g3), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id3[[i]] <- index_g3[folds == i]
}

id4 <- list()
folds <- cut(1:length(index_g4), breaks = 5, labels = FALSE)
for (i in 1:5) {
    id4[[i]] <- index_g4[folds == i]
}

id <- list()

for (i in 1:5) {
    id[[i]] <- c(id1[[i]], id2[[i]], id3[[i]], id4[[i]])
    id[[i]] <- sample(id[[i]], length(id[[i]]))
}

# Do a random forest again

train <- Brief[c(id[[2]], id[[3]], id[[4]], id[[5]]), 
    ]
test <- Brief[id[[1]], ]

fit <- randomForest(sim_group ~ B.cells.naive + B.cells.memory + 
    Plasma.cells + T.cells.CD8 + T.cells.CD4.naive + 
    T.cells.CD4.memory.resting + T.cells.CD4.memory.activated + 
    T.cells.follicular.helper + T.cells.regulatory..Tregs. + 
    T.cells.gamma.delta + NK.cells.resting + NK.cells.activated + 
    Monocytes + Macrophages.M0 + Macrophages.M1 + Macrophages.M2 + 
    Dendritic.cells.resting + Dendritic.cells.activated + 
    Mast.cells.resting + Mast.cells.activated + Eosinophils + 
    Neutrophils, data = train, importance = TRUE, ntree = 2000, 
    mtry = 3, nodesize = 2)

varImpPlot(fit)
plot(fit)
fit$err.rate


Prediction <- predict(fit, test)

table(Prediction, test$sim_group)


### See which variables are good to separate A/B and
### 1/2


## A / B

fit1 <- randomForest(d1_group ~ B.cells.naive + B.cells.memory + 
    Plasma.cells + T.cells.CD8 + T.cells.CD4.naive + 
    T.cells.CD4.memory.resting + T.cells.CD4.memory.activated + 
    T.cells.follicular.helper + T.cells.regulatory..Tregs. + 
    T.cells.gamma.delta + NK.cells.resting + NK.cells.activated + 
    Monocytes + Macrophages.M0 + Macrophages.M1 + Macrophages.M2 + 
    Dendritic.cells.resting + Dendritic.cells.activated + 
    Mast.cells.resting + Mast.cells.activated + Eosinophils + 
    Neutrophils, data = train, importance = TRUE, ntree = 2450, 
    mtry = 4, nodesize = 4)

varImpPlot(fit1)
plot(fit1)
fit1$err.rate


Prediction <- predict(fit1, test)

table(Prediction, test$d1_group)

## 1 / 2

fit2 <- randomForest(d2_group ~ B.cells.naive + B.cells.memory + 
    Plasma.cells + T.cells.CD8 + T.cells.CD4.naive + 
    T.cells.CD4.memory.resting + T.cells.CD4.memory.activated + 
    T.cells.follicular.helper + T.cells.regulatory..Tregs. + 
    T.cells.gamma.delta + NK.cells.resting + NK.cells.activated + 
    Monocytes + Macrophages.M0 + Macrophages.M1 + Macrophages.M2 + 
    Dendritic.cells.resting + Dendritic.cells.activated + 
    Mast.cells.resting + Mast.cells.activated + Eosinophils + 
    Neutrophils, data = train, importance = TRUE, ntree = 2450, 
    mtry = 4, nodesize = 4)

varImpPlot(fit2)
plot(fit2)
fit2$err.rate


Prediction <- predict(fit2, test)

table(Prediction, test$d2_group)

## Do lasso

# install.packages('glmnet')
library(glmnet)

# glmnet() requires x to be in matrix class, so
# saving out the separate variables to be used as Y
# and X.

## Use the randomly sampled balanced data to
## construct lasso model.

y.1 <- train$sim_group
x.1 <- as.matrix(train[, 5:26])
y.2 <- test$sim_group
x.2 <- as.matrix(test[, 5:26])


lasso.1 <- glmnet(y = y.1, x = x.1, family = "multinomial")

plot(lasso.1, label = TRUE)  # Plots coefficient path

# cv.glmnet() uses crossvalidation to estimate
# optimal lambda
cv.lasso.1 <- cv.glmnet(y = y.1, x = x.1, family = "multinomial")

plot(cv.lasso.1)  # Plot mean cross validation error


coef(cv.lasso.1)  # Print out coefficients at optimal lambda
# (The default is to use largest value of lambda
# such that error is within 1 standard error of the
# minimum as lambda)

# Make Prediction
predict.1.2 <- predict(cv.lasso.1, newx = x.2, s = cv.lasso.1$lambda.1se, 
    type = "class")
table(y.2, predict.1.2)





