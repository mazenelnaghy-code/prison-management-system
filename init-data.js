import crypto from 'crypto';
import fs from 'fs';

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

const data = {
  users: [
    { UserID: 1, Username: 'admin', Password: hashPassword('password123'), Role: 'Admin', StaffID: null, GuardID: null },
    { UserID: 2, Username: 'sarah.johnson', Password: hashPassword('password123'), Role: 'Staff', StaffID: 1, GuardID: null },
    { UserID: 3, Username: 'mike.chen', Password: hashPassword('password123'), Role: 'Staff', StaffID: 2, GuardID: null },
    { UserID: 4, Username: 'john.martinez', Password: hashPassword('password123'), Role: 'Guard', StaffID: null, GuardID: 1 },
    { UserID: 5, Username: 'lisa.anderson', Password: hashPassword('password123'), Role: 'Guard', StaffID: null, GuardID: 2 }
  ],
  cells: [
    { CellID: 1, BlockName: 'Block A', Capacity: 4, Occupied: 3 },
    { CellID: 2, BlockName: 'Block B', Capacity: 4, Occupied: 4 },
    { CellID: 3, BlockName: 'Block C', Capacity: 6, Occupied: 5 },
    { CellID: 4, BlockName: 'Block D', Capacity: 4, Occupied: 2 },
    { CellID: 5, BlockName: 'Isolation Wing', Capacity: 2, Occupied: 1 }
  ],
  crimes: [
    { CrimeID: 1, CrimeName: 'Theft', SeverityLevel: 'Low' },
    { CrimeID: 2, CrimeName: 'Assault', SeverityLevel: 'Medium' },
    { CrimeID: 3, CrimeName: 'Armed Robbery', SeverityLevel: 'High' },
    { CrimeID: 4, CrimeName: 'Murder', SeverityLevel: 'Critical' },
    { CrimeID: 5, CrimeName: 'Drug Trafficking', SeverityLevel: 'High' },
    { CrimeID: 6, CrimeName: 'Fraud', SeverityLevel: 'Medium' },
    { CrimeID: 7, CrimeName: 'Kidnapping', SeverityLevel: 'Critical' },
    { CrimeID: 8, CrimeName: 'Burglary', SeverityLevel: 'Medium' }
  ],
  kitchens: [
    { RestaurantID: 1, RestaurantName: 'Main Cafeteria', Capacity: 500 },
    { RestaurantID: 2, RestaurantName: 'Staff Dining', Capacity: 50 }
  ],
  staff: [
    { StaffID: 1, FullName: 'Sarah Johnson', JobType: 'Cook', Phone: '555-0101', ShiftTime: 'Day Shift', RestaurantID: 1 },
    { StaffID: 2, FullName: 'Mike Chen', JobType: 'Chef', Phone: '555-0102', ShiftTime: 'Day Shift', RestaurantID: 1 },
    { StaffID: 3, FullName: 'Emily Davis', JobType: 'Nutritionist', Phone: '555-0103', ShiftTime: 'Day Shift', RestaurantID: 1 },
    { StaffID: 4, FullName: 'Tom Wilson', JobType: 'Kitchen Manager', Phone: '555-0104', ShiftTime: 'Day Shift', RestaurantID: 2 }
  ],
  guards: [
    { GuardID: 1, FullName: 'John Martinez', Phone: '555-0201', ShiftTime: 'Night Shift', CellID: 1 },
    { GuardID: 2, FullName: 'Lisa Anderson', Phone: '555-0202', ShiftTime: 'Day Shift', CellID: 1 },
    { GuardID: 3, FullName: 'David Brown', Phone: '555-0203', ShiftTime: 'Evening Shift', CellID: 2 },
    { GuardID: 4, FullName: 'Maria Garcia', Phone: '555-0204', ShiftTime: 'Day Shift', CellID: 3 },
    { GuardID: 5, FullName: 'Robert Taylor', Phone: '555-0205', ShiftTime: 'Night Shift', CellID: 3 },
    { GuardID: 6, FullName: 'Jennifer Lee', Phone: '555-0206', ShiftTime: 'Day Shift', CellID: 4 },
    { GuardID: 7, FullName: 'James White', Phone: '555-0207', ShiftTime: 'Evening Shift', CellID: 5 }
  ],
  prisoners: [
    { PrisonerID: 1, FullName: 'Michael Smith', Age: 34, Gender: 'Male', SentenceYears: 10, AdmissionDate: '2020-03-15', ReleaseDate: '2030-03-15', CellID: 1, Status: 'Active' },
    { PrisonerID: 2, FullName: 'Carlos Rodriguez', Age: 28, Gender: 'Male', SentenceYears: 5, AdmissionDate: '2022-06-20', ReleaseDate: '2027-06-20', CellID: 1, Status: 'Active' },
    { PrisonerID: 3, FullName: 'Ahmed Hassan', Age: 41, Gender: 'Male', SentenceYears: 25, AdmissionDate: '2018-01-10', ReleaseDate: '2043-01-10', CellID: 1, Status: 'Active' },
    { PrisonerID: 4, FullName: 'Daniel Kim', Age: 30, Gender: 'Male', SentenceYears: 8, AdmissionDate: '2021-09-05', ReleaseDate: '2029-09-05', CellID: 2, Status: 'Active' },
    { PrisonerID: 5, FullName: 'Marcus Johnson', Age: 26, Gender: 'Male', SentenceYears: 3, AdmissionDate: '2023-02-14', ReleaseDate: '2026-02-14', CellID: 2, Status: 'Active' },
    { PrisonerID: 6, FullName: 'Luis Fernandez', Age: 38, Gender: 'Male', SentenceYears: 15, AdmissionDate: '2019-11-22', ReleaseDate: '2034-11-22', CellID: 2, Status: 'Active' },
    { PrisonerID: 7, FullName: 'Ryan Thompson', Age: 29, Gender: 'Male', SentenceYears: 6, AdmissionDate: '2022-04-18', ReleaseDate: '2028-04-18', CellID: 2, Status: 'Active' },
    { PrisonerID: 8, FullName: 'Anthony Davis', Age: 45, Gender: 'Male', SentenceYears: 20, AdmissionDate: '2017-07-30', ReleaseDate: '2037-07-30', CellID: 3, Status: 'Active' },
    { PrisonerID: 9, FullName: 'Victor Martinez', Age: 33, Gender: 'Male', SentenceYears: 12, AdmissionDate: '2020-10-12', ReleaseDate: '2032-10-12', CellID: 3, Status: 'Active' },
    { PrisonerID: 10, FullName: 'Jason Lee', Age: 27, Gender: 'Male', SentenceYears: 4, AdmissionDate: '2023-05-25', ReleaseDate: '2027-05-25', CellID: 3, Status: 'Active' },
    { PrisonerID: 11, FullName: 'Kevin Brown', Age: 36, Gender: 'Male', SentenceYears: 9, AdmissionDate: '2021-12-08', ReleaseDate: '2030-12-08', CellID: 3, Status: 'Active' },
    { PrisonerID: 12, FullName: 'Omar Ali', Age: 31, Gender: 'Male', SentenceYears: 7, AdmissionDate: '2022-08-16', ReleaseDate: '2029-08-16', CellID: 3, Status: 'Active' },
    { PrisonerID: 13, FullName: 'Christopher White', Age: 42, Gender: 'Male', SentenceYears: 18, AdmissionDate: '2018-03-22', ReleaseDate: '2036-03-22', CellID: 4, Status: 'Active' },
    { PrisonerID: 14, FullName: 'Brandon Garcia', Age: 25, Gender: 'Male', SentenceYears: 2, AdmissionDate: '2024-01-10', ReleaseDate: '2026-01-10', CellID: 4, Status: 'Active' },
    { PrisonerID: 15, FullName: 'Samuel Wilson', Age: 39, Gender: 'Male', SentenceYears: 14, AdmissionDate: '2019-06-14', ReleaseDate: '2033-06-14', CellID: 5, Status: 'Active' }
  ],
  prisonerCrimes: [
    { PrisonerCrimeID: 1, PrisonerID: 1, CrimeID: 3, CrimeDate: '2020-03-10' },
    { PrisonerCrimeID: 2, PrisonerID: 2, CrimeID: 2, CrimeDate: '2022-06-15' },
    { PrisonerCrimeID: 3, PrisonerID: 3, CrimeID: 4, CrimeDate: '2018-01-05' },
    { PrisonerCrimeID: 4, PrisonerID: 4, CrimeID: 5, CrimeDate: '2021-09-01' },
    { PrisonerCrimeID: 5, PrisonerID: 5, CrimeID: 1, CrimeDate: '2023-02-10' },
    { PrisonerCrimeID: 6, PrisonerID: 6, CrimeID: 7, CrimeDate: '2019-11-18' },
    { PrisonerCrimeID: 7, PrisonerID: 7, CrimeID: 6, CrimeDate: '2022-04-12' },
    { PrisonerCrimeID: 8, PrisonerID: 8, CrimeID: 4, CrimeDate: '2017-07-25' },
    { PrisonerCrimeID: 9, PrisonerID: 9, CrimeID: 3, CrimeDate: '2020-10-08' },
    { PrisonerCrimeID: 10, PrisonerID: 10, CrimeID: 2, CrimeDate: '2023-05-20' },
    { PrisonerCrimeID: 11, PrisonerID: 11, CrimeID: 5, CrimeDate: '2021-12-01' },
    { PrisonerCrimeID: 12, PrisonerID: 12, CrimeID: 8, CrimeDate: '2022-08-10' },
    { PrisonerCrimeID: 13, PrisonerID: 13, CrimeID: 4, CrimeDate: '2018-03-15' },
    { PrisonerCrimeID: 14, PrisonerID: 14, CrimeID: 1, CrimeDate: '2024-01-05' },
    { PrisonerCrimeID: 15, PrisonerID: 15, CrimeID: 7, CrimeDate: '2019-06-10' }
  ],
  backupForces: [
    { BackupID: 1, FullName: 'Captain Richards', Rank: 'Captain', Phone: '555-0301', ShiftTime: 'On-Call' },
    { BackupID: 2, FullName: 'Lieutenant Foster', Rank: 'Lieutenant', Phone: '555-0302', ShiftTime: 'On-Call' },
    { BackupID: 3, FullName: 'Sergeant Murphy', Rank: 'Sergeant', Phone: '555-0303', ShiftTime: 'Day Shift' },
    { BackupID: 4, FullName: 'Officer Palmer', Rank: 'Officer', Phone: '555-0304', ShiftTime: 'Night Shift' }
  ],
  emergencies: [
    { EmergencyID: 1, EmergencyType: 'Fight', EmergencyDate: '2024-01-15 14:30:00', Location: 'Cafeteria', Description: 'Altercation between two inmates', CellID: null },
    { EmergencyID: 2, EmergencyType: 'Medical', EmergencyDate: '2024-01-18 09:15:00', Location: 'Block C', Description: 'Inmate collapsed, ambulance called', CellID: 3 },
    { EmergencyID: 3, EmergencyType: 'Fire Alarm', EmergencyDate: '2024-01-20 22:45:00', Location: 'Kitchen', Description: 'Smoke detected in kitchen area', CellID: null },
    { EmergencyID: 4, EmergencyType: 'Lockdown', EmergencyDate: '2024-01-22 16:00:00', Location: 'Block A', Description: 'Suspicious activity reported', CellID: 1 }
  ],
  emergencyBackup: [
    { EmergencyBackupID: 1, EmergencyID: 1, BackupID: 3 },
    { EmergencyBackupID: 2, EmergencyID: 2, BackupID: 1 },
    { EmergencyBackupID: 3, EmergencyID: 3, BackupID: 2 },
    { EmergencyBackupID: 4, EmergencyID: 4, BackupID: 1 },
    { EmergencyBackupID: 5, EmergencyID: 4, BackupID: 3 }
  ],
  visitors: [
    { VisitorID: 1, FullName: 'Mary Smith', RelationToPrisoner: 'Mother', Phone: '555-0401' },
    { VisitorID: 2, FullName: 'Jennifer Rodriguez', RelationToPrisoner: 'Wife', Phone: '555-0402' },
    { VisitorID: 3, FullName: 'Fatima Hassan', RelationToPrisoner: 'Sister', Phone: '555-0403' },
    { VisitorID: 4, FullName: 'Susan Kim', RelationToPrisoner: 'Mother', Phone: '555-0404' },
    { VisitorID: 5, FullName: 'Angela Johnson', RelationToPrisoner: 'Girlfriend', Phone: '555-0405' },
    { VisitorID: 6, FullName: 'Laura Thompson', RelationToPrisoner: 'Sister', Phone: '555-0406' }
  ],
  visits: [
    { VisitID: 1, PrisonerID: 1, VisitorID: 1, VisitDate: '2024-01-10 14:00:00' },
    { VisitID: 2, PrisonerID: 2, VisitorID: 2, VisitDate: '2024-01-12 15:30:00' },
    { VisitID: 3, PrisonerID: 3, VisitorID: 3, VisitDate: '2024-01-14 10:00:00' },
    { VisitID: 4, PrisonerID: 4, VisitorID: 4, VisitDate: '2024-01-16 13:00:00' },
    { VisitID: 5, PrisonerID: 5, VisitorID: 5, VisitDate: '2024-01-18 11:00:00' },
    { VisitID: 6, PrisonerID: 7, VisitorID: 6, VisitDate: '2024-01-20 14:30:00' }
  ]
};

fs.writeFileSync('data.json', JSON.stringify(data, null, 2));

console.log('Database initialized with sample data!');
console.log('\nLogin credentials:');
console.log('Admin: admin / password123');
console.log('Staff: sarah.johnson / password123');
console.log('Guard: john.martinez / password123');
