
DROP TABLE IF EXISTS Swim CASCADE;
DROP TABLE IF EXISTS Heat CASCADE;
DROP TABLE IF EXISTS StrokeOf CASCADE;
DROP TABLE IF EXISTS Event CASCADE;
DROP TABLE IF EXISTS Participant CASCADE;
DROP TABLE IF EXISTS Meet CASCADE;
DROP TABLE IF EXISTS Stroke CASCADE;
DROP TABLE IF EXISTS Leg CASCADE;
DROP TABLE IF EXISTS Distance CASCADE;
DROP TABLE IF EXISTS Org CASCADE;


CREATE OR REPLACE FUNCTION CreateOrg()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Org(ID CHAR(4), name varchar(50), is_univ BOOLEAN, PRIMARY KEY(ID));
END $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION CreateLeg()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Leg(leg INT, PRIMARY KEY(leg));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateStroke()
RETURNS VOID
AS $$
BEGIN
DROP TABLE IF EXISTS Stroke;
CREATE TABLE Stroke(stroke CHAR(15), PRIMARY KEY(stroke));
END $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION CreateStrokeOf()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE StrokeOf(event_id CHAR(10),leg int,stroke CHAR(15),
                      PRIMARY KEY(event_id,leg),
                      FOREIGN KEY(event_id) REFERENCES Event(ID),
                      FOREIGN KEY(leg) REFERENCES Leg(leg));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateDistance()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Distance(distance CHAR(3), PRIMARY KEY(distance));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateParticipant()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Participant(ID CHAR(7),
                         gender CHAR(1),
                         org_id CHAR(4),
						 name VARCHAR(50),
						 PRIMARY KEY(ID),
                         FOREIGN KEY (org_id) REFERENCES Org(ID));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateMeet()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Meet(name VARCHAR(50), start_date date, num_days int, org_id CHAR(4), 
                  PRIMARY KEY(name),FOREIGN KEY (org_id) REFERENCES Org(ID));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateEvent()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Event(ID CHAR(10),
                   gender CHAR(1),
                   distance CHAR(3), PRIMARY KEY(ID),
                   FOREIGN KEY (distance) REFERENCES Distance(distance));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateHeat()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Heat (ID CHAR(10),
                   event_id CHAR(10),
                   meet_name VARCHAR(50), 
                   PRIMARY KEY(ID, event_id, meet_name),
                   FOREIGN KEY (event_id) REFERENCES Event(ID),
                   FOREIGN KEY (meet_name) REFERENCES Meet(name));
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION CreateSwim()
RETURNS VOID
AS $$
BEGIN
CREATE TABLE Swim (heat_id CHAR(10),
                   event_id CHAR(10),
                   meet_name VARCHAR(50),
                   participant_id CHAR(7),
                   leg int,
                   time FLOAT,
                   PRIMARY KEY(heat_id, event_id, meet_name, participant_id),
                   FOREIGN KEY (heat_id, event_id, meet_name) REFERENCES Heat(ID, event_id, meet_name),
                   FOREIGN KEY (participant_id) REFERENCES Participant(ID),
                   FOREIGN KEY (leg) REFERENCES Leg(leg));
END $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION InsertOrg(org_id CHAR(4), org_name varchar(50), org_is_univ BOOLEAN)
RETURNS VOID
AS $$
BEGIN
INSERT INTO Org 
VALUES(org_id, org_name, org_is_univ)
ON CONFLICT (ID) DO UPDATE SET (name, is_univ) = (org_name, org_is_univ);
END $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION InsertMeet(m_name VARCHAR(50), m_start_date date, m_num_days int, m_org_id CHAR(4))
RETURNS VOID
AS $$
BEGIN
INSERT INTO Meet VALUES
(m_name, m_start_date, m_num_days, m_org_id)
ON CONFLICT (name) DO UPDATE SET (start_date, num_days, org_id) =
(m_start_date, m_num_days, m_org_id);
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertParticip(p_id CHAR(7), p_gender CHAR(1), p_org_id CHAR(4), p_name VARCHAR(50))
RETURNS VOID
AS $$
BEGIN
INSERT INTO Participant VALUES
(p_id,p_gender, p_org_id, p_name)
ON CONFLICT (ID) DO UPDATE SET (gender, org_id, name) = (p_gender, p_org_id, p_name);
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertEvent(e_id CHAR(10),
                                       e_gender CHAR(1),
                                       e_distance CHAR(3))
