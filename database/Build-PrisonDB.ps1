#requires -Version 5.1
# Builds PrisonManagement.accdb with all tables, sample data, and relationships visible in the Relationships diagram.

$ErrorActionPreference = 'Stop'
$dbPath = Join-Path $PSScriptRoot 'PrisonManagement.accdb'

# --- Step 1: Remove any existing item at the target path (file OR OneDrive directory) ---
if (Test-Path -LiteralPath $dbPath) {
    Write-Host "Removing existing item at $dbPath..."
    # If it's a OneDrive ReparsePoint folder, try normal recurse first, then attrib clear if needed.
    try {
        Remove-Item -LiteralPath $dbPath -Recurse -Force
    } catch {
        attrib -r -s -h "$dbPath" /S /D 2>$null
        Remove-Item -LiteralPath $dbPath -Recurse -Force
    }
}

# --- Step 2: Create the database via DAO (ACE 120 engine) ---
Write-Host "Creating new Access database..."
$engine = New-Object -ComObject DAO.DBEngine.120
$db = $engine.CreateDatabase($dbPath, ';LANGID=0x0409;CP=1252;COUNTRY=0')

$dbFailOnError = 128

function Invoke-Sql([string]$sql) {
    $db.Execute($sql, $dbFailOnError)
}

# --- Step 3: Create tables (no inline FK constraints — relationships added later via DAO so they show in the diagram) ---
Write-Host "Creating tables..."

# Minimal DDL — DAO's ANSI-89 parser dislikes DEFAULT/NOT NULL/CHECK. Apply those via DAO properties below.
$tableSql = @(
    "CREATE TABLE Cell (CellID AUTOINCREMENT PRIMARY KEY, BlockName TEXT(50), Capacity LONG, Occupied LONG)",
    "CREATE TABLE Crime (CrimeID AUTOINCREMENT PRIMARY KEY, CrimeName TEXT(100), SeverityLevel TEXT(20))",
    "CREATE TABLE Kitchen (RestaurantID AUTOINCREMENT PRIMARY KEY, RestaurantName TEXT(100), Capacity LONG)",
    "CREATE TABLE BackupForces (BackupID AUTOINCREMENT PRIMARY KEY, FullName TEXT(100), [Rank] TEXT(50), Phone TEXT(20), ShiftTime TEXT(50))",
    "CREATE TABLE Staff (StaffID AUTOINCREMENT PRIMARY KEY, FullName TEXT(100), JobType TEXT(50), Phone TEXT(20), ShiftTime TEXT(50), RestaurantID LONG)",
    "CREATE TABLE Guards (GuardID AUTOINCREMENT PRIMARY KEY, FullName TEXT(100), Phone TEXT(20), ShiftTime TEXT(50), CellID LONG)",
    "CREATE TABLE Prisoners (PrisonerID AUTOINCREMENT PRIMARY KEY, FullName TEXT(100), Age LONG, Gender TEXT(10), SentenceYears LONG, AdmissionDate DATETIME, ReleaseDate DATETIME, CellID LONG, Status TEXT(20))",
    "CREATE TABLE Visitors (VisitorID AUTOINCREMENT PRIMARY KEY, FullName TEXT(100), RelationToPrisoner TEXT(50), Phone TEXT(20))",
    "CREATE TABLE Emergencies (EmergencyID AUTOINCREMENT PRIMARY KEY, EmergencyType TEXT(50), EmergencyDate DATETIME, Location TEXT(100), [Description] MEMO, CellID LONG)",
    "CREATE TABLE PrisonerCrime (PrisonerCrimeID AUTOINCREMENT PRIMARY KEY, PrisonerID LONG, CrimeID LONG, CrimeDate DATETIME)",
    "CREATE TABLE Visits (VisitID AUTOINCREMENT PRIMARY KEY, PrisonerID LONG, VisitorID LONG, VisitDate DATETIME)",
    "CREATE TABLE EmergencyBackup (EmergencyBackupID AUTOINCREMENT PRIMARY KEY, EmergencyID LONG, BackupID LONG)",
    "CREATE TABLE Users (UserID AUTOINCREMENT PRIMARY KEY, Username TEXT(50), [Password] TEXT(100), Role TEXT(20), StaffID LONG, GuardID LONG)"
)

foreach ($sql in $tableSql) { Invoke-Sql $sql }

# Unique index on Users.Username
Invoke-Sql "CREATE UNIQUE INDEX idx_Users_Username ON Users (Username)"

