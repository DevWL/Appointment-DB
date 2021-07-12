CREATE TABLE Services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    length_in_min INT NOT NULL DEFAULT 20,
    capacity INT NOT NULL DEFAULT 1
);

INSERT INTO Services (name, length_in_min, capacity) 
VALUES 
    ('ANY', 20, 1), -- allow any type appointment
    ('USG', 30, 1), -- allow only USG type appointments
    ('VISION', 10, 1)-- allow only VISION type appointments
;

SELECT * FROM Services;

CREATE TABLE Staff(
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    spec VARCHAR(255) NOT NULL,
    dob YEAR NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL
);

INSERT INTO Staff (title, name, surname, spec, dob, email, phone) 
VALUES
    ('dr', 'John', 'Lee', 'vet', '1988-01-01', 'somedr@email.com', '888 888 888');

SELECT * FROM Staff;

CREATE TABLE Locations(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    room VARCHAR (255) DEFAULT NULL,
    address1 VARCHAR(255) NOT NULL,
    address2 VARCHAR(255) NOT NULL,
    post VARCHAR(6) NOT NULL
);

INSERT INTO Locations (name, address1, address2, post) 
VALUES
    ('Pet Clinick', 'Sezam Streen 17', 'London', '06-100');

SELECT * FROM Locations;

CREATE TABLE Schedules(
    id INT AUTO_INCREMENT PRIMARY KEY,
    day INT NOT NULL,
        CHECK(day BETWEEN 1 AND 7),
    location_id INT NOT NULL REFERENCES Locations(id),
    staff_id INT NOT NULL REFERENCES Staff(id),
    open TIME NOT NULL,
    close TIME NOT NULL,
        CHECK(close > open),
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
        CHECK(modified_at >= created_at),
    starts_at DATETIME NOT NULL DEFAULT NOW(),
    ends_at DATETIME NOT NULL DEFAULT '9999-01-01 00:00:00', 
        CHECK(ends_at >= starts_at)
);

INSERT INTO Schedules (staff_id, location_id, day, open, close) 
VALUES
    (
        (SELECT id FROM Staff st WHERE st.name = 'John' AND st.surname = 'Lee' AND spec = 'vet'),
        (SELECT id FROM Locations l WHERE l.name = '' and l.room = 'Main'), 
        1, 
        '10:00:00', 
        '18:00:00'
    ), -- query others the same way
    (1, 1, 2, '10:00:00', '18:00:00'),
    (1, 1, 3, '10:00:00', '18:00:00'),
    (1, 1, 4, '10:00:00', '18:00:00'),
    (1, 1, 5, '10:00:00', '18:00:00'),
    (1, 1, 6, '08:30:00', '16:00:00'),
    (1, 1, 7, '08:30:00', '16:00:00')
;

SELECT id as schedule_id, day, open, close, starts_at, ends_at FROM Schedules;

CREATE TABLE Schedules_Service(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL REFERENCES Services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    schedules_id INT NOT NULL REFERENCES Schedules(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    limit_per_schedule INT NOT NULL DEFAULT 999,
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO Schedules_Service (service_id, schedules_id, price, limit_per_schedule)
VALUES
    (
        (SELECT id FROM Services WHERE name = 'ANY'),
        (SELECT id FROM Schedules WHERE id = 1),
        60.00,
        10
    ), -- query others the same way
    (2, 1, 60.00, 10)
;

CREATE TABLE Clients(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(255) NOT NULL,
    legals BOOLEAN DEFAULT TRUE
);

INSERT INTO Clients (name, email, phone) 
VALUES  
    ('Wiktor', 'some@email.com', '000 000 000'),
    ('John', 'john@email.com', '111 111 111')
;

SELECT * FROM Clients;

CREATE TABLE Appointments(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL REFERENCES Services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    client_id INT NOT NULL REFERENCES Clients(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- schedule_id ? Schedule id ?
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW(),
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    approved_by_client BOOLEAN NOT NULL DEFAULT FALSE
    -- UNIQUE KEY make_booking_unique (starts_at, ends_at)
);

INSERT INTO Appointments (client_id, service_id, starts_at, ends_at) 
VALUES 
    (   
        (SELECT id FROM Clients WHERE email = 'some@email.com'), 
        (SELECT id FROM Services WHERE name = 'USG'), 
        '2021-07-10 11:00:00', 
        '2021-07-10 11:30:00'
    ), -- query others the same way
    (1, 2, '2021-07-10 12:00:00', '2021-07-10 12:30:00'), -- 2 is USG name
    (1, 2, '2021-07-10 13:00:00', '2021-07-10 13:30:00'), -- 2 is USG name
    (1, 1, '2021-07-10 13:30:00', '2021-07-10 14:00:00') -- 1 is any name
;

SELECT id, starts_at, ends_at  FROM Appointments ORDER BY starts_at;