RETURNS VOID
AS $$
BEGIN
INSERT INTO Event VALUES
(e_id, e_gender, e_distance)
ON CONFLICT (ID) DO UPDATE SET (gender,distance) = (e_gender, e_distance);
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertStroke(m_stroke CHAR(15))
RETURNS VOID
AS $$
BEGIN
INSERT INTO Stroke VALUES
(m_stroke)
ON CONFLICT (stroke) DO NOTHING;
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Insert_StrokeOf(m_event_id CHAR(10) ,m_leg int,m_stroke CHAR(15))
RETURNS VOID
AS $$
BEGIN
INSERT INTO StrokeOf VALUES
(m_event_id,m_leg,m_stroke)
ON CONFLICT (event_id,leg) DO NOTHING;
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Insert_Leg(m_leg INT)
RETURNS VOID
AS $$
BEGIN
INSERT INTO Leg VALUES
(m_leg)
ON CONFLICT (leg) DO NOTHING;
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertDistance(m_distance CHAR(3))
RETURNS VOID
AS $$
BEGIN
INSERT INTO Distance VALUES
(m_distance)
ON CONFLICT (distance) DO NOTHING;
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertHeat(h_id CHAR(10),
                                      h_event_id CHAR(10),
                                      h_meet_name VARCHAR(50))
RETURNS VOID
AS $$
DECLARE
matches INT;
BEGIN
SELECT COUNT(*) into matches
FROM Heat
WHERE ID= h_id and event_id=h_event_id and meet_name=h_meet_name;
IF matches = 0 THEN
INSERT INTO Heat
VALUES(h_id, h_event_id, h_meet_name);
END IF;
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION Insert_Swim(s_heat_id CHAR(10),
                                      s_event_id CHAR(10),
                                      s_meet_name VARCHAR(50),
                                      s_participant_id CHAR(7),
                                      s_leg int,
                                      s_time FLOAT)
RETURNS VOID
AS $$
BEGIN
INSERT INTO Swim VALUES
(s_heat_id, s_event_id, s_meet_name, s_participant_id,s_leg,s_time)
ON CONFLICT (heat_id, event_id, meet_name, participant_id) DO UPDATE SET (leg,time) = (s_leg, s_time);
END $$
LANGUAGE plpgsql;






