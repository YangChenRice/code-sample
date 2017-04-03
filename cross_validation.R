#cv_lsvm is my function to perform K-fold cross-validation using linear SVM. 
#To use it you just need to put the X matrix. the Y matrix, the number of fold, 
#the range of parameters and the method option describing the loss function to it, 
#and it will return you with a matrix of the cv error for every parameter in each 
#fold.
cv_lsvm <- function(X, Y, k, para, method) {
  require(e1071)
  
  cal_loss <- function(Y1, Y2, method) {
    npar <- length(para)
    num <- dim(Y1)[1]
    if (method == "misclassification") {
      err <- NULL
      for (i in 1:npar) {
        realtemp <- Y1[, i]
        pretemp <- Y2[, i]
        err <- c(err, sum(realtemp != pretemp)/num)
      }
      err
    } else if (method == "binomdev") {
      err <- NULL
      for (i in 1:npar) {
        realtemp <- Y1[, i]
        pretemp <- Y2[, i]
        loss <- NULL
        for (j in 1:num) {
          loss <- c(loss, log(1 + exp(-2 * realtemp[j] * pretemp[j])))
        }
        
        err <- c(err, mean(loss))
      }
      err
    } else if (method == "hinge") {
      err <- NULL
      for (i in 1:npar) {
        realtemp <- Y1[, i]
        pretemp <- Y2[, i]
        loss <- NULL
        for (j in 1:num) {
          loss <- c(loss, max(0, 1 - realtemp[j] * pretemp[j]))
        }
        
        err <- c(err, mean(loss))
      }
      err
    }
  }
  
  
  n <- dim(X)[1]
  sam <- sample(1:n, n)
  CVerrs <- NULL
  for (i in 1:k) {
    ind <- sam[floor((i - 1) * n/k + 1):floor(i * n/k)]
    Xin <- X[-ind, ]
    Yin <- Y[-ind]
    Xout <- X[ind, ]
    Yout <- Y[ind]
    din <- cbind(Xin, Author = Yin)
    dout <- cbind(Xout, Author = Yout)
    pre <- NULL
    for (j in para) {
      svm.fit <- svm(Author ~ ., data = din, kernel = "linear", cost = j, 
                     scale = TRUE)
      preclass <- as.numeric(as.character(predict(svm.fit, dout)))
      pre <- cbind(pre, preclass)
    }
    
    Y1 <- as.numeric(as.character(Yout)) %*% matrix(1, 1, length(para))
    Y2 <- matrix(as.numeric(pre), length(Yout), length(para))
    CVerrs <- cbind(CVerrs, cal_loss(Y1, Y2, method))
  }
  CVerrs
}

##Get the data
data2=subset(data,Author=="Austen"|Author=="London",select= -BookID)
data2$Author=as.numeric(data2$Author)
data2[data2$Author==2,70]=-1
data2$Author=as.factor(data2$Author)

N=dim(data2)[1]
tr_id=sample(N,ceiling(0.8*N))

Xtr=data2[tr_id,-70];Ytr=data2[tr_id,70]
Xts=data2[-tr_id,-70];Yts=data2[-tr_id,70]
tr=data2[tr_id,];ts=data2[-tr_id,]

##After loading the data and make necessary transformations.

k=5
cverrs <- cv_lsvm(Xtr, Ytr, k = 5, para = seq(0.1, 10, by = 0.5), method = "misclassification")
(cverr <- apply(cverrs, 1, mean))
para <- seq(0.1, 10, by = 0.5)

##The following part is choosing tuning parameters using two different criteria.

## Using the minimum CV error rulet
(optpara1 <- para[which.min(cverr)])

# Using one SE rule
SE <- sqrt(apply(cverrs, 1, var)/k)
minSE <- cverr[which.min(cverr)] + SE[which.min(cverr)]
minSEx <- which(cverr < minSE)[1]
(optpara2 <- para[minSEx])