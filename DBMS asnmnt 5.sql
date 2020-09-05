 --Q1. IDs and names of students who have applied to major in CS at some college.sID
SELECT sID, sName FROM STUDENT
WHERE sID IN (
       SELECT sID FROM APPLY
        WHERE major = 'CS'
    );

-- Q2. Find ID and name of student having same high school size as Jay.
SELECT DISTINCT sID, sName
FROM STUDENT
WHERE sizeHS = (
        SELECT sizeHS FROM STUDENT
        WHERE sName = 'Jay'
    )
ORDER BY sName;

-- Q3. Find ID and name of student having same high school size as Jay but result should not include Jay.
SELECT DISTINCT sID, sName
FROM STUDENT
WHERE sizeHS = (
        SELECT sizeHS FROM STUDENT
        WHERE sName = 'Jay'
    )
AND sName != 'Jay';

-- Q4. Find the name of student with their GPA and Sid whose GPA not equal to GPA of Irene?
SELECT DISTINCT sID, sName, GPA
FROM STUDENT
WHERE GPA != (
        SELECT GPA FROM STUDENT
        WHERE sName = 'Irene'
    )
ORDER BY sName;

-- Q5. Find college where any student having their name started from J have applied?
SELECT DISTINCT cName FROM APPLY
WHERE sID IN (
        SELECT sID FROM STUDENT
        WHERE sName LIKE 'J%'
    )
ORDER BY cName;

-- Q6. Find all different major where Irene has applied?
SELECT DISTINCT major FROM APPLY
WHERE sID IN (
        SELECT sID FROM STUDENT
        WHERE sName = 'Irene'
    )
ORDER BY major;

-- Q7. Find IDs of student and major who applied in any of major Irene had applied to?
SELECT DISTINCT sID, major FROM APPLY
WHERE major IN(
        SELECT major FROM APPLY
        WHERE sID IN(
                SELECT sID FROM STUDENT
                WHERE sName = 'Irene')
    )
ORDER BY sID, major;

-- Q8. Find IDs of student and major who applied in any of major Irene had applied to? 
--     But this time exclude Irene sID from the list.
SELECT DISTINCT sID, major FROM APPLY
WHERE major IN(
        SELECT major FROM APPLY
        WHERE sID IN(
                SELECT sID FROM STUDENT
                WHERE sName = 'Irene' ))
    AND sID NOT IN (
        SELECT sID FROM STUDENT
        WHERE sName = 'Irene'
    )
ORDER BY sID, major;

-- Q9. Give the number of colleges Jay applied to? (Remember count each college once no matter 
--     if he applied to same college twice with different major)
SELECT COUNT(DISTINCT cName) AS "No._college"
FROM APPLY
WHERE sID = (
        SELECT sID FROM STUDENT
        WHERE sName = 'Jay'
    );

-- Q10. Find sID of student who applied to more or same number of college where Jay has applied?
SELECT sID
FROM APPLY
GROUP BY sID
HAVING COUNT(DISTINCT cName) >= (SELECT COUNT(DISTINCT cName) AS COLLEGE_COUNT
                                 FROM APPLY
                                 WHERE sID = (SELECT sID
                                              FROM student
                                              WHERE sName = 'Jay'
                                 ))
ORDER BY sID;

-- Q11. Find details of Students who applied to major CS but not applied to major EE? (sID 987, 876, 543 should only be include in result)
SELECT *
FROM STUDENT WHERE sID IN (SELECT sID FROM APPLY WHERE major = 'CS' )
    AND sID NOT IN (SELECT sID FROM APPLY WHERE major = 'EE')
ORDER BY sID;

-- Q12. All colleges such that some other college is in same state. (Cornell should not be part of result as no other college in New York Hint: use exists)
SELECT cName
FROM COLLEGE OUTER_TABLE
WHERE EXISTS(SELECT cName FROM COLLEGE WHERE state = OUTER_TABLE.state AND cName != OUTER_TABLE.cName)
ORDER BY cName;
-- OR
SELECT cName FROM COLLEGE
WHERE state IN (
        SELECT state FROM COLLEGE GROUP BY state
        HAVING COUNT(state) >= 2 )
ORDER BY cName;

-- Q13. Find the college with highest enrollment.
SELECT cName FROM APPLY
GROUP BY cName
HAVING COUNT(DISTINCT sID) IN (
        SELECT MAX(ENROLLMENT_COUNT)
        FROM (
                SELECT COUNT(DISTINCT sID) AS ENROLLMENT_COUNT
                FROM APPLY GROUP BY cName
            )  COUNT_TABLE );