CREATE OR REPLACE FUNCTION CreateView()
RETURNS VOID
AS $$
BEGIN
        drop view if exists meet_org ;
        create view meet_org as
        select m.name as meet, o.name as school
        from Meet m
        inner join Org o on o.id = m.org_id;

        drop view if exists Participant_org;
        create view Participant_org as
        select p.id , p.name as swimmer_name, o.name as school
        from Participant p
        inner join org o on o.id = p.org_id;

        drop view if exists Participant_info ;
        create view Participant_info as
        select s.heat_id, s.event_id, s.meet_name, s.participant_id, s.leg, s.time, p.swimmer_name, p.school
        from Swim s
        inner join Participant_org p on p.id = s.participant_id
        order by s.event_id, s.heat_id, p.school;


        drop view if exists individual_info2;
        create view individual_info2 as
        select p.event_id, p.swimmer_name, p.school, min(p.time) as time
        from Participant_info p
        where p.event_id  not in (select s.event_id from StrokeOf s where s.leg > 1)
        group by p.event_id, p.swimmer_name, p.school;

        drop view if exists individual_info3 ;
        create view individual_info3 as
        select p.event_id, p.swimmer_name, p.school, p.time, rank() OVER (PARTITION BY p.event_id  ORDER BY p.time)
        from individual_info2 p;



        drop view if exists individual_rank_1;
        create view individual_rank_1 as
        select p.meet_name, p.event_id, p.heat_id, p.participant_id, p.swimmer_name, p.school, p.time
        from Participant_info p
        where p.event_id  not in (select s.event_id from StrokeOf s where s.leg > 1);

        drop view if exists individual_rank;
        create view individual_rank as
        select p.meet_name, p.event_id, p.heat_id, p.participant_id, p.swimmer_name, p.school, p.time, i.rank
        from individual_rank_1 p
        left join individual_info3 i on p.event_id = i.event_id and p.swimmer_name = i.swimmer_name and p.time = i.time
        order by p.event_id, i.rank;

        
        drop view if exists relay_rank ;
        create view relay_rank as
        select p.meet_name, p.event_id, p.heat_id, p.participant_id, p.leg,  p.swimmer_name, p.school, p.time
        from Participant_info p
        where p.event_id  in (select s.event_id from StrokeOf s where s.leg > 1)
        order by p.event_id, p.heat_id, p.school;

        drop view if exists relay_rank2 ;
        create view relay_rank2 as
        select r.meet_name, r.event_id, r.school, sum(r.time) as team_time, rank() OVER (PARTITION BY r.meet_name,r.event_id ORDER BY sum(r.time))
        from relay_rank r
        group by r.meet_name,r.event_id, r.school;

        drop view if exists relay_rank3;
        create view relay_rank3 as
        select r1.meet_name, r1.event_id, r1.heat_id, r1.participant_id, r1.leg,  r1.swimmer_name, r1.school, r1.time, r2.team_time, r2.rank
        from relay_rank r1
        inner join relay_rank2 r2 on r1.event_id = r2.event_id and r1.school = r2.school
        order by r1.event_id, r2.rank;
END $$
LANGUAGE plpgsql;



        


--function1 For a Meet, display a Heat Sheet

CREATE OR REPLACE FUNCTION MeetToHeat(m_meet_name varchar(20))
RETURNS VOID

AS $$
    BEGIN

        drop table if exists heat_result1 CASCADE;
        create table heat_result1 as
        select i.event_id, i.heat_id, i.participant_id,  i.swimmer_name, i.school, i.time, i.rank
        from individual_rank i
        where i.meet_name = m_meet_name
        order by i.event_id, i.rank;

        drop table if exists heat_result2 CASCADE;
        create table heat_result2 as
        select r.event_id, r.participant_id,  r.heat_id, r.swimmer_name, r.school, r.time, r.team_time, r.rank
        from relay_rank3 r
        where r.meet_name = m_meet_name
        order by r.event_id, r.rank;

    END $$
LANGUAGE plpgsql;




--function2 For a Participant and Meet, display a Heat Sheet limited to just that swimmer, including any relays they are in.

CREATE OR REPLACE FUNCTION PMToHeat(m_participant_name varchar(20), m_meet_name varchar(20))
RETURNS VOID
AS $$
    BEGIN

        drop table if exists temp_result CASCADE;
        create table temp_result as
        select r.meet_name, r.event_id, r.heat_id, r.participant_id,  r.swimmer_name, r.school, r.time, r.team_time, r.rank
        from relay_rank3 r
        where r.meet_name = m_meet_name
        order by r.event_id, r.rank;

        drop table if exists pm_result CASCADE;
        create table pm_result as
        select i.event_id, i.heat_id, i.school, i.time, i.rank
        from individual_rank i
        where i.swimmer_name = m_participant_name and i.meet_name = m_meet_name;

        drop table if exists pm_result1 CASCADE;
        create table pm_result1 as
        select r.event_id, r.heat_id, r.school, r.time, r.rank
        from temp_result r
        where r.swimmer_name = m_participant_name and r.meet_name = m_meet_name
        ;
    END $$
LANGUAGE plpgsql;



--function3 For a School and Meet, display a Heat Sheet limited to just that School’s swimmers.

