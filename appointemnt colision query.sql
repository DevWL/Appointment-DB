

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

-- -- CASE 2 ---[]--- 
-- SET @s = '2021-07-10 11:00:00'; --  ne
-- SET @e = '2021-07-10 14:00:00'; --  ne
-- -- CUSTOM RETURNS [1,2,3,4] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

-- CASE 4  []------[]
SET @s = '2021-07-10 11:30:00'; -- exsist
SET @e = '2021-07-10 12:00:00'; -- exsist
-- CUSTOM RETURNS [] works (expected insert)
-- BETEEN RETURNS [1,2] fails (expected insert)

-- -- CASE 6 [ ---]----
-- SET @s = '2021-07-10 12:30:00'; -- exsist
-- SET @e = '2021-07-21 12:00:00'; -- ne
-- -- CUSTOM RETURNS [3,4] works (expected no insert)
-- -- BETEEN RETURNS [2,3,4] works (expected no insert)

-- -- CASE 6 ----[--- ]
-- SET @s = '2021-07-05 12:30:00'; -- ne
-- SET @e = '2021-07-10 13:30:00'; -- exsist
-- -- CUSTOM RETURNS [1,2,3] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

-- -- CASE 7 ----[---] (not insert)
-- SET @s = '2021-07-5 12:00:00'; -- ne
-- SET @e = '2021-07-10 14:00:00'; -- exsist
-- -- CUSTOM RETURNS [1,2,3,4] works (expected no insert)
-- -- BETEEN RETURNS [1,2,3,4] works (expected no insert)

SELECT '' AS '';
SELECT @s AS 'start date',  @e as 'end date';

SELECT 'appointments table - before insert:' AS ' ';
SELECT a.id, c.name, c.phone, s.name, a.starts_at, a.ends_at 
FROM appointments a 
LEFT JOIN
    Clients c ON a.client_id = c.id
LEFT JOIN 
    Services s ON a.service_id = s.id
ORDER BY a.starts_at;

-- -- This will detect collisions as expected
-- SELECT '--- CUSTOM ---' as '';
-- SELECT id FROM appointments
--     WHERE 
--         ((starts_at <= @s AND @s < ends_at)
--         OR (starts_at < @e AND @e <= ends_at)
--         OR (@s <= starts_at AND starts_at < @e))
--         AND (1 = 1) -- replace withother mandatory conditions 
-- ;        

-- -- This will return unexpected collision results
-- SELECT '--- BETWEEN ---' as '';
-- SELECT id FROM appointments
--     WHERE 
--         ((@s BETWEEN starts_at AND ends_at
--         OR @e BETWEEN starts_at AND ends_at
--         OR starts_at BETWEEN @s AND @e))
--         AND (1 = 1) -- replace withother mandatory conditions 
--         LIMIT 1  -- micro optimisation
-- ;

-- INSERT INTO appointments (client_id, service_id, starts_at, ends_at) 
-- VALUES 
--     (   
--         (SELECT id FROM clients WHERE email = 'some@email.com'), 
--         (SELECT id FROM services WHERE name = 'USG'), 
--         '2021-07-10 11:00:00', 
--         '2021-07-10 11:30:00'
--     ), -- query others the same way
--     (1, 2, '2021-07-10 12:00:00', '2021-07-10 12:30:00'), -- 2 is USG name
--     (1, 2, '2021-07-10 13:00:00', '2021-07-10 13:30:00'), -- 2 is USG name
--     (1, 1, '2021-07-10 13:30:00', '2021-07-10 14:00:00') -- 1 is any name
-- ;

SELECT ' ' AS '';
-- INSERT NEW APPOINTMENT IF NOT IN COLISION WITH CURRENT APPOINTMENTS
-- curently it does not check for apoitment type allowed in shedule, working days and holidays

INSERT INTO appointments
        (client_id, service_id, starts_at, ends_at) 
    SELECT 2, 2, @s, @e -- John, USG, ...
    WHERE NOT EXISTS -- search for colisions if there is colision row returned no insert will be run
        (SELECT id FROM appointments
        WHERE 
        (starts_at <= @s AND @s < ends_at)
        OR (starts_at < @e AND @e <= ends_at)
        OR (@s <= starts_at AND starts_at < @e)
        LIMIT 1 
        )
    AND EXISTS (SELECT id FROM Schedule WHERE WEEKDAY(@s) + 1 = day and @s >= starts_at and @e <= ends_at)
    LIMIT 1 -- micro optimisation
;

-- WHERE ESISTS ( SELECT id FROM appointments WHERE (starts_at >= @e AND starts_at > @s AND ends_at > @s AND ends_at > @e)

SELECT 'appointments table - after insert:' AS ' ';
SELECT a.id, c.name, c.phone, s.name, a.starts_at, a.ends_at 
FROM appointments a 
LEFT JOIN
    Clients c ON a.client_id = c.id
LEFT JOIN 
    Services s ON a.service_id = s.id
ORDER BY a.starts_at;