-- Q14. Find name of student having lowest GPA.
SELECT sName
FROM STUDENT
WHERE GPA = (
        SELECT MIN(GPA)
        FROM STUDENT
    );

-- Q15. Find the most popular major.
SELECT major FROM APPLY
GROUP BY major
HAVING COUNT(DISTINCT sID) IN (
        SELECT MAX(POPULAR_MAJOR)
        FROM (
                SELECT COUNT(DISTINCT sID) AS POPULAR_MAJOR
                FROM APPLY GROUP BY major
            ) COUNT_TABLE );

-- Q16. Find sID, sName, sizeHS of all students NOT from smallest HS.
SELECT sID, sName, sizeHS
FROM STUDENT
WHERE sizeHS <> (SELECT MIN(sizeHS) FROM STUDENT)
ORDER  BY sID;

-- Q17. Find the name of student who applies to all the colleges where sID 987 has applied?
SELECT sName, sID
FROM STUDENT AS OUTER_TABLE
WHERE NOT EXISTS(
        SELECT DISTINCT cName FROM APPLY
        WHERE sID = 987
            AND cName NOT IN(
                SELECT DISTINCT cName FROM APPLY
                WHERE sID = OUTER_TABLE.sID )
    );
    
    -- RUN THIS COMMAND BEFORE RUNNING FURTHER QUERIES
INSERT INTO Apply
SELECT s1.sID, 'Berkeley', 'CSE', 'Y'
FROM student s1
WHERE s1.sID IN
      (SELECT s.sID FROM student s WHERE s.sID NOT IN (SELECT a.sID FROM apply a where a.cName = 'Berkeley'));


-- Q18. Find college where all the student have applied.
SELECT DISTINCT cName
FROM APPLY OUTER_TABLE
WHERE NOT EXISTS(
        SELECT DISTINCT sID
        FROM APPLY
        WHERE sID NOT IN (
                SELECT DISTINCT sID
                FROM APPLY
                WHERE cNAME = OUTER_TABLE.cName));

-- Q19. Find sid of student who have not applied to Stanford.
SELECT DISTINCT sID
FROM APPLY
MINUS
SELECT DISTINCT sID
FROM APPLY
WHERE cName = 'Stanford';

-- Q20. Find sid of Student that applied to both Stanford and Berkeley.
SELECT DISTINCT sID
FROM APPLY
MINUS
SELECT DISTINCT sID
FROM APPLY
WHERE cName = 'Stanford'
   OR cName = 'Berkeley';

-- Q21. Give list of all names including all names of colleges and students.
SELECT DISTINCT sName, cName
FROM STUDENT, APPLY
WHERE APPLY.sID = STUDENT.sID
ORDER BY sName;

-- Q22. Create a table ApplicationInfo having columns sID: int, sName: varchar2(10) and number_of_applications: number(2) they filed?
--      Populate this table with appropriate data using insert command.
CREATE TABLE ApplicationInfo
(
    sID                    INTEGER,
    sName                  VARCHAR(10),
    number_of_applications NUMBER(2)
);

INSERT INTO ApplicationInfo
SELECT sID, sName, COUNT(*)
FROM STUDENT
         NATURAL JOIN APPLY
GROUP BY sID, sName;

-- Q23. Create table ApplicationData and load with ID, name and college where they applied with state of college (remember to include details of ALL 
--      students that have applied or not applied) on runtime using single query.
CREATE TABLE ApplicationData(
    sID INTEGER,
    sName VARCHAR(10),
    cName VARCHAR(10),
    state VARCHAR(2)
);
INSERT INTO ApplicationData
SELECT STUDENT.sID, sName,
    APPLY.cName, state
FROM STUDENT
    LEFT JOIN APPLY ON APPLY.sID = sTUDENT.sID
    LEFT JOIN COLLEGE ON APPLY.cName = COLLEGE.cName
ORDER BY STUDENT.sID;

-- Q24. Stanford decide not to take any student who have also applied to its rival Berkeley turn their application decision to N.
UPDATE APPLY OUTER_TABLE
SET decision = 'N'
WHERE cName = 'Stanford'
  AND 'Berkeley' IN (SELECT DISTINCT cName FROM APPLY WHERE sID = OUTER_TABLE.sID);


-- Q25. Delete applications that are filed to city ‘ New York ’.
DELETE FROM APPLY
WHERE cName IN (
        SELECT cName FROM COLLEGE
        WHERE state = 'NY'
    );