CREATE OR REPLACE FUNCTION SMToHeat(m_school_name varchar(20), m_meet_name varchar(20))
RETURNS VOID
AS $$
    BEGIN

        drop table if exists temp_result CASCADE;
        create table temp_result as
        select r.meet_name, r.event_id, r.heat_id, r.participant_id,  r.swimmer_name, r.school, r.time, r.team_time, r.rank
        from relay_rank3 r
        where r.meet_name = m_meet_name
        order by r.event_id, r.rank;

        drop table if exists sm_result CASCADE;
        create table sm_result as
        select i.event_id, i.heat_id,  i.participant_id, i.swimmer_name, i.time, i.rank
        from individual_rank i
        where i.school = m_school_name and i.meet_name = m_meet_name
        order by event_id, heat_id;


        drop table if exists sm_result1 CASCADE;
        create table sm_result1 as
        select r.event_id, r.heat_id, r.participant_id, r.swimmer_name, r.time, r.team_time, r.rank
        from temp_result r
        where r.school = m_school_name and r.meet_name = m_meet_name
        order by event_id, heat_id;
    END $$
LANGUAGE plpgsql;


--function4 For a School and Meet, display just the names of the competing swimmers

CREATE OR REPLACE FUNCTION SMToSwimmer(m_school_name varchar(20), m_meet_name varchar(20))
RETURNS VOID
AS $$
    BEGIN

      
        drop table if exists temp_result CASCADE;
        create table temp_result as
        select r.meet_name, r.event_id, r.participant_id,  r.swimmer_name, r.school, r.time, r.team_time, r.rank
        from relay_rank3 r
        where r.meet_name = m_meet_name
        order by r.event_id, r.rank;

        drop table if exists sm_swim_result CASCADE;
        create table sm_swim_result as
        (
        select  i.swimmer_name
        from individual_rank i
        where i.school = m_school_name and i.meet_name = m_meet_name
        )
        union
        (
        select r.swimmer_name
        from temp_result r
        where r.school = m_school_name and r.meet_name = m_meet_name
        );
    END $$
LANGUAGE plpgsql;


--function5 For an Event and Meet, display all results sorted by time.

CREATE OR REPLACE FUNCTION EMToHeat(m_event_id varchar(5), m_meet_name varchar(20))
RETURNS VOID
AS $$
    BEGIN

        drop table if exists temp_result CASCADE;
        create table temp_result as
        select r.heat_id, r.meet_name, r.event_id, r.participant_id,  r.swimmer_name, r.school, r.time, r.team_time, r.rank
        from relay_rank3 r
        where r.meet_name = m_meet_name
        order by r.event_id, r.rank;

        drop table if exists em_result CASCADE;
        create table em_result as
        select  i.heat_id, i.swimmer_name, i.participant_id, i.time, i.rank
        from individual_rank i
        where i.event_id = m_event_id and i.meet_name = m_meet_name
        order by i.time;

        drop table if exists em_result1 CASCADE;
        create table em_result1 as
        select r.heat_id, r.swimmer_name, r.participant_id, r.time, r.team_time, r.rank
        from temp_result r
        where r.event_id = m_event_id and r.meet_name = m_meet_name
        order by r.team_time;
    END $$
LANGUAGE plpgsql;

--function6 For a Meet, display the scores of each school, sorted by scores


CREATE OR REPLACE FUNCTION CalScore(m_meet_name varchar(20))
RETURNS VOID
AS $$
    BEGIN

        drop table if exists relay_score CASCADE;
        create table relay_score as 
        select meet_name, school, rank, rank as grade  from relay_rank2 ;

        update relay_score set grade = 8 where rank = 1;
        update relay_score set grade = 4 where rank = 2;
        update relay_score set grade = 2 where rank = 3;
        update relay_score set grade = 0 where rank > 3;

        drop table if exists individual_score CASCADE;
        create table individual_score as
        select p.meet_name, p.event_id, p.participant_id, p.swimmer_name, p.school, p.time, p.rank, p.rank as grade
        from individual_rank p;


        update individual_score set grade = 6 where rank = 1;
        update individual_score set grade = 4 where rank = 2;
        update individual_score set grade = 3 where rank = 3;
        update individual_score set grade = 2 where rank = 4;
        update individual_score set grade = 1 where rank = 5;
        update individual_score set grade = 0 where rank > 5;

        drop table if exists individual_score2 CASCADE;
        create table individual_score2 as
        select p.meet_name, p.school, sum(p.grade) as grade
        from individual_score p
        group by meet_name, school;

        drop table if exists relay_score2 CASCADE;
        create table relay_score2 as
        select p.school, meet_name, sum(p.grade) as grade
        from relay_score p
        group by school, meet_name;

        drop table if exists sco_result2 CASCADE;
        create table sco_result2 as(
        select p.school, p.grade
        from individual_score2 p
        where p.meet_name = m_meet_name
        )
        union all
        (
        select r.school, r.grade
        from relay_score2 r
        where r.meet_name = m_meet_name
        );

        drop table if exists sco_result CASCADE;
        create table sco_result as(
        select p.school, sum(p.grade) as grade
        from sco_result2 p
        group by p.school
        order by grade
        );

        
    END $$
LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION dropf()
RETURNS VOID
AS $$
    BEGIN
        drop table if exists Org CASCADE;
        drop table if exists Meet CASCADE;
        drop table if exists Participant CASCADE;
        drop table if exists Leg CASCADE;
        drop table if exists Stroke CASCADE;
        drop table if exists Distance CASCADE;
        drop table if exists Event CASCADE;
        drop table if exists StrokeOf CASCADE;
        drop table if exists Heat CASCADE;
        drop table if exists Swim CASCADE;


        drop view if exists relayhelper ;
        drop view if exists meet_org ;
        drop view if exists Participant_org ;
        drop view if exists Participant_info ;
        drop view if exists individual_info2 ;
        drop view if exists individual_info3 ;
        drop view if exists individual_rank_1 ;
        drop view if exists individual_rank ;
        drop view if exists relay_rank ;
        drop view if exists relay_rank2 ;
        drop table if exists relay_score CASCADE;
        drop table if exists individual_score CASCADE;
        drop table if exists individual_score2 CASCADE;
        drop table if exists relay_score2 CASCADE;
        drop table if exists sco_result2 CASCADE;
        drop table if exists sco_result CASCADE;
        drop table if exists temp_result CASCADE;
        drop table if exists em_result CASCADE;
        drop table if exists em_result1 CASCADE;
        drop table if exists sm_result CASCADE;
        drop table if exists sm_result1 CASCADE;
        drop table if exists sm_swim_result CASCADE;

        drop table if exists pm_result CASCADE;
        drop table if exists pm_result1 CASCADE;
        drop table if exists heat_result1 CASCADE;
        drop table if exists heat_result2 CASCADE;
        drop view if exists relay_rank3 CASCADE;

        DROP FUNCTION IF EXISTS InsertOrg(m_id CHAR(4), m_name varchar(20), m_is_univ BOOLEAN);
        DROP FUNCTION IF EXISTS InsertMeet(m_name varchar(20), m_start_date date, m_num_days integer, m_org_id CHAR(4));
        DROP FUNCTION IF EXISTS InsertParticip(m_id CHAR(7), m_gender char(1), m_org_id CHAR(4), m_name varchar(20));
        DROP FUNCTION IF EXISTS InsertDistance(m_distance integer);
        DROP FUNCTION IF EXISTS InsertEvent(m_id CHAR(5), m_gender char(1), m_distance integer);
        DROP FUNCTION IF EXISTS Insert_StrokeOf(m_event_id CHAR(5), m_leg integer, m_stroke VARCHAR(20));
        DROP FUNCTION IF EXISTS InsertStroke(m_stroke VARCHAR(20));
        DROP FUNCTION IF EXISTS Insert_Leg(m_leg integer);
        DROP FUNCTION IF EXISTS InsertHeat(m_id integer, m_event_id CHAR(5), m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS Insert_Swim(m_heat_id integer, m_event_id CHAR(5), m_meet_name varchar(20), m_participant_id CHAR(7), m_leg integer, m_time decimal);

        DROP FUNCTION IF EXISTS MeetToHeat(m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS PMToHeat(m_participant_name varchar(20), m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS SMToHeat(m_school_name varchar(20), m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS SMToSwimmer(m_school_name varchar(20), m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS EMToHeat(m_event_id varchar(5), m_meet_name varchar(20));
        DROP FUNCTION IF EXISTS CalScore(m_meet_name varchar(20));


    END $$
LANGUAGE plpgsql;