# Apply NOT NULL (Required) via DAO field properties, plus defaults and validation rules.
function Set-Required($tableName, $fieldName) {
    $td = $db.TableDefs.Item($tableName)
    $f = $td.Fields.Item($fieldName)
    $f.Required = $true
}
function Set-Default($tableName, $fieldName, $value) {
    $td = $db.TableDefs.Item($tableName)
    $f = $td.Fields.Item($fieldName)
    $f.DefaultValue = $value
}
function Set-Validation($tableName, $fieldName, $rule) {
    $td = $db.TableDefs.Item($tableName)
    $f = $td.Fields.Item($fieldName)
    $f.ValidationRule = $rule
}

Set-Required 'Cell' 'BlockName'
Set-Required 'Cell' 'Capacity'
Set-Default  'Cell' 'Occupied' '0'

Set-Required 'Crime' 'CrimeName'
Set-Validation 'Crime' 'SeverityLevel' "In ('Low','Medium','High','Critical')"

Set-Required 'Kitchen' 'RestaurantName'

Set-Required 'BackupForces' 'FullName'

Set-Required 'Staff' 'FullName'

Set-Required 'Guards' 'FullName'

Set-Required 'Prisoners' 'FullName'
Set-Default  'Prisoners' 'Status' '"Active"'

Set-Required 'Visitors' 'FullName'

Set-Required 'Emergencies' 'EmergencyType'
Set-Default  'Emergencies' 'EmergencyDate' 'Now()'

Set-Required 'PrisonerCrime' 'PrisonerID'
Set-Required 'PrisonerCrime' 'CrimeID'

Set-Required 'Visits' 'PrisonerID'
Set-Required 'Visits' 'VisitorID'
Set-Default  'Visits' 'VisitDate' 'Now()'

Set-Required 'EmergencyBackup' 'EmergencyID'
Set-Required 'EmergencyBackup' 'BackupID'

Set-Required 'Users' 'Username'
Set-Required 'Users' 'Password'
Set-Validation 'Users' 'Role' "In ('Admin','Staff','Guard')"

# --- Step 4: Insert sample data ---
Write-Host "Inserting data..."

