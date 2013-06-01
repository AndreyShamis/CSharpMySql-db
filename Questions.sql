CREATE TRIGGER `update_question_status` AFTER INSERT ON `tbl_answer_rank`
FOR each ROW BEGIN
   UPDATE `tbl_question`
   SET id_status='1'
   WHERE `tbl_question`.`id_question`=NEW.`id_question`;
END;

CREATE TRIGGER `update_user_score_on_question` BEFORE INSERT ON `tbl_question`
FOR each ROW BEGIN
   UPDATE `tbl_users` SET id_score=id_score+2   WHERE  tbl_users.id_user=NEW.id_user;
END;

CREATE TRIGGER `update_user_score_on_answer` AFTER INSERT ON `tbl_answer`
FOR each ROW BEGIN
   UPDATE `tbl_users` SET id_score=id_score+1   WHERE  tbl_users.id_user=NEW.id_user;
END;
--///////////////////////////////////////////////////////////////////////////////////////
--/////////////////////////////////// 1

SELECT Q.id_question as id , Q.id_date , "question" as table_type FROM tbl_question as Q WHERE Q.id_user='12345'
UNION
 SELECT A.id_answer as id,A.id_date , "answer" as table_type FROM tbl_answer as A WHERE A.id_user='12345'


--/////////////////////////////////// 2
SELECT tbl_answer.* FROM tbl_answer,tbl_best_answer_rank,tbl_category AS CS,tbl_category AS CP,tbl_question AS Q
WHERE tbl_answer.id_user='12345'
AND
tbl_answer.id_answer = tbl_best_answer_rank.id_answer
AND
tbl_answer.id_question = Q.id_question
AND
Q.id_category = CS.id_category
AND
CP.id_name='מחשבים'
AND
CS.id_name = 'אפיון ועיצוב'
AND
CS.id_parent= CP.id_category
---////////////////////////////////    3
SELECT AR.* FROM tbl_answer_rank AS AR,tbl_best_answer_rank AS BAR,tbl_question AS Q
WHERE
AR.id_answer=BAR.id_answer
AND
AR.id_user='12345'
AND
DATE(Q.id_date) >=DATE('2012-07-01')
AND
DATE(Q.id_date) <=DATE('2012-07-31')
AND
DATEDIFF( CURRENT_TIMESTAMP(),Q.id_date )>4
AND
Q.id_status='0'
AND
Q.id_question=AR.id_question



--/////////////////////////////  4
SELECT COUNT( * ) , "Up" as What
FROM tbl_answer, tbl_thumb
WHERE tbl_answer.id_user =  '12345'
AND tbl_answer.id_answer = tbl_thumb.id_answer
AND tbl_thumb.id_up_down='1'
UNION
SELECT COUNT( * ) , "Down" as What
FROM tbl_answer, tbl_thumb
WHERE tbl_answer.id_user =  '12345'
AND tbl_answer.id_answer = tbl_thumb.id_answer
AND tbl_thumb.id_up_down='2'


--/////////////////////////////     5
SELECT A.* FROM tbl_answer  AS A, tbl_best_answer_rank AS BAR, tbl_category AS CS,tbl_category AS CP , tbl_question AS Q
WHERE
A.id_answer=BAR.id_answer
AND
BAR.id_question= Q.id_question
AND
Q.id_category=CS.id_category
AND
CP.id_name='מחשבים'
AND
CS.id_name = 'אפיון ועיצוב'
AND
CS.id_parent= CP.id_category


--/////////////////////////////    6
SELECT A.* FROM tbl_answer AS A, tbl_question AS Q
WHERE
A.id_question=Q.id_question
AND
DATE(A.id_date) >= DATE('2012-04-01')
AND
DATE(A.id_date) <=DATE('2012-04-30')
AND
DATE(Q.id_date) <DATE('2012-03-01')



--/////////////////////////////    7
SELECT Q.* FROM tbl_question as Q, tbl_funs AS F
WHERE

Q.id_user=F.id_other
AND
F.id_self='12345'
AND
Q.id_status='0'
AND
Q.id_question NOT IN (SELECT id_question FROM  tbl_best_answer_rank as BAR WHERE BAR.id_question=Q.id_question)
AND
  DATEDIFF( CURRENT_TIMESTAMP(),Q.id_date )<=4

