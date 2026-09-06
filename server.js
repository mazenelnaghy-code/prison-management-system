import express from 'express';
import session from 'express-session';
import crypto from 'crypto';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load data
let data = JSON.parse(fs.readFileSync('data.json', 'utf8'));

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));

app.use(session({
  secret: 'prison-management-secret-key-2024',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 24 * 60 * 60 * 1000 }
}));

function requireAuth(req, res, next) {
  if (!req.session.user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.session.user || !roles.includes(req.session.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

// Login endpoint
app.post('/api/login', (req, res) => {
  const { username, password } = req.body;
  const user = data.users.find(u => u.Username === username);
  
  if (!user || user.Password !== hashPassword(password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  req.session.user = {
    id: user.UserID,
    username: user.Username,
    role: user.Role,
    staffId: user.StaffID,
    guardId: user.GuardID
  };
  
  res.json({ success: true, user: req.session.user });
});

app.post('/api/logout', (req, res) => {
  req.session.destroy();
  res.json({ success: true });
});

app.get('/api/user', requireAuth, (req, res) => {
  res.json(req.session.user);
});

// Dashboard stats
app.get('/api/dashboard/stats', requireAuth, (req, res) => {
  const stats = {};
  
  if (req.session.user.role === 'Admin') {
    stats.totalPrisoners = data.prisoners.filter(p => p.Status === 'Active').length;
    stats.totalCells = data.cells.length;
    stats.totalGuards = data.guards.length;
    stats.totalStaff = data.staff.length;
    
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    stats.recentEmergencies = data.emergencies.filter(e => new Date(e.EmergencyDate) >= weekAgo).length;
    
    const now = new Date();
    stats.upcomingVisits = data.visits.filter(v => new Date(v.VisitDate) >= now).length;
  } else if (req.session.user.role === 'Guard') {
    const guard = data.guards.find(g => g.GuardID === req.session.user.guardId);
    if (guard && guard.CellID) {
      stats.assignedCell = guard.CellID;
      stats.prisonersInCell = data.prisoners.filter(p => p.CellID === guard.CellID && p.Status === 'Active').length;
      const cell = data.cells.find(c => c.CellID === guard.CellID);
      stats.cellCapacity = cell?.Capacity || 0;
      stats.cellOccupancy = cell?.Occupied || 0;
    }
  } else if (req.session.user.role === 'Staff') {
    const staff = data.staff.find(s => s.StaffID === req.session.user.staffId);
    if (staff && staff.RestaurantID) {
      const kitchen = data.kitchens.find(k => k.RestaurantID === staff.RestaurantID);
      stats.assignedKitchen = kitchen?.RestaurantName || 'N/A';
      stats.kitchenCapacity = kitchen?.Capacity || 0;
    }
  }
  
  res.json(stats);
});

// Prisoners endpoints
app.get('/api/prisoners', requireAuth, requireRole('Admin', 'Guard'), (req, res) => {
  let prisoners = data.prisoners.map(p => {
    const cell = data.cells.find(c => c.CellID === p.CellID);
    const crimes = data.prisonerCrimes
      .filter(pc => pc.PrisonerID === p.PrisonerID)
      .map(pc => data.crimes.find(c => c.CrimeID === pc.CrimeID))
      .filter(c => c)
      .map(c => c.CrimeName)
      .join(', ');
    
    return {
      ...p,
      BlockName: cell?.BlockName,
      Crimes: crimes
    };
  });
  
  if (req.session.user.role === 'Guard') {
    const guard = data.guards.find(g => g.GuardID === req.session.user.guardId);
    if (guard && guard.CellID) {
      prisoners = prisoners.filter(p => p.CellID === guard.CellID);
    }
  }
  
  res.json(prisoners);
});

app.get('/api/prisoners/:id', requireAuth, requireRole('Admin', 'Guard'), (req, res) => {
  const prisoner = data.prisoners.find(p => p.PrisonerID === parseInt(req.params.id));
  if (!prisoner) {
    return res.status(404).json({ error: 'Prisoner not found' });
  }
  
  const cell = data.cells.find(c => c.CellID === prisoner.CellID);
  const crimes = data.prisonerCrimes
    .filter(pc => pc.PrisonerID === prisoner.PrisonerID)
    .map(pc => {
      const crime = data.crimes.find(c => c.CrimeID === pc.CrimeID);
      return { ...crime, CrimeDate: pc.CrimeDate };
    });
  
  const visits = data.visits
    .filter(v => v.PrisonerID === prisoner.PrisonerID)
    .map(v => {
      const visitor = data.visitors.find(vis => vis.VisitorID === v.VisitorID);
      return {
        ...v,
        VisitorName: visitor?.FullName,
        RelationToPrisoner: visitor?.RelationToPrisoner
      };
    });
  
  res.json({
    ...prisoner,
    BlockName: cell?.BlockName,
    crimes,
    visits
  });
});

// Guards endpoints
app.get('/api/guards', requireAuth, requireRole('Admin'), (req, res) => {
  const guards = data.guards.map(g => {
    const cell = data.cells.find(c => c.CellID === g.CellID);
    return { ...g, BlockName: cell?.BlockName };
  });
  res.json(guards);
});

// Staff endpoints
app.get('/api/staff', requireAuth, requireRole('Admin'), (req, res) => {
  const staff = data.staff.map(s => {
    const kitchen = data.kitchens.find(k => k.RestaurantID === s.RestaurantID);
    return { ...s, RestaurantName: kitchen?.RestaurantName };
  });
  res.json(staff);
});

// Cells endpoints
app.get('/api/cells', requireAuth, requireRole('Admin', 'Guard'), (req, res) => {
  const cells = data.cells.map(c => ({
    ...c,
    CurrentOccupied: data.prisoners.filter(p => p.CellID === c.CellID && p.Status === 'Active').length,
    GuardCount: data.guards.filter(g => g.CellID === c.CellID).length
  }));
  res.json(cells);
});

// Emergencies endpoints
app.get('/api/emergencies', requireAuth, requireRole('Admin', 'Guard'), (req, res) => {
  let emergencies = data.emergencies.map(e => {
    const cell = e.CellID ? data.cells.find(c => c.CellID === e.CellID) : null;
    const backup = data.emergencyBackup
      .filter(eb => eb.EmergencyID === e.EmergencyID)
      .map(eb => data.backupForces.find(b => b.BackupID === eb.BackupID))
      .filter(b => b)
      .map(b => b.FullName)
      .join(', ');
    
    return {
      ...e,
      BlockName: cell?.BlockName,
      BackupPersonnel: backup
    };
  });
  
  if (req.session.user.role === 'Guard') {
    const guard = data.guards.find(g => g.GuardID === req.session.user.guardId);
    if (guard && guard.CellID) {
      emergencies = emergencies.filter(e => e.CellID === guard.CellID || e.CellID === null);
    }
  }
  
  emergencies.sort((a, b) => new Date(b.EmergencyDate) - new Date(a.EmergencyDate));
  res.json(emergencies.slice(0, 50));
});

// Visits endpoints
app.get('/api/visits', requireAuth, requireRole('Admin'), (req, res) => {
  const visits = data.visits.map(v => {
    const prisoner = data.prisoners.find(p => p.PrisonerID === v.PrisonerID);
    const visitor = data.visitors.find(vis => vis.VisitorID === v.VisitorID);
    return {
      ...v,
      PrisonerName: prisoner?.FullName,
      VisitorName: visitor?.FullName,
      RelationToPrisoner: visitor?.RelationToPrisoner
    };
  });
  
  visits.sort((a, b) => new Date(b.VisitDate) - new Date(a.VisitDate));
  res.json(visits.slice(0, 100));
});

// Kitchen endpoints
app.get('/api/kitchens', requireAuth, requireRole('Admin', 'Staff'), (req, res) => {
  const kitchens = data.kitchens.map(k => ({
    ...k,
    StaffCount: data.staff.filter(s => s.RestaurantID === k.RestaurantID).length
  }));
  res.json(kitchens);
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`\n🏛️  Prison Management System`);
  console.log(`📍 Running at: http://localhost:${PORT}`);
  console.log(`\n🔑 Login credentials:`);
  console.log(`   Admin: admin / password123`);
  console.log(`   Staff: sarah.johnson / password123`);
  console.log(`   Guard: john.martinez / password123\n`);
});
