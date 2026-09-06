-- ============================================
-- PRISON MANAGEMENT SYSTEM - ACCESS DATABASE
-- Complete SQL Script with Data and Relationships
-- ============================================

-- Drop existing tables if they exist
DROP TABLE EmergencyBackup;
DROP TABLE Visits;
DROP TABLE PrisonerCrime;
DROP TABLE Emergencies;
DROP TABLE Visitors;
DROP TABLE Prisoners;
DROP TABLE Guards;
DROP TABLE Staff;
DROP TABLE BackupForces;
DROP TABLE Kitchen;
DROP TABLE Crime;
DROP TABLE Cell;
DROP TABLE Users;

-- ============================================
-- CREATE TABLES
-- ============================================

-- Cell Table
CREATE TABLE Cell (
    CellID AUTOINCREMENT PRIMARY KEY,
    BlockName TEXT(50) NOT NULL,
    Capacity INTEGER NOT NULL,
    Occupied INTEGER DEFAULT 0
);

-- Crime Table
CREATE TABLE Crime (
    CrimeID AUTOINCREMENT PRIMARY KEY,
    CrimeName TEXT(100) NOT NULL,
    SeverityLevel TEXT(20) CHECK (SeverityLevel IN ('Low', 'Medium', 'High', 'Critical'))
);

-- Kitchen Table
CREATE TABLE Kitchen (
    RestaurantID AUTOINCREMENT PRIMARY KEY,
    RestaurantName TEXT(100) NOT NULL,
    Capacity INTEGER
);

-- BackupForces Table
CREATE TABLE BackupForces (
    BackupID AUTOINCREMENT PRIMARY KEY,
    FullName TEXT(100) NOT NULL,
    Rank TEXT(50),
    Phone TEXT(20),
    ShiftTime TEXT(50)
);

-- Staff Table
CREATE TABLE Staff (
    StaffID AUTOINCREMENT PRIMARY KEY,
    FullName TEXT(100) NOT NULL,
    JobType TEXT(50),
    Phone TEXT(20),
    ShiftTime TEXT(50),
    RestaurantID INTEGER,
    CONSTRAINT FK_Staff_Kitchen FOREIGN KEY (RestaurantID) REFERENCES Kitchen(RestaurantID)
);

-- Guards Table
CREATE TABLE Guards (
    GuardID AUTOINCREMENT PRIMARY KEY,
    FullName TEXT(100) NOT NULL,
    Phone TEXT(20),
    ShiftTime TEXT(50),
    CellID INTEGER,
    CONSTRAINT FK_Guards_Cell FOREIGN KEY (CellID) REFERENCES Cell(CellID)
);

-- Prisoners Table
CREATE TABLE Prisoners (
    PrisonerID AUTOINCREMENT PRIMARY KEY,
    FullName TEXT(100) NOT NULL,
    Age INTEGER,
    Gender TEXT(10),
    SentenceYears INTEGER,
    AdmissionDate DATETIME,
    ReleaseDate DATETIME,
    CellID INTEGER,
    Status TEXT(20) DEFAULT 'Active',
    CONSTRAINT FK_Prisoners_Cell FOREIGN KEY (CellID) REFERENCES Cell(CellID)
);

-- Visitors Table
CREATE TABLE Visitors (
    VisitorID AUTOINCREMENT PRIMARY KEY,
    FullName TEXT(100) NOT NULL,
    RelationToPrisoner TEXT(50),
    Phone TEXT(20)
);

-- Emergencies Table
CREATE TABLE Emergencies (
    EmergencyID AUTOINCREMENT PRIMARY KEY,
    EmergencyType TEXT(50) NOT NULL,
    EmergencyDate DATETIME DEFAULT Now(),
    Location TEXT(100),
    Description MEMO,
    CellID INTEGER,
    CONSTRAINT FK_Emergencies_Cell FOREIGN KEY (CellID) REFERENCES Cell(CellID)
);

