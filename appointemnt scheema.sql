DROP DATABASE IF EXISTS bookings;
CREATE DATABASE bookings CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

USE bookings;

CREATE TABLE services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    length_in_min INT NOT NULL DEFAULT 20,
    capacity INT NOT NULL DEFAULT 1
);

INSERT INTO services (`name`, length_in_min, capacity) 
VALUES 
    ('ANY', 20, 1), -- allow any type appointment
    ('USG', 30, 1), -- allow only USG type appointments
    ('VISION', 10, 1)-- allow only VISION type appointments
;

SELECT * FROM services;

CREATE TABLE staff(
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(20) NOT NULL,
    `name` VARCHAR(30) NOT NULL,
    surname VARCHAR(60) NOT NULL,
    spec VARCHAR(60) NOT NULL,
    dob DATE NOT NULL,
    email VARCHAR(50) NOT NULL,
    phone VARCHAR(16) NOT NULL
);

INSERT INTO staff (title, `name`, surname, spec, dob, email, phone) 
VALUES
    ('dr', 'John', 'Lee', 'vet', '1988-01-01', 'somedr@email.com', '888 888 888')
;

SELECT * FROM staff;

CREATE TABLE locations(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(30) NOT NULL,
    room VARCHAR (20) DEFAULT NULL,
    address1 VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) NOT NULL,
    post VARCHAR(8) NOT NULL
);

INSERT INTO locations (`name`, address1, address2, post) 
VALUES
    ('Pet Clinick', 'Sezam Streen 17', 'London', '06-100')
;

SELECT * FROM locations;

CREATE TABLE dailyschedule(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `day` INT NOT NULL,
        CHECK(`day` BETWEEN 1 AND 7),
    location_id INT NOT NULL REFERENCES locations(id),
    `open` TIME NOT NULL,
    `close` TIME NOT NULL,
        CHECK(close > open),
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
        CHECK(modified_at >= created_at),
    starts_at DATETIME NOT NULL DEFAULT NOW(),
    ends_at DATETIME DEFAULT NULL,
        CHECK(ends_at >= starts_at)
);

INSERT INTO dailyschedule (location_id, `day`, `open`, `close`, starts_at) 
VALUES
    (
        (SELECT id FROM locations lo WHERE lo.name = 'Pet Clinick'), 
        1, 
        '10:00:00', 
        '18:00:00',
        '2021-01-01 00:00:00'
    ), -- query others the same way
    (1, 2, '10:00:00', '18:00:00', '2021-01-01 00:00:00'),
    (1, 3, '10:00:00', '18:00:00', '2021-01-01 00:00:00'),
    (1, 4, '10:00:00', '18:00:00', '2021-01-01 00:00:00'),
    (1, 5, '10:00:00', '18:00:00', '2021-01-01 00:00:00'),
    (1, 6, '08:30:00', '16:00:00', '2021-01-01 00:00:00'),
    (1, 7, '08:30:00', '16:00:00', '2021-01-01 00:00:00')
;

SELECT sc.id, sc.day, sc.open, sc.close, sc.starts_at, sc.ends_at FROM dailyschedule sc;

CREATE TABLE dailyschedule_services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id INT NOT NULL REFERENCES staff(id),
    service_id INT NOT NULL REFERENCES services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    dailyschedule_id INT NOT NULL REFERENCES dailyschedule(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    starts_at TIME NOT NULL,
    ends_at TIME NOT NULL
        CHECK(ends_at >= starts_at),
    limit_per_schedule INT NOT NULL DEFAULT 999,
    price DECIMAL(10,2) NOT NULL,
    allow_online_booking BOOLEAN DEFAULT 1
);

INSERT INTO dailyschedule_services (staff_id, service_id, dailyschedule_id, starts_at, ends_at, price, limit_per_schedule)
VALUES
    (
        (SELECT id FROM staff st WHERE st.name = 'John' AND st.surname = 'Lee' AND spec = 'vet'),
        (SELECT id FROM services s WHERE s.name = 'USG'),
        (SELECT id FROM dailyschedule s WHERE s.day = 1),
        '12:00:00',
        '12:30:00',
        60.00,
        10
    ), -- query others the same way
    (1, 2, 2,'13:00:00', '13:30:00', 60.00, 10),
    (1, 1, 6,'12:30:00', '13:30:00', 80.00, 10)
