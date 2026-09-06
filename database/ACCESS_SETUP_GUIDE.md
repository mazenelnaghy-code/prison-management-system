# 🔷 Creating a Full Access Database with Relationships

## Method 1: Import SQL Script (Recommended)

### Step 1: Create New Access Database
1. Open **Microsoft Access**
2. Click **Blank Database**
3. Name it: `PrisonManagement.accdb`
4. Choose location: Your Desktop
5. Click **Create**

### Step 2: Import the SQL Script
1. In Access, go to **Database Tools** tab
2. Click **Query Design**
3. Close the "Show Table" dialog (click X)
4. Click **SQL View** button (or View menu → SQL View)
5. Open the file `PrisonManagement_Complete.sql` in Notepad
6. **Copy ALL the text** (Ctrl+A, Ctrl+C)
7. **Paste it** into the Access SQL window (Ctrl+V)
8. Click **Run** button (red exclamation mark)

**IMPORTANT:** The script runs in sections. You'll need to:
- Copy and paste **one section at a time** (each INSERT statement)
- Run each section separately
- OR use the alternate method below

---

## Method 2: Manual Creation (Step-by-Step)

### Step 1: Create Tables

#### 1. Cell Table
- Right-click in left panel → **Table Design**
- Add fields:
  - `CellID` → Number → Primary Key
  - `BlockName` → Short Text (50)
  - `Capacity` → Number
  - `Occupied` → Number (Default: 0)
- Save as: **Cell**

#### 2. Crime Table
- Create new table
- Add fields:
  - `CrimeID` → Number → Primary Key
  - `CrimeName` → Short Text (100)
  - `SeverityLevel` → Short Text (20)
- Save as: **Crime**

#### 3. Kitchen Table
- `RestaurantID` → Number → Primary Key
- `RestaurantName` → Short Text (100)
- `Capacity` → Number
- Save as: **Kitchen**

#### 4. Staff Table
- `StaffID` → Number → Primary Key
- `FullName` → Short Text (100)
- `JobType` → Short Text (50)
- `Phone` → Short Text (20)
- `ShiftTime` → Short Text (50)
- `RestaurantID` → Number (Foreign Key to Kitchen)
- Save as: **Staff**

#### 5. Guards Table
- `GuardID` → Number → Primary Key
- `FullName` → Short Text (100)
- `Phone` → Short Text (20)
- `ShiftTime` → Short Text (50)
- `CellID` → Number (Foreign Key to Cell)
- Save as: **Guards**

#### 6. Prisoners Table
- `PrisonerID` → Number → Primary Key
- `FullName` → Short Text (100)
- `Age` → Number
- `Gender` → Short Text (10)
- `SentenceYears` → Number
- `AdmissionDate` → Date/Time
- `ReleaseDate` → Date/Time
- `CellID` → Number (Foreign Key to Cell)
- `Status` → Short Text (20)
- Save as: **Prisoners**

#### 7. Visitors Table
- `VisitorID` → Number → Primary Key
- `FullName` → Short Text (100)
- `RelationToPrisoner` → Short Text (50)
- `Phone` → Short Text (20)
- Save as: **Visitors**

#### 8. BackupForces Table
- `BackupID` → Number → Primary Key
- `FullName` → Short Text (100)
- `Rank` → Short Text (50)
- `Phone` → Short Text (20)
- `ShiftTime` → Short Text (50)
- Save as: **BackupForces**

#### 9. Emergencies Table
- `EmergencyID` → Number → Primary Key
- `EmergencyType` → Short Text (50)
- `EmergencyDate` → Date/Time
- `Location` → Short Text (100)
- `Description` → Long Text
- `CellID` → Number (Foreign Key to Cell)
- Save as: **Emergencies**

#### 10. PrisonerCrime Table (Junction)
- `PrisonerCrimeID` → Number → Primary Key
- `PrisonerID` → Number (Foreign Key to Prisoners)
- `CrimeID` → Number (Foreign Key to Crime)
- `CrimeDate` → Date/Time
- Save as: **PrisonerCrime**

