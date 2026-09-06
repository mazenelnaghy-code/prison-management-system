# Prison Management System

A role-based prison management system, built in two parts:

1. **A web application** — Node.js + Express backend with a vanilla-JavaScript frontend, session auth, and three permission levels.
2. **A relational database design** — a fully populated Microsoft Access database (13 tables, 14 enforced relationships), reproducible from a script, plus an ER diagram, SQL schema, and CSV data files.

---

## Quick start (web app)

Requires Node.js 16+.

```bash
npm install
npm run init     # generates data.json from the seed data
npm start        # http://localhost:3000
```

### Test accounts

| Role  | Username        | Password      | Sees |
|-------|-----------------|---------------|------|
| Admin | `admin`         | `password123` | Everything |
| Staff | `sarah.johnson` | `password123` | Kitchen / dining facility |
| Guard | `john.martinez` | `password123` | Prisoners and emergencies in their assigned block |

> Demo credentials only. Authentication is SHA-256 + sessions — see [Security notes](#security-notes).

---

## Features

### Role-based access control
- **Admin** — full access to prisoners, guards, staff, cells, emergencies, visits, and kitchens.
- **Guard** — restricted to the cell block they are assigned to.
- **Staff** — restricted to their kitchen/dining facility.

Roles are enforced on the API, not just hidden in the menu: every endpoint is wrapped in `requireAuth` and `requireRole`, and record queries are filtered by the caller's assigned cell or facility.

### Modules
- **Prisoners** — inmate records, sentences, criminal history, visit history
- **Cells** — capacity and live occupancy rates per block
- **Guards & staff** — shift assignments per cell block / kitchen
- **Emergencies** — incident log with assigned backup personnel
- **Visitors** — visit records linked to prisoners and relationships
- **Kitchens** — dining facilities and their staff rosters

### Sample data
15 prisoners across 5 cell blocks · 7 guards · 4 kitchen staff in 2 kitchens · 8 crime categories · 4 emergency events · 6 visitors · 4 backup personnel.

---

## API

| Method | Endpoint | Access |
|--------|----------|--------|
| `POST` | `/api/login` | public |
| `POST` | `/api/logout` | authenticated |
| `GET`  | `/api/user` | authenticated |
| `GET`  | `/api/dashboard/stats` | all roles (response varies by role) |
| `GET`  | `/api/prisoners` | Admin, Guard (Guard sees own block) |
| `GET`  | `/api/prisoners/:id` | Admin, Guard |
| `GET`  | `/api/guards` | Admin |
| `GET`  | `/api/staff` | Admin |
| `GET`  | `/api/cells` | Admin, Guard |
| `GET`  | `/api/emergencies` | Admin, Guard |
| `GET`  | `/api/visits` | Admin |
| `GET`  | `/api/kitchens` | Admin, Staff |

---

## Database design

The `database/` folder holds the relational model the application is based on.

| File | What it is |
|------|-----------|
| `PrisonManagement.accdb` | The finished Access database — 13 tables, 14 relationships with referential integrity, fully populated |
| `Build-PrisonDB.ps1` | Rebuilds that database from scratch via DAO: tables, keys, sample data, and relationships laid out in the Relationships diagram |
| `PrisonManagement_Complete.sql` | The schema and sample data as SQL |
| `prison_ER_schema.html` / `.pdf` | Entity-relationship diagram |
| `ACCESS_SETUP_GUIDE.md` | Step-by-step guide to building the database by hand in Access |
| `csv/` | One CSV per table, for importing the data into any other database |

Rebuild the Access database (Windows, with the Access Database Engine installed):

```powershell
powershell -ExecutionPolicy Bypass -File database\Build-PrisonDB.ps1
```

### Schema

```
Cell ──┬─< Prisoners ──< PrisonerCrime >── Crime
       │        └──────< Visits >────────── Visitors
       ├─< Guards
       └─< Emergencies ──< EmergencyBackup >── BackupForces

Kitchen ─< Staff

Users ── (Admin | Staff → StaffID | Guard → GuardID)
```

Junction tables (`PrisonerCrime`, `Visits`, `EmergencyBackup`) resolve the three many-to-many relationships: a prisoner can have several crimes, several visitors, and an emergency can call in several backup units.

---

## Project structure

```
prison-management-system/
├── server.js               # Express server, auth, and all API endpoints
├── init-data.js            # Seeds data.json
├── data.json               # Application data store
├── public/
│   ├── index.html          # Single-page frontend
│   ├── app.js              # Frontend logic and rendering
│   └── styles.css          # Styling
└── database/               # Access database, ER diagram, SQL schema, CSVs
```

---

## Tech stack

- **Backend** — Node.js, Express, express-session
- **Frontend** — vanilla JavaScript, no framework
- **Application store** — JSON file (portable, no install step)
- **Database design** — Microsoft Access / DAO, with SQL and CSV exports

---

## Security notes

This is a coursework/demo system. Passwords are hashed with SHA-256 and the session secret is committed in source. For real use it would need bcrypt or Argon2, HTTPS, a secret loaded from the environment, and a proper database engine rather than a JSON file.

---

## License

MIT