;

CREATE TABLE clients(
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(30) NOT NULL,
    email VARCHAR(60) NOT NULL UNIQUE,
    phone VARCHAR(16) NOT NULL,
    legals BOOLEAN DEFAULT TRUE
);

INSERT INTO clients (`name`, email, phone) 
VALUES  
    ('Wiktor', 'some@email.com', '000 000 000'),
    ('John', 'john@email.com', '111 111 111')
;

SELECT * FROM clients;

CREATE TABLE appointments(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL REFERENCES services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    client_id INT NOT NULL REFERENCES clients(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- schedule_id ? Schedule id ?
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
        CHECK(modified_at >= created_at),
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    approved_by_client BOOLEAN NOT NULL DEFAULT FALSE
    -- UNIQUE KEY make_booking_unique (starts_at, ends_at)
);

CREATE TABLE notifications(
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointments_id INT NOT NULL REFERENCES appointments(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    sent_at TIMESTAMP DEFAULT NOW(),
    types ENUM('sms','email','phone', 'verbal'),
    notification_text VARCHAR(255) DEFAULT NULL
);

INSERT INTO appointments (client_id, service_id, starts_at, ends_at) 
VALUES 
    (   
        (SELECT id FROM clients WHERE email = 'some@email.com'), 
        (SELECT id FROM services WHERE name = 'USG'),
        '2021-07-10 11:00:00', 
        '2021-07-10 11:30:00'
    ), -- query others the same way
    (1, 2, '2021-07-10 12:00:00', '2021-07-10 12:30:00'), -- 2 is USG name
    (1, 2, '2021-07-10 13:00:00', '2021-07-10 13:30:00'), -- 2 is USG name
    (1, 1, '2021-07-10 13:30:00', '2021-07-10 14:00:00') -- 1 is any name
;

SET @s := '2021-07-10 12:30:00';
SET @e := '2021-07-10 13:00:00';

-- SELECT( WEEKDAY(@s));
-- SELECT(TIME(@s));
-- SELECT * FROM dailyschedule sc LEFT JOIN dailyschedule_services ss ON ss.dailyschedule_id = sc.id;

-- SELECT ss.id, sc.day FROM dailyschedule sc LEFT JOIN dailyschedule_services ss ON ss.dailyschedule_id = sc.id
--             WHERE 
--                 WEEKDAY(@s) + 1 = sc.day
--                 AND TIME(@s) = ss.starts_at
--                 AND TIME(@e) = ss.ends_at;

INSERT INTO appointments
        (client_id, service_id, starts_at, ends_at) 
    SELECT 
        (SELECT id FROM clients c WHERE c.email = 'some@email.com'),
        (SELECT id FROM services s WHERE s.name = 'ANY'),
        @s, 
        @e
    WHERE 
	 	EXISTS -- see if this timeslot is defined and available for booking in dailyschedule_services table
        (
            SELECT ss.id, sc.day FROM dailyschedule sc LEFT JOIN dailyschedule_services ss ON ss.dailyschedule_id = sc.id
            WHERE 
                (service_id = (SELECT id FROM services s WHERE s.name = 'USG') OR service_id = (SELECT id FROM services s WHERE s.name = 'ANY'))
                AND WEEKDAY(@s) + 1 = sc.day
            	AND @s >= sc.starts_at
                AND TIME(@s) = ss.starts_at 
                AND TIME(@e) = ss.ends_at
        )
    AND 
	 	NOT EXISTS -- check if already booked or if there are any colisions with other booking. If there is colision found, colision booking is returned and no insert will be run
        (
            SELECT id FROM appointments
            WHERE 
                (starts_at <= @s AND @s < ends_at)
                OR (starts_at < @e AND @e <= ends_at)
                OR (@s <= starts_at AND starts_at < @e)
            LIMIT 1 
        )
    AND 
	 	(1=1) -- CHECK FOR HOLIDAYS AND OFF DAYS
;

SELECT * FROM dailyschedule_services ss 
    LEFT JOIN dailyschedule s 
        ON ss.dailyschedule_id = s.id;

SELECT a.id, c.name, s.name, a.starts_at, a.ends_at 
    FROM appointments a 
    LEFT JOIN services s 
        ON a.service_id = s.id 
    LEFT JOIN clients c 
        ON a.client_id = c.id;