#### 11. Visits Table
- `VisitID` → Number → Primary Key
- `PrisonerID` → Number (Foreign Key to Prisoners)
- `VisitorID` → Number (Foreign Key to Visitors)
- `VisitDate` → Date/Time
- Save as: **Visits**

#### 12. EmergencyBackup Table (Junction)
- `EmergencyBackupID` → Number → Primary Key
- `EmergencyID` → Number (Foreign Key to Emergencies)
- `BackupID` → Number (Foreign Key to BackupForces)
- Save as: **EmergencyBackup**

### Step 2: Create Relationships

1. Go to **Database Tools** → **Relationships**
2. Add all tables (right-click → Show Table)
3. Create relationships by dragging:

**One-to-Many Relationships:**
- Cell → Prisoners (CellID to CellID)
- Cell → Guards (CellID to CellID)
- Cell → Emergencies (CellID to CellID)
- Kitchen → Staff (RestaurantID to RestaurantID)
- Crime → PrisonerCrime (CrimeID to CrimeID)
- Prisoners → PrisonerCrime (PrisonerID to PrisonerID)
- Prisoners → Visits (PrisonerID to PrisonerID)
- Visitors → Visits (VisitorID to VisitorID)
- Emergencies → EmergencyBackup (EmergencyID to EmergencyID)
- BackupForces → EmergencyBackup (BackupID to BackupID)

4. For each relationship:
   - ✅ Check "Enforce Referential Integrity"
   - ✅ Check "Cascade Update Related Fields"
   - Click **Create**

5. Save the relationship diagram

### Step 3: Enter Sample Data

Open each table in **Datasheet View** and enter the data from the SQL file or use the CSV files provided.

---

## Method 3: Use the CSV Import Files

I can create individual CSV files for each table that you can import directly into Access:

1. **External Data** tab → **New Data Source** → **From File** → **Text File**
2. Select CSV file
3. Follow wizard to import
4. Repeat for each table

---

## Viewing Relationships

After everything is set up:
1. Go to **Database Tools** → **Relationships**
2. You'll see all tables connected with relationship lines
3. Double-click any line to see/edit relationship properties

---

## Creating Queries

### Example: View All Prisoners with Their Crimes
1. **Create** tab → **Query Design**
2. Add tables: Prisoners, PrisonerCrime, Crime
3. Add fields you want to see
4. Run query

### Example: View Cell Occupancy
1. Create Query Design
2. Add: Cell table
3. Add calculated field: `Occupancy: [Occupied]/[Capacity]*100`

---

## Creating Forms

### Simple Form for Data Entry:
1. Click a table (e.g., Prisoners)
2. **Create** tab → **Form**
3. Access creates automatic form
4. Customize as needed

### Split Form (Table + Form):
1. Click table
2. **Create** tab → **More Forms** → **Split Form**

---

## Creating Reports

1. Click a table or query
2. **Create** tab → **Report**
3. Access generates automatic report
4. Use **Report Design** for custom layouts

---

## Tips

- **AutoNumber**: For Primary Keys, use **AutoNumber** data type (automatically increments)
- **Lookup Fields**: For foreign keys, create Lookup Wizard to show names instead of IDs
- **Input Masks**: Set for Phone fields → `(000) 000-0000`
- **Validation Rules**: For SeverityLevel → In("Low","Medium","High","Critical")

---

## Complete Database Features

Your Access database will have:
- ✅ 12 interconnected tables
- ✅ All relationships with referential integrity
- ✅ 15 prisoners with complete records
- ✅ 7 guards assigned to cells
- ✅ 4 staff members in kitchens
- ✅ Crime history for each prisoner
- ✅ Visitor logs
- ✅ Emergency tracking
- ✅ Backup personnel assignments

You can create queries, forms, and reports to view and analyze this data in any way you need!