-- PrisonerCrime Junction Table
CREATE TABLE PrisonerCrime (
    PrisonerCrimeID AUTOINCREMENT PRIMARY KEY,
    PrisonerID INTEGER NOT NULL,
    CrimeID INTEGER NOT NULL,
    CrimeDate DATETIME,
    CONSTRAINT FK_PrisonerCrime_Prisoner FOREIGN KEY (PrisonerID) REFERENCES Prisoners(PrisonerID),
    CONSTRAINT FK_PrisonerCrime_Crime FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

-- Visits Table
CREATE TABLE Visits (
    VisitID AUTOINCREMENT PRIMARY KEY,
    PrisonerID INTEGER NOT NULL,
    VisitorID INTEGER NOT NULL,
    VisitDate DATETIME DEFAULT Now(),
    CONSTRAINT FK_Visits_Prisoner FOREIGN KEY (PrisonerID) REFERENCES Prisoners(PrisonerID),
    CONSTRAINT FK_Visits_Visitor FOREIGN KEY (VisitorID) REFERENCES Visitors(VisitorID)
);

-- EmergencyBackup Junction Table
CREATE TABLE EmergencyBackup (
    EmergencyBackupID AUTOINCREMENT PRIMARY KEY,
    EmergencyID INTEGER NOT NULL,
    BackupID INTEGER NOT NULL,
    CONSTRAINT FK_EmergencyBackup_Emergency FOREIGN KEY (EmergencyID) REFERENCES Emergencies(EmergencyID),
    CONSTRAINT FK_EmergencyBackup_Backup FOREIGN KEY (BackupID) REFERENCES BackupForces(BackupID)
);

-- Users Table (for authentication)
CREATE TABLE Users (
    UserID AUTOINCREMENT PRIMARY KEY,
    Username TEXT(50) NOT NULL UNIQUE,
    Password TEXT(100) NOT NULL,
    Role TEXT(20) CHECK (Role IN ('Admin', 'Staff', 'Guard')),
    StaffID INTEGER,
    GuardID INTEGER,
    CONSTRAINT FK_Users_Staff FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CONSTRAINT FK_Users_Guard FOREIGN KEY (GuardID) REFERENCES Guards(GuardID)
);

-- ============================================
-- INSERT DATA
-- ============================================

-- Insert Cells
INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block A', 4, 3);
INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block B', 4, 4);
INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block C', 6, 5);
INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block D', 4, 2);
INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Isolation Wing', 2, 1);

-- Insert Crimes
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Theft', 'Low');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Assault', 'Medium');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Armed Robbery', 'High');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Murder', 'Critical');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Drug Trafficking', 'High');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Fraud', 'Medium');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Kidnapping', 'Critical');
INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Burglary', 'Medium');

-- Insert Kitchens
INSERT INTO Kitchen (RestaurantName, Capacity) VALUES ('Main Cafeteria', 500);
INSERT INTO Kitchen (RestaurantName, Capacity) VALUES ('Staff Dining', 50);

-- Insert Staff
INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Sarah Johnson', 'Cook', '555-0101', 'Day Shift', 1);
INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Mike Chen', 'Chef', '555-0102', 'Day Shift', 1);
INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Emily Davis', 'Nutritionist', '555-0103', 'Day Shift', 1);
INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Tom Wilson', 'Kitchen Manager', '555-0104', 'Day Shift', 2);

-- Insert Guards
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('John Martinez', '555-0201', 'Night Shift', 1);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Lisa Anderson', '555-0202', 'Day Shift', 1);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('David Brown', '555-0203', 'Evening Shift', 2);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Maria Garcia', '555-0204', 'Day Shift', 3);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Robert Taylor', '555-0205', 'Night Shift', 3);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Jennifer Lee', '555-0206', 'Day Shift', 4);
INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('James White', '555-0207', 'Evening Shift', 5);

