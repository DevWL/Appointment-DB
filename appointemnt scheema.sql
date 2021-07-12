-- TABLE Services --
CREATE TABLE Services(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service VARCHAR(255) NOT NULL,
    length_in_min INT NOT NULL DEFAULT 20,
    capacity INT NOT NULL DEFAULT 1
);

INSERT INTO Services (service, length_in_min, capacity) 
VALUES 
    ('ANY', 20, 1), -- if ANY allow for all service apointments
    ('USG', 30, 1), -- if USG allow aonly USG apointments
    ('VISION', 10, 1); -- if VISION allow aonly VISION apointments

SELECT * FROM Services;

-- TABLE Staff --
CREATE TABLE Staff(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL
);

INSERT INTO Staff (name, email, phone) 
VALUES
    ("dr Lee", "somedr@email.com", "888 888 888");

SELECT * FROM Staff;

-- TABLE Locations --
CREATE TABLE Locations(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    room VARCHAR (255) DEFAULT 'Main',
    address1 VARCHAR(255) NOT NULL,
    address2 VARCHAR(255) NOT NULL,
    post VARCHAR(6) NOT NULL
);

INSERT INTO Locations (name, address1, address2, post) 
VALUES
    ("Pet Clinick", "Sezam Streen 17", "London", "06-100");

SELECT * FROM Locations;

-- TABLE Schedules --
CREATE TABLE Schedules(
    id INT AUTO_INCREMENT PRIMARY KEY,
    day INT NOT NULL,
        CONSTRAINT chk_if_days_in_range CHECK(day BETWEEN 1 AND 7),
    location_id INT NOT NULL REFERENCES Locations(id),
    staff_id INT NOT NULL REFERENCES Staff(id),
    open TIME NOT NULL,
    close TIME NOT NULL,
        CONSTRAINT chk_open_close_order CHECK(close > open),
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW(),
        CONSTRAINT chk_edit_timestamp_order CHECK(modified_at >= created_at),
    starts_at DATETIME NOT NULL DEFAULT NOW(),
    ends_at DATETIME NOT NULL DEFAULT '9999-01-01 00:00:00', 
        CONSTRAINT chk_booking_datetime_order CHECK(ends_at >= starts_at)
);

INSERT INTO Schedules (staff_id, location_id, day, open, close) 
VALUES
    (1, 1, 1, '10:00:00', '18:00:00'),
    (1, 1, 3, '08:30:00', '16:00:00'),
    (1, 1, 4, '08:30:00', '16:00:00')
;

SELECT id as shedule_id, day, open, close, starts_at, ends_at FROM Schedules;

-- TABLE Schedules_Service --
CREATE TABLE Schedules_Service(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL REFERENCES Services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    schedules_id INT NOT NULL REFERENCES Schedules(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    limit_per_shedule INT NOT NULL DEFAULT 999,
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO Schedules_Service (service_id, schedules_id, price, limit_per_shedule)
VALUES
    (1, 1, 60.00, 10),
    (2, 1, 60.00, 10)
;

-- TABLE Clients --
CREATE TABLE Clients(
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    legals BOOLEAN DEFAULT TRUE
);

INSERT INTO Clients (name, email, phone) 
VALUES  
    ("Wiktor", "some@email.com", "000 000 000"),
    ("John", "john@email.com", "111 111 111")
;

SELECT * FROM Clients;

-- TABLE Appointments --
CREATE TABLE Appointments(
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_id INT NOT NULL REFERENCES Services(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    client_id INT NOT NULL REFERENCES Clients(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    -- shedule_id ? Schedule id ?
    created_at TIMESTAMP DEFAULT NOW(),
    modified_at TIMESTAMP DEFAULT NOW(),
    starts_at DATETIME NOT NULL,
    ends_at DATETIME NOT NULL,
    approved_by_client BOOLEAN NOT NULL DEFAULT FALSE
    -- UNIQUE KEY make_booking_unique (starts_at, ends_at)
);

INSERT INTO Appointments (client_id, service_id, starts_at, ends_at) 
VALUES 
    (1, 2, '2021-07-10 11:00:00', '2021-07-10 11:30:00'), -- 2 is USG service
    (1, 2, '2021-07-10 12:00:00', '2021-07-10 12:30:00'), -- 2 is USG service
    (1, 2, '2021-07-10 13:00:00', '2021-07-10 13:30:00'), -- 2 is USG service
    (1, 1, '2021-07-10 13:30:00', '2021-07-10 14:00:00') -- 1 is any service
;

SELECT id, starts_at, ends_at  FROM Appointments ORDER BY starts_at;