

-- TESTING:

-- -- CASE 1 ------[] works (insert)
-- SET @s = '2021-07-10 10:30:00'; --  ne
-- SET @e = '2021-07-10 11:00:00'; -- exsist
-- -- -- CUSTOM RETURNS [] works (expected insert)
-- -- -- BETEEN RETURNS [1] fails (expected insert) -- id 1 = 2021-07-10 13:30:00	2021-07-10 14:00:00

-- -- CASE 2 []------ 
-- SET @s = '2021-07-10 14:00:00'; -- exsist
-- SET @e = '2021-07-10 14:30:00'; --  ne
-- -- CUSTOM RETURNS [] works (expected insert)
-- -- BETEEN RETURNS [4] fails (expected insert) -- id 4 = 2021-07-10 13:30:00	2021-07-10 14:00:00

-- -- CASE 3 --- [] --- works (no insert)
-- SET @s = '2021-07-9 11:45:00'; --  ne
-- SET @e = '2021-07-21 11:50:00'; --  ne
-- -- CUSTOM RETURNS [1,2,3,4] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

-- -- CASE 4 ---[]--- 
-- SET @s = '2021-07-10 11:00:00'; --  ne
-- SET @e = '2021-07-10 14:00:00'; --  ne
-- -- CUSTOM RETURNS [1,2,3,4] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

-- CASE 5  []------[]
SET @s = '2021-07-10 11:30:00'; -- exsist
SET @e = '2021-07-10 12:00:00'; -- exsist
-- CUSTOM RETURNS [] works (expected insert)
-- BETEEN RETURNS [1,2] fails (expected insert)

-- -- CASE 6 [ ---]----
-- SET @s = '2021-07-10 12:30:00'; -- exsist
-- SET @e = '2021-07-21 12:00:00'; -- ne
-- -- CUSTOM RETURNS [3,4] works (expected no insert)
-- -- BETEEN RETURNS [2,3,4] works (expected no insert)

-- -- CASE 7 ----[--- ]
-- SET @s = '2021-07-05 12:30:00'; -- ne
-- SET @e = '2021-07-10 13:30:00'; -- exsist
-- -- CUSTOM RETURNS [1,2,3] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

-- -- CASE 8 ----[---] (not insert)
-- SET @s = '2021-07-5 12:00:00'; -- ne
-- SET @e = '2021-07-10 14:00:00'; -- exsist
-- -- CUSTOM RETURNS [1,2,3,4] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)