$insertSql = @(
    # Cells
    "INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block A', 4, 3)",
    "INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block B', 4, 4)",
    "INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block C', 6, 5)",
    "INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Block D', 4, 2)",
    "INSERT INTO Cell (BlockName, Capacity, Occupied) VALUES ('Isolation Wing', 2, 1)",

    # Crimes
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Theft', 'Low')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Assault', 'Medium')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Armed Robbery', 'High')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Murder', 'Critical')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Drug Trafficking', 'High')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Fraud', 'Medium')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Kidnapping', 'Critical')",
    "INSERT INTO Crime (CrimeName, SeverityLevel) VALUES ('Burglary', 'Medium')",

    # Kitchens
    "INSERT INTO Kitchen (RestaurantName, Capacity) VALUES ('Main Cafeteria', 500)",
    "INSERT INTO Kitchen (RestaurantName, Capacity) VALUES ('Staff Dining', 50)",

    # Staff
    "INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Sarah Johnson', 'Cook', '555-0101', 'Day Shift', 1)",
    "INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Mike Chen', 'Chef', '555-0102', 'Day Shift', 1)",
    "INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Emily Davis', 'Nutritionist', '555-0103', 'Day Shift', 1)",
    "INSERT INTO Staff (FullName, JobType, Phone, ShiftTime, RestaurantID) VALUES ('Tom Wilson', 'Kitchen Manager', '555-0104', 'Day Shift', 2)",

    # Guards
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('John Martinez', '555-0201', 'Night Shift', 1)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Lisa Anderson', '555-0202', 'Day Shift', 1)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('David Brown', '555-0203', 'Evening Shift', 2)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Maria Garcia', '555-0204', 'Day Shift', 3)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Robert Taylor', '555-0205', 'Night Shift', 3)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('Jennifer Lee', '555-0206', 'Day Shift', 4)",
    "INSERT INTO Guards (FullName, Phone, ShiftTime, CellID) VALUES ('James White', '555-0207', 'Evening Shift', 5)",

    # Prisoners
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Michael Smith', 34, 'Male', 10, #03/15/2020#, #03/15/2030#, 1, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Carlos Rodriguez', 28, 'Male', 5, #06/20/2022#, #06/20/2027#, 1, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Ahmed Hassan', 41, 'Male', 25, #01/10/2018#, #01/10/2043#, 1, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Daniel Kim', 30, 'Male', 8, #09/05/2021#, #09/05/2029#, 2, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Marcus Johnson', 26, 'Male', 3, #02/14/2023#, #02/14/2026#, 2, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Luis Fernandez', 38, 'Male', 15, #11/22/2019#, #11/22/2034#, 2, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Ryan Thompson', 29, 'Male', 6, #04/18/2022#, #04/18/2028#, 2, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Anthony Davis', 45, 'Male', 20, #07/30/2017#, #07/30/2037#, 3, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Victor Martinez', 33, 'Male', 12, #10/12/2020#, #10/12/2032#, 3, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Jason Lee', 27, 'Male', 4, #05/25/2023#, #05/25/2027#, 3, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Kevin Brown', 36, 'Male', 9, #12/08/2021#, #12/08/2030#, 3, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Omar Ali', 31, 'Male', 7, #08/16/2022#, #08/16/2029#, 3, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Christopher White', 42, 'Male', 18, #03/22/2018#, #03/22/2036#, 4, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Brandon Garcia', 25, 'Male', 2, #01/10/2024#, #01/10/2026#, 4, 'Active')",
    "INSERT INTO Prisoners (FullName, Age, Gender, SentenceYears, AdmissionDate, ReleaseDate, CellID, Status) VALUES ('Samuel Wilson', 39, 'Male', 14, #06/14/2019#, #06/14/2033#, 5, 'Active')",

    # PrisonerCrime
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (1, 3, #03/10/2020#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (2, 2, #06/15/2022#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (3, 4, #01/05/2018#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (4, 5, #09/01/2021#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (5, 1, #02/10/2023#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (6, 7, #11/18/2019#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (7, 6, #04/12/2022#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (8, 4, #07/25/2017#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (9, 3, #10/08/2020#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (10, 2, #05/20/2023#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (11, 5, #12/01/2021#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (12, 8, #08/10/2022#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (13, 4, #03/15/2018#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (14, 1, #01/05/2024#)",
    "INSERT INTO PrisonerCrime (PrisonerID, CrimeID, CrimeDate) VALUES (15, 7, #06/10/2019#)",

    # BackupForces
    "INSERT INTO BackupForces (FullName, [Rank], Phone, ShiftTime) VALUES ('Captain Richards', 'Captain', '555-0301', 'On-Call')",
    "INSERT INTO BackupForces (FullName, [Rank], Phone, ShiftTime) VALUES ('Lieutenant Foster', 'Lieutenant', '555-0302', 'On-Call')",
    "INSERT INTO BackupForces (FullName, [Rank], Phone, ShiftTime) VALUES ('Sergeant Murphy', 'Sergeant', '555-0303', 'Day Shift')",
    "INSERT INTO BackupForces (FullName, [Rank], Phone, ShiftTime) VALUES ('Officer Palmer', 'Officer', '555-0304', 'Night Shift')",

    # Emergencies
    "INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, [Description], CellID) VALUES ('Fight', #01/15/2024 14:30:00#, 'Cafeteria', 'Altercation between two inmates', NULL)",
    "INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, [Description], CellID) VALUES ('Medical', #01/18/2024 09:15:00#, 'Block C', 'Inmate collapsed, ambulance called', 3)",
    "INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, [Description], CellID) VALUES ('Fire Alarm', #01/20/2024 22:45:00#, 'Kitchen', 'Smoke detected in kitchen area', NULL)",
    "INSERT INTO Emergencies (EmergencyType, EmergencyDate, Location, [Description], CellID) VALUES ('Lockdown', #01/22/2024 16:00:00#, 'Block A', 'Suspicious activity reported', 1)",

    # EmergencyBackup
    "INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (1, 3)",
    "INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (2, 1)",
    "INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (3, 2)",
    "INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (4, 1)",
    "INSERT INTO EmergencyBackup (EmergencyID, BackupID) VALUES (4, 3)",

    # Visitors
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Mary Smith', 'Mother', '555-0401')",
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Jennifer Rodriguez', 'Wife', '555-0402')",
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Fatima Hassan', 'Sister', '555-0403')",
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Susan Kim', 'Mother', '555-0404')",
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Angela Johnson', 'Girlfriend', '555-0405')",
    "INSERT INTO Visitors (FullName, RelationToPrisoner, Phone) VALUES ('Laura Thompson', 'Sister', '555-0406')",

    # Visits
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (1, 1, #01/10/2024 14:00:00#)",
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (2, 2, #01/12/2024 15:30:00#)",
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (3, 3, #01/14/2024 10:00:00#)",
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (4, 4, #01/16/2024 13:00:00#)",
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (5, 5, #01/18/2024 11:00:00#)",
    "INSERT INTO Visits (PrisonerID, VisitorID, VisitDate) VALUES (7, 6, #01/20/2024 14:30:00#)",

    # Users (password hash from spec = SHA256('password123'))
    "INSERT INTO Users (Username, [Password], Role, StaffID, GuardID) VALUES ('admin', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Admin', NULL, NULL)",
    "INSERT INTO Users (Username, [Password], Role, StaffID, GuardID) VALUES ('sarah.johnson', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Staff', 1, NULL)",
    "INSERT INTO Users (Username, [Password], Role, StaffID, GuardID) VALUES ('john.martinez', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Guard', NULL, 1)"
)

foreach ($sql in $insertSql) { Invoke-Sql $sql }

# --- Step 5: Create relationships (visible in Database Tools -> Relationships) ---
Write-Host "Creating relationships..."

# DAO Relation attributes
$dbRelationUpdateCascade = 256
$dbRelationDeleteCascade = 4096
$attrsEnforcedCascadeUpdate = $dbRelationUpdateCascade  # Enforce RI + cascade update (matches setup guide)

function Add-Relation {
    param(
        [string]$Name,
        [string]$PrimaryTable,
        [string]$ForeignTable,
        [string]$PrimaryField,
        [string]$ForeignField,
        [int]$Attributes
    )
    $rel = $db.CreateRelation($Name, $PrimaryTable, $ForeignTable, $Attributes)
    $fld = $rel.CreateField($PrimaryField)
    $fld.ForeignName = $ForeignField
    $rel.Fields.Append($fld)
    $db.Relations.Append($rel)
    Write-Host "  $PrimaryTable.$PrimaryField -> $ForeignTable.$ForeignField"
}

Add-Relation -Name 'Cell_Prisoners'        -PrimaryTable 'Cell'         -ForeignTable 'Prisoners'        -PrimaryField 'CellID'        -ForeignField 'CellID'        -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Cell_Guards'           -PrimaryTable 'Cell'         -ForeignTable 'Guards'           -PrimaryField 'CellID'        -ForeignField 'CellID'        -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Cell_Emergencies'      -PrimaryTable 'Cell'         -ForeignTable 'Emergencies'      -PrimaryField 'CellID'        -ForeignField 'CellID'        -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Kitchen_Staff'         -PrimaryTable 'Kitchen'      -ForeignTable 'Staff'            -PrimaryField 'RestaurantID'  -ForeignField 'RestaurantID'  -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Crime_PrisonerCrime'   -PrimaryTable 'Crime'        -ForeignTable 'PrisonerCrime'    -PrimaryField 'CrimeID'       -ForeignField 'CrimeID'       -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Prisoners_PrisonerCrime' -PrimaryTable 'Prisoners'  -ForeignTable 'PrisonerCrime'    -PrimaryField 'PrisonerID'    -ForeignField 'PrisonerID'    -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Prisoners_Visits'      -PrimaryTable 'Prisoners'    -ForeignTable 'Visits'           -PrimaryField 'PrisonerID'    -ForeignField 'PrisonerID'    -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Visitors_Visits'       -PrimaryTable 'Visitors'     -ForeignTable 'Visits'           -PrimaryField 'VisitorID'     -ForeignField 'VisitorID'     -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Emergencies_EmergencyBackup' -PrimaryTable 'Emergencies' -ForeignTable 'EmergencyBackup' -PrimaryField 'EmergencyID' -ForeignField 'EmergencyID' -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'BackupForces_EmergencyBackup' -PrimaryTable 'BackupForces' -ForeignTable 'EmergencyBackup' -PrimaryField 'BackupID'   -ForeignField 'BackupID'    -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Staff_Users'           -PrimaryTable 'Staff'        -ForeignTable 'Users'            -PrimaryField 'StaffID'       -ForeignField 'StaffID'       -Attributes $attrsEnforcedCascadeUpdate
Add-Relation -Name 'Guards_Users'          -PrimaryTable 'Guards'       -ForeignTable 'Users'            -PrimaryField 'GuardID'       -ForeignField 'GuardID'       -Attributes $attrsEnforcedCascadeUpdate

# --- Step 6: Verify counts ---
Write-Host ""
Write-Host "Verifying row counts..."
$tables = @('Cell','Crime','Kitchen','Staff','Guards','Prisoners','Visitors','BackupForces','Emergencies','PrisonerCrime','Visits','EmergencyBackup','Users')
foreach ($t in $tables) {
    $rs = $db.OpenRecordset("SELECT COUNT(*) AS c FROM [$t]")
    $count = $rs.Fields.Item('c').Value
    $rs.Close()
    Write-Host ("  {0,-18} {1,4} rows" -f $t, $count)
}

Write-Host ""
Write-Host "Relationships ($($db.Relations.Count)):"
foreach ($r in $db.Relations) {
    Write-Host "  $($r.Name): $($r.Table) -> $($r.ForeignTable) [attrs=$($r.Attributes)]"
}

# --- Step 7: Close ---
$db.Close()
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($db) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($engine) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

Write-Host ""
Write-Host "Done. Database created at: $dbPath"
