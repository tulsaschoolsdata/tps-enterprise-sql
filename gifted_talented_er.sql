SELECT
  S.ID,
  S.STUDENT_NUMBER,
  S.LASTFIRST,
  S.DCID,
  SX.GIFTED,
  CASE
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'Composite(VQ) S Age Score' AND STS.NUMSCORE > 1 THEN
      'Certified by CogAT Abilities'
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'Composite(VN) S Age Score' AND STS.NUMSCORE > 1 THEN
      'Certified  by CogAT Abilities'
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'Composite(QN) S Age Score' AND STS.NUMSCORE > 1 THEN
      'Certified by CogAT Abilities'
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'Composite(VQN) S Age Score' AND STS.NUMSCORE > 1 THEN
      'Certified by  CogAT Abilities'
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'OTIS_SEM_ADJUST_ABILITY_INDEX' AND STS.NUMSCORE > 1 THEN
      'Certified  OLSAT (Otis-Lennon)'
    WHEN REGEXP_REPLACE(TS.NAME, CHR(94)
                                 || 'a-zA-Z0-9'
                                 || CHR(93)) = 'NAGLIERI_SEM_ADJUST_ABILITY_INDEX' AND STS.NUMSCORE > 1 THEN
      'Certified  by NNAT3 (Naglieri)'
  END                                            CERTIFIED_BY,
  ST.TEST_DATE,
  ST.DCID                                        AS TEST_KEY,
  ST.GRADE_LEVEL,
  ST.ID                                          AS STUDENT_TEST_ID,
  T.NAME                                         AS TEST_NAME,
  TS.ID                                          AS SUBTEST_ID,
  LOWER(REGEXP_REPLACE(TS.NAME, CHR(94)
                                || 'a-zA-Z0-9'
                                || CHR(93), '')) AS SUBTEST_KEY,
  TS.NAME                                        AS SUBTEST_NAME,
  STS.NUMSCORE,
  STS.PERCENTSCORE,
  STS.ALPHASCORE
FROM
  STUDENTS         S
  INNER JOIN STUDENTTEST ST
  ON S.ID = ST.STUDENTID
  JOIN S_OK_STU_X SX
  ON S.DCID = SX.STUDENTSDCID INNER JOIN TEST T
  ON T.ID = ST.TESTID
  INNER JOIN STUDENTTESTSCORE STS
  ON ST.ID = STS.STUDENTTESTID
  INNER JOIN TESTSCORE TS
  ON TS.ID = STS.TESTSCOREID
WHERE
  ST.STUDENTID = 230671
  AND (REGEXP_REPLACE(TS.NAME, CHR(94)
                               || 'a-zA-Z0-9'
                               || CHR(93)) = 'Composite(VQ) S Age Score'
  OR REGEXP_REPLACE(TS.NAME, CHR(94)
                             || 'a-zA-Z0-9'
                             || CHR(93)) = 'Composite(VN) S Age Score'
  OR REGEXP_REPLACE(TS.NAME, CHR(94)
                             || 'a-zA-Z0-9'
                             || CHR(93)) = 'Composite(QN) S Age Score'
  OR REGEXP_REPLACE(TS.NAME, CHR(94)
                             || 'a-zA-Z0-9'
                             || CHR(93)) = 'Composite(VQN) S Age Score'
  OR REGEXP_REPLACE(TS.NAME, CHR(94)
                             || 'a-zA-Z0-9'
                             || CHR(93)) = 'OTIS_SEM_ADJUST_ABILITY_INDEX'
  OR REGEXP_REPLACE(TS.NAME, CHR(94)
                             || 'a-zA-Z0-9'
                             || CHR(93)) = 'NAGLIERI_SEM_ADJUST_ABILITY_INDEX')
ORDER BY
  ST.TEST_DATE