-- Insert Prisoners
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Michael Smith', 34, 'Male', 10, #03/15/2020#, #03/15/2030#, 1, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Carlos Rodriguez', 28, 'Male', 5, #06/20/2022#, #06/20/2027#, 1, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Ahmed Hassan', 41, 'Male', 25, #01/10/2018#, #01/10/2043#, 1, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Daniel Kim', 30, 'Male', 8, #09/05/2021#, #09/05/2029#, 2, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Marcus Johnson', 26, 'Male', 3, #02/14/2023#, #02/14/2026#, 2, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Luis Fernandez', 38, 'Male', 15, #11/22/2019#, #11/22/2034#, 2, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Ryan Thompson', 29, 'Male', 6, #04/18/2022#, #04/18/2028#, 2, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Anthony Davis', 45, 'Male', 20, #07/30/2017#, #07/30/2037#, 3, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Victor Martinez', 33, 'Male', 12, #10/12/2020#, #10/12/2032#, 3, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Jason Lee', 27, 'Male', 4, #05/25/2023#, #05/25/2027#, 3, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Kevin Brown', 36, 'Male', 9, #12/08/2021#, #12/08/2030#, 3, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Omar Ali', 31, 'Male', 7, #08/16/2022#, #08/16/2029#, 3, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Christopher White', 42, 'Male', 18, #03/22/2018#, #03/22/2036#, 4, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Brandon Garcia', 25, 'Male', 2, #01/10/2024#, #01/10/2026#, 4, 'Active');
INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) 
VALUES ('Samuel Wilson', 39, 'Male', 14, #06/14/2019#, #06/14/2033#, 5, 'Active');

-- Insert PrisonerCrime associations
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (1, 3, #03/10/2020#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (2, 2, #06/15/2022#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (3, 4, #01/05/2018#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (4, 5, #09/01/2021#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (5, 1, #02/10/2023#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (6, 7, #11/18/2019#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (7, 6, #04/12/2022#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (8, 4, #07/25/2017#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (9, 3, #10/08/2020#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (10, 2, #05/20/2023#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (11, 5, #12/01/2021#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (12, 8, #08/10/2022#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (13, 4, #03/15/2018#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (14, 1, #01/05/2024#);
INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (15, 7, #06/10/2019#);

-- Insert Backup Forces
INSERT INTO BackupForces (FullName, Rank, Phone, ShiftTime) VALUES ('Captain Richards', 'Captain', '555-0301', 'On-Call');
INSERT INTO BackupForces (FullName, Rank, Phone, ShiftTime) VALUES ('Lieutenant Foster', 'Lieutenant', '555-0302', 'On-Call');
INSERT INTO BackupForces (FullName, Rank, Phone, ShiftTime) VALUES ('Sergeant Murphy', 'Sergeant', '555-0303', 'Day Shift');
INSERT INTO BackupForces (FullName, Rank, Phone, ShiftTime) VALUES ('Officer Palmer', 'Officer', '555-0304', 'Night Shift');

-- Insert Emergencies
INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, Description, CellID) 
VALUES ('Fight', #01/15/2024 14:30:00#, 'Cafeteria', 'Altercation between two inmates', NULL);
INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, Description, CellID) 
VALUES ('Medical', #01/18/2024 09:15:00#, 'Block C', 'Inmate collapsed, ambulance called', 3);
INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, Description, CellID) 
VALUES ('Fire Alarm', #01/20/2024 22:45:00#, 'Kitchen', 'Smoke detected in kitchen area', NULL);
INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, Description, CellID) 
VALUES ('Lockdown', #01/22/2024 16:00:00#, 'Block A', 'Suspicious activity reported', 1);

-- Insert EmergencyBackup associations
INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (1, 3);
INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (2, 1);
INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (3, 2);
INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (4, 1);
INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (4, 3);

-- Insert Visitors
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Mary Smith', 'Mother', '555-0401');
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Jennifer Rodriguez', 'Wife', '555-0402');
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Fatima Hassan', 'Sister', '555-0403');
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Susan Kim', 'Mother', '555-0404');
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Angela Johnson', 'Girlfriend', '555-0405');
INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Laura Thompson', 'Sister', '555-0406');

-- Insert Visits
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (1, 1, #01/10/2024 14:00:00#);
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (2, 2, #01/12/2024 15:30:00#);
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (3, 3, #01/14/2024 10:00:00#);
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (4, 4, #01/16/2024 13:00:00#);
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (5, 5, #01/18/2024 11:00:00#);
INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (7, 6, #01/20/2024 14:30:00#);

-- Insert Users (Password: password123)
INSERT INTO Users (Username, Password, Role, StaffID, GuardID) VALUES ('admin', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Admin', NULL, NULL);
INSERT INTO Users (Username, Password, Role, StaffID, GuardID) VALUES ('sarah.johnson', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Staff', 1, NULL);
INSERT INTO Users (Username, Password, Role, StaffID, GuardID) VALUES ('john.martinez', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Guard', NULL, 1);
