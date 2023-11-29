WITH STUD AS (
  SELECT
    STUDENTS.STUDENT_NUMBER,
    STUDENTS.ID,
    STUDENTS.LASTFIRST,
    STUDENTS.FIRST_NAME,
    STUDENTS.MIDDLE_NAME,
    STUDENTS.LAST_NAME,
    STUDENTS.SCHOOLID,
    STUDENTS.ENROLL_STATUS
  FROM
    STUDENTS
), TERM AS (
  SELECT
    TERMS.FIRSTDAY,
    TERMS.LASTDAY,
    TERMS.YEARID,
    TERMS.NAME,
    TERMS.PORTION,
    TERMS.SCHOOLID
  FROM
    TERMS
  WHERE
    REGEXP_LIKE(TERMS.NAME, '[0-9]*-[0-9]*')
), CYE AS (
  SELECT
    ST.ID                                    STUDENTID,
    ST.ENTRYDATE                             ENTRYDATE,
    ST.EXITDATE                              EXITDATE,
    ST.EXITCODE                              EXITCODE,
    DBMS_LOB.SUBSTR(ST.EXITCOMMENT, 4000, 1) EXITCOMMENT,
    ST.SCHED_YEAROFGRADUATION                COHORT,
    ST.SCHOOLID                              SCHOOLID,
    (
      SELECT
        SCHOOLS.NAME
      FROM
        SCHOOLS
      WHERE
        SCHOOLS.SCHOOL_NUMBER = ST.SCHOOLID
    ) SCHOOLNAME,
    'Current Enrollment' AS ENROLLMENT
  FROM
    STUDENTS ST
    JOIN TERMS
    ON ST.SCHOOLID = TERMS.SCHOOLID JOIN SCHOOLS
    ON ST.SCHOOLID = SCHOOLS.SCHOOL_NUMBER
    LEFT JOIN TERM
    ON TERM.SCHOOLID = ST.SCHOOLID
  WHERE
    ST.EXITDATE < TRUNC(SYSDATE)
    AND ST.EXITDATE < TERMS.LASTDAY
    AND ST.ENTRYDATE > TERMS.FIRSTDAY
    AND REGEXP_LIKE(TERMS.NAME, '[0-9]{2}-[0-9]{2}')
    AND SCHOOLS.SCHOOLCATEGORYCODESETID IN (35201, 35202, 35203)
    AND ST.EXITCODE IN ('1927', '1925', '1926', '1918', '1916', '1907', '3505', '1921')
    AND ST.EXITDATE < TERM.LASTDAY
    AND ST.EXITDATE = ST.ENTRYDATE
    AND :P18_CURRENT_OR_PREVIOUS_ENROLLMENT = 'current'
    AND :P18_DATES_EQUAL = 'true'
  UNION
  SELECT
    ST.ID                                    STUDENTID,
    ST.ENTRYDATE                             ENTRYDATE,
    ST.EXITDATE                              EXITDATE,
    ST.EXITCODE                              EXITCODE,
    DBMS_LOB.SUBSTR(ST.EXITCOMMENT, 4000, 1) EXITCOMMENT,
    ST.SCHED_YEAROFGRADUATION                COHORT,
    ST.SCHOOLID                              SCHOOLID,
    (
      SELECT
        SCHOOLS.NAME
      FROM
        SCHOOLS
      WHERE
        SCHOOLS.SCHOOL_NUMBER = ST.SCHOOLID
    ) SCHOOLNAME,
    'Current Enrollment' AS ENROLLMENT
  FROM
    STUDENTS ST
    JOIN TERMS
    ON ST.SCHOOLID = TERMS.SCHOOLID JOIN SCHOOLS
    ON ST.SCHOOLID = SCHOOLS.SCHOOL_NUMBER
    LEFT JOIN TERM
    ON TERM.SCHOOLID = ST.SCHOOLID
  WHERE
    ST.EXITDATE < TRUNC(SYSDATE)
    AND ST.EXITDATE < TERMS.LASTDAY
    AND ST.ENTRYDATE > TERMS.FIRSTDAY
    AND REGEXP_LIKE(TERMS.NAME, '[0-9]{2}-[0-9]{2}')
    AND SCHOOLS.SCHOOLCATEGORYCODESETID IN (35201, 35202, 35203)
    AND ST.EXITCODE IN ('1927', '1925', '1926', '1918', '1916', '1907', '3505', '1921')
    AND ST.EXITDATE < TERM.LASTDAY
    AND ST.ENTRYDATE != ST.EXITDATE
    AND :P18_CURRENT_OR_PREVIOUS_ENROLLMENT = 'current'
    AND :P18_DATES_EQUAL = 'false'
), PYE AS (
  SELECT
    STUDENTS.ID                                         STUDENTID,
    REENROLLMENTS.ENTRYDATE                             ENTRYDATE,
    REENROLLMENTS.EXITDATE                              EXITDATE,
    REENROLLMENTS.EXITCODE                              EXITCODE,
    DBMS_LOB.SUBSTR(REENROLLMENTS.EXITCOMMENT, 4000, 1) EXITCOMMENT,
    STUDENTS.SCHED_YEAROFGRADUATION                     COHORT,
    REENROLLMENTS.SCHOOLID                              SCHOOLID,
    (
      SELECT
        SCHOOLS.NAME
      FROM
        SCHOOLS
      WHERE
        SCHOOLS.SCHOOL_NUMBER = REENROLLMENTS.SCHOOLID
    ) SCHOOLNAME,
    'Previous Enrollment' ENROLLMENT
  FROM
    REENROLLMENTS
    JOIN STUDENTS
    ON REENROLLMENTS.STUDENTID = STUDENTS.ID JOIN SCHOOLS
    ON REENROLLMENTS.SCHOOLID = SCHOOLS.SCHOOL_NUMBER
    LEFT JOIN TERM
    ON TERM.SCHOOLID = REENROLLMENTS.SCHOOLID
  WHERE
    STUDENTS.EXITCODE IN ('1927', '1925', '1926', '1918', '1916', '1907', '3505', '1921')
    AND SCHOOLS.SCHOOLCATEGORYCODESETID IN (35201, 35202, 35203)
    AND REENROLLMENTS.EXITDATE = (
      SELECT
        MAX(RE.EXITDATE)
      FROM
        REENROLLMENTS RE
      WHERE
        RE.STUDENTID = REENROLLMENTS.STUDENTID
        AND RE.EXITDATE = RE.ENTRYDATE
    )
    AND REENROLLMENTS.ENTRYDATE = REENROLLMENTS.EXITDATE
    AND REGEXP_LIKE(REENROLLMENTS.EXITCODE, '[0-9]{4}')
    AND REENROLLMENTS.EXITDATE < TERM.LASTDAY
    AND :P18_DATES_EQUAL = 'true'
    AND :P18_CURRENT_OR_PREVIOUS_ENROLLMENT = 'previous'
  UNION
  SELECT
    STUDENTS.ID                                         STUDENTID,
    REENROLLMENTS.ENTRYDATE                             ENTRYDATE,
    REENROLLMENTS.EXITDATE                              EXITDATE,
    REENROLLMENTS.EXITCODE                              EXITCODE,
    DBMS_LOB.SUBSTR(REENROLLMENTS.EXITCOMMENT, 4000, 1) EXITCOMMENT,
    STUDENTS.SCHED_YEAROFGRADUATION                     COHORT,
    REENROLLMENTS.SCHOOLID                              SCHOOLID,
    (
      SELECT
        SCHOOLS.NAME
      FROM
        SCHOOLS
      WHERE
        SCHOOLS.SCHOOL_NUMBER = REENROLLMENTS.SCHOOLID
    ) SCHOOLNAME,
    'Previous Enrollment' ENROLLMENT
  FROM
    REENROLLMENTS
    JOIN STUDENTS
    ON REENROLLMENTS.STUDENTID = STUDENTS.ID JOIN SCHOOLS
    ON REENROLLMENTS.SCHOOLID = SCHOOLS.SCHOOL_NUMBER
    LEFT JOIN TERM
    ON TERM.SCHOOLID = REENROLLMENTS.SCHOOLID
  WHERE
    STUDENTS.EXITCODE IN ('1927', '1925', '1926', '1918', '1916', '1907', '3505', '1921')
    AND SCHOOLS.SCHOOLCATEGORYCODESETID IN (35201, 35202, 35203)
    AND REENROLLMENTS.EXITDATE = (
      SELECT
        MAX(RE.EXITDATE)
      FROM
        REENROLLMENTS RE
      WHERE
        RE.STUDENTID = REENROLLMENTS.STUDENTID
        AND RE.ENTRYDATE != RE.EXITDATE
    )
    AND REENROLLMENTS.ENTRYDATE != REENROLLMENTS.EXITDATE
    AND REGEXP_LIKE(REENROLLMENTS.EXITCODE, '[0-9]{4}')
    AND REENROLLMENTS.EXITDATE < TERM.LASTDAY
    AND :P18_DATES_EQUAL = 'false'
    AND :P18_CURRENT_OR_PREVIOUS_ENROLLMENT = 'previous'
), COMBINED AS (
  SELECT
    STUD.ID                              ID,
    STUD.LASTFIRST                       LASTFIRST,
    STUD.STUDENT_NUMBER,
    STUD.FIRST_NAME,
    STUD.MIDDLE_NAME,
    STUD.LAST_NAME,
    TO_CHAR(CYE.ENTRYDATE, 'MM/DD/YYYY') ENTRYDATE,
    TO_CHAR(CYE.EXITDATE, 'MM/DD/YYYY')  EXITDATE,
    CYE.EXITCODE,
    CYE.EXITCOMMENT,
    CYE.COHORT,
    CYE.SCHOOLID,
    CYE.SCHOOLNAME,
    CYE.ENROLLMENT
  FROM
    (
      SELECT
        STUD.*
      FROM
        STUD
    )   STUD
    JOIN CYE
    ON STUD.ID = CYE.STUDENTID UNION
    SELECT
      STUD.ID,
      STUD.LASTFIRST,
      STUD.STUDENT_NUMBER,
      STUD.FIRST_NAME,
      STUD.MIDDLE_NAME,
      STUD.LAST_NAME,
      TO_CHAR(PYE.ENTRYDATE, 'MM/DD/YYYY') ENTRYDATE,
      TO_CHAR(PYE.EXITDATE, 'MM/DD/YYYY')  EXITDATE,
      PYE.EXITCODE,
      PYE.EXITCOMMENT,
      PYE.COHORT,
      PYE.SCHOOLID,
      PYE.SCHOOLNAME,
      PYE.ENROLLMENT
    FROM
      (
        SELECT
          STUD.*
        FROM
          STUD
      )   STUD
      JOIN PYE
      ON STUD.ID = PYE.STUDENTID
)
SELECT
  ID             ID,
  LASTFIRST,
  STUDENT_NUMBER,
  FIRST_NAME,
  MIDDLE_NAME,
  LAST_NAME,
  ENTRYDATE,
  EXITDATE,
  EXITCODE,
  EXITCOMMENT,
  COHORT,
  SCHOOLID,
  SCHOOLNAME,
  ENROLLMENT
FROM
  (
    SELECT
      COMBINED.*
    FROM
      COMBINED
  ) COMBINED
ORDER BY
  STUDENT_NUMBER