--//////////////////////////////////////////   8
SELECT * FROM tbl_question AS Q
WHERE
Q.id_user='12345'
AND
id_question not in (SELECT AR.id_question FROM tbl_best_answer_rank AS AR WHERE AR.id_question=Q.id_question )
AND
Q.id_status='0'
AND
DATE(Q.id_date) >=DATE('2012-03-01')
AND
DATE(Q.id_date) <=DATE('2012-03-31')
AND
DATEDIFF( CURRENT_TIMESTAMP(),Q.id_date )>4


  --////////////////////////////////////////////
-- 9
--
SELECT * FROM tbl_users as U WHERE
U.id_user In (SELECT id_other FROM tbl_funs WHERE id_self='12345')
AND
 EXISTS
        (SELECT * FROM tbl_answer as A, tbl_question as Q
          WHERE A.id_question=Q.id_question
          AND
          (A.id_user=U.id_user AND  Q.id_user='12345'
                  OR
          A.id_user='12345'  AND  Q.id_user=U.id_user
          )
)


--//////////////   PROGRAM

SET @dateFrom=DATE('1970-01-01');
SET @dateTo=DATE('2012-12-31');
SET @dateF='%Y-%m-%d';

SELECT ALLRES.date,sum(nofUsers) as nofUsers,sum(nofQuestions) as nofQuestions,sum(nofAnswers) as nofAnswers,sum(nofOfAnswersRank)as nofOfAnswersRank FROM
( SELECT * FROM (
(SELECT DATE_FORMAT(userCounter.date,@dateF)as date  , sum(userCounter.c) as nofUsers, 0 as nofQuestions , 0 as nofAnswers, 0 as nofOfAnswersRank FROM
((SELECT  count(*) as c,DATE_FORMAT(RE.id_date,@dateF) as date FROM tbl_remark AS RE WHERE RE.id_date >= @dateFrom AND RE.id_date <= @dateTo GROUP BY RE.id_date)
UNION (SELECT  count(*) as c,DATE_FORMAT(QR.id_date,@dateF) as date FROM tbl_question_rank AS QR WHERE QR.id_date >= @dateFrom AND QR.id_date <= @dateTo GROUP BY QR.id_date)
UNION (SELECT  count(*) as c,DATE_FORMAT(Q.id_date,@dateF) as date FROM tbl_question AS Q WHERE Q.id_date >= @dateFrom AND Q.id_date <= @dateTo GROUP BY Q.id_date)
UNION (SELECT count(*) as c,DATE_FORMAT(A.id_date,@dateF) as date FROM tbl_answer AS A WHERE A.id_date >= @dateFrom AND A.id_date <= @dateTo GROUP BY A.id_date)
UNION (SELECT count(*) as c,DATE_FORMAT(A.id_date,@dateF) as date FROM tbl_answer AS A WHERE A.id_date_rank >= @dateFrom AND A.id_date_rank <= @dateTo GROUP BY A.id_date ) )
 as userCounter
GROUP BY DATE(userCounter.date) ORder by userCounter.date) as t1 )
UNION ((SELECT DATE_FORMAT(Q.id_date,@dateF) as date,0 as nofUsers, count(*) as nofQuestions, 0 as nofAnswers, 0 as nofOfAnswersRank FROM tbl_question AS Q WHERE Q.id_date >= @dateFrom AND Q.id_date <= @dateTo GROUP BY Q.id_date ))
UNION ((SELECT DATE_FORMAT(A.id_date,@dateF)as date ,0 as nofUsers,0 as nofQuestions,count(*) as nofAnswers , 0 as nofOfAnswersRank FROM tbl_answer AS A WHERE A.id_date >= @dateFrom AND A.id_date <= @dateTo GROUP BY A.id_date))
UNION ((SELECT DATE_FORMAT(A.id_date,@dateF)as date ,0 as nofUsers,0 as nofQuestions,0 as nofAnswers , count(*) as nofOfAnswersRank FROM tbl_answer AS A WHERE A.id_date_rank >= @dateFrom AND A.id_date_rank <= @dateTo GROUP BY A.id_date_rank ))
) as ALLRES GROUP BY ALLRES.date ORDER BY ALLRES.date;
