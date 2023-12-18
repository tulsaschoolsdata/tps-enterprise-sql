SELECT
  DISTINCT STUDENTTEST.TEST_DATE,
  STUDENTS.ID,
  STUDENTS.STUDENT_NUMBER,
  STUDENTS.LASTFIRST,
  STUDENTS.DCID,
  S_OK_STU_X.GIFTED,
  CASE
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'Composite(VQ) S Age Score' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified by CogAT Abilities'
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'Composite(VN) S Age Score' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified  by CogAT Abilities'
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'Composite(QN) S Age Score' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified by CogAT Abilities'
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'Composite(VQN) S Age Score' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified by  CogAT Abilities'
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'OTIS_SEM_ADJUST_ABILITY_INDEX' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified  OLSAT (Otis-Lennon)'
    WHEN REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                        || 'a-zA-Z0-9'
                                        || CHR(93)) = 'NAGLIERI_SEM_ADJUST_ABILITY_INDEX' AND STUDENTTESTSCORE.NUMSCORE > 119 THEN
      'Certified  by NNAT3 (Naglieri)'
  END                                                   CERTIFIED_BY,
  STUDENTTEST.DCID                                      AS TEST_KEY,
  STUDENTTEST.GRADE_LEVEL,
  STUDENTTEST.ID                                        AS STUDENT_TEST_ID,
  TEST.NAME                                             AS TEST_NAME,
  TESTSCORE.ID                                          AS SUBTEST_ID,
  LOWER(REGEXP_REPLACE(TESTSCORE.NAME, CHR(94)
                                       || 'a-zA-Z0-9'
                                       || CHR(93), '')) AS SUBTEST_KEY,
  TESTSCORE.NAME                                        AS SUBTEST_NAME,
  STUDENTTESTSCORE.NUMSCORE,
  STUDENTTESTSCORE.PERCENTSCORE,
  STUDENTTESTSCORE.ALPHASCORE
FROM
  STUDENTS
  INNER JOIN STUDENTTEST
  ON STUDENTS.ID = STUDENTTEST.STUDENTID
  JOIN S_OK_STU_X
  ON STUDENTS.DCID = S_OK_STU_X.STUDENTSDCID INNER JOIN TEST
  ON TEST.ID = STUDENTTEST.TESTID
  INNER JOIN STUDENTTESTSCORE
  ON STUDENTS.ID = STUDENTTESTSCORE.STUDENTTESTID
  INNER JOIN TESTSCORE
  ON TESTSCORE.ID = STUDENTTESTSCORE.TESTSCOREID
WHERE
  UPPER(S_OK_STU_X.GIFTED) = 'YES'
  AND (TEST.NAME = 'NAGL'
  OR TEST.NAME = 'OTIS'
  OR TEST.NAME = 'COGAT')
  AND (TESTSCORE.NAME = 'NAGLIERI_SEM_ADJUST_ABILITY_INDEX'
  OR TESTSCORE.NAME = 'OTIS_SEM_ADJUST_ABILITY_INDEX'
  OR TESTSCORE.NAME = 'Composite(VQ) S Age Score'
  OR TESTSCORE.NAME = 'Composite(VN) S Age Score'
  OR TESTSCORE.NAME = 'Composite(QN) S Age Score'
  OR TESTSCORE.NAME = 'Composite(VQN) S Age Score')
  AND STUDENTS.SCHOOLID != '999999'
ORDER BY
  STUDENTS.STUDENT_NUMBER,
  STUDENTTEST.TEST_DATE