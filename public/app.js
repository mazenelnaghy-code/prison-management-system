// Application state
let currentUser = null;
let currentView = 'overview';

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
  checkAuth();
  setupEventListeners();
});

function setupEventListeners() {
  // Login form
  document.getElementById('login-form').addEventListener('submit', handleLogin);
  
  // Logout button
  document.getElementById('logout-btn').addEventListener('click', handleLogout);
  
  // Menu navigation
  document.querySelectorAll('.menu a').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const view = e.target.dataset.view;
      if (view) {
        navigateTo(view);
      }
    });
  });
}

async function checkAuth() {
  try {
    const response = await fetch('/api/user');
    if (response.ok) {
      currentUser = await response.json();
      showDashboard();
    } else {
      showLogin();
    }
  } catch (error) {
    showLogin();
  }
}

async function handleLogin(e) {
  e.preventDefault();
  
  const username = document.getElementById('username').value;
  const password = document.getElementById('password').value;
  const errorEl = document.getElementById('login-error');
  
  try {
    const response = await fetch('/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password })
    });
    
    if (response.ok) {
      const data = await response.json();
      currentUser = data.user;
      errorEl.textContent = '';
      showDashboard();
    } else {
      errorEl.textContent = 'Invalid username or password';
    }
  } catch (error) {
    errorEl.textContent = 'Login failed. Please try again.';
  }
}

async function handleLogout() {
  await fetch('/api/logout', { method: 'POST' });
  currentUser = null;
  showLogin();
}

function showLogin() {
  document.getElementById('login-screen').classList.add('active');
  document.getElementById('dashboard-screen').classList.remove('active');
}

function showDashboard() {
  document.getElementById('login-screen').classList.remove('active');
  document.getElementById('dashboard-screen').classList.add('active');
  
  document.getElementById('user-name').textContent = currentUser.username;
  document.getElementById('user-role').textContent = currentUser.role;
  
  setupMenuForRole();
  navigateTo('overview');
}

function setupMenuForRole() {
  const role = currentUser.role;
  
  // Show/hide menu items based on role
  const menuItems = {
    'menu-prisoners': ['Admin', 'Guard'],
    'menu-guards': ['Admin'],
    'menu-staff': ['Admin'],
    'menu-cells': ['Admin', 'Guard'],
    'menu-emergencies': ['Admin', 'Guard'],
    'menu-visits': ['Admin'],
    'menu-kitchens': ['Admin', 'Staff']
  };
  
  Object.entries(menuItems).forEach(([id, roles]) => {
    const el = document.getElementById(id);
    if (el) {
      el.style.display = roles.includes(role) ? 'block' : 'none';
    }
  });
}

async function navigateTo(view) {
  currentView = view;
  
  // Update active menu item
  document.querySelectorAll('.menu a').forEach(link => {
    link.classList.remove('active');
    if (link.dataset.view === view) {
      link.classList.add('active');
    }
  });
  
  const content = document.getElementById('main-content');
  content.innerHTML = '<div class="loading">Loading...</div>';
  
  switch (view) {
    case 'overview':
      await renderOverview();
      break;
    case 'prisoners':
      await renderPrisoners();
      break;
    case 'guards':
      await renderGuards();
      break;
    case 'staff':
      await renderStaff();
      break;
    case 'cells':
      await renderCells();
      break;
    case 'emergencies':
      await renderEmergencies();
      break;
    case 'visits':
      await renderVisits();
      break;
    case 'kitchens':
      await renderKitchens();
      break;
  }
}

async function renderOverview() {
  const stats = await fetch('/api/dashboard/stats').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Dashboard Overview</h2>';
  
  if (currentUser.role === 'Admin') {
    html += `
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Total Prisoners</h3>
          <div class="stat-value">${stats.totalPrisoners}</div>
        </div>
        <div class="stat-card">
          <h3>Total Cells</h3>
          <div class="stat-value">${stats.totalCells}</div>
        </div>
        <div class="stat-card">
          <h3>Total Guards</h3>
          <div class="stat-value">${stats.totalGuards}</div>
        </div>
        <div class="stat-card">
          <h3>Total Staff</h3>
          <div class="stat-value">${stats.totalStaff}</div>
        </div>
        <div class="stat-card">
          <h3>Recent Emergencies (7d)</h3>
          <div class="stat-value">${stats.recentEmergencies}</div>
        </div>
        <div class="stat-card">
          <h3>Upcoming Visits</h3>
          <div class="stat-value">${stats.upcomingVisits}</div>
        </div>
      </div>
      <p>Welcome, Administrator. You have full access to all system functions.</p>
    `;
  } else if (currentUser.role === 'Guard') {
    html += `
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Assigned Cell</h3>
          <div class="stat-value">${stats.assignedCell || 'N/A'}</div>
        </div>
        <div class="stat-card">
          <h3>Prisoners in Cell</h3>
          <div class="stat-value">${stats.prisonersInCell || 0}</div>
        </div>
        <div class="stat-card">
          <h3>Cell Capacity</h3>
          <div class="stat-value">${stats.cellCapacity || 0}</div>
        </div>
        <div class="stat-card">
          <h3>Current Occupancy</h3>
          <div class="stat-value">${stats.cellOccupancy || 0}</div>
        </div>
      </div>
      <p>Welcome, Guard. You can view prisoners and emergencies in your assigned cell.</p>
    `;
  } else if (currentUser.role === 'Staff') {
    html += `
      <div class="stats-grid">
        <div class="stat-card">
          <h3>Assigned Kitchen</h3>
          <div class="stat-value" style="font-size: 24px;">${stats.assignedKitchen || 'N/A'}</div>
        </div>
        <div class="stat-card">
          <h3>Kitchen Capacity</h3>
          <div class="stat-value">${stats.kitchenCapacity || 0}</div>
        </div>
      </div>
      <p>Welcome, Staff Member. You can view kitchen and dining information.</p>
    `;
  }
  
  content.innerHTML = html;
}

async function renderPrisoners() {
  const prisoners = await fetch('/api/prisoners').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Prisoners</h2>';
  
  if (prisoners.length === 0) {
    html += '<div class="empty-state"><h3>No prisoners found</h3></div>';
  } else {
    html += `
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Age</th>
            <th>Gender</th>
            <th>Cell Block</th>
            <th>Crimes</th>
            <th>Sentence</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    prisoners.forEach(p => {
      html += `
        <tr onclick="viewPrisonerDetail(${p.PrisonerID})">
          <td>${p.PrisonerID}</td>
          <td>${p.FullName}</td>
          <td>${p.Age}</td>
          <td>${p.Gender}</td>
          <td>${p.BlockName || 'Unassigned'}</td>
          <td>${p.Crimes || 'None'}</td>
          <td>${p.SentenceYears} years</td>
          <td><span class="status-badge status-${p.Status.toLowerCase()}">${p.Status}</span></td>
        </tr>
      `;
    });
    
    html += '</tbody></table>';
  }
  
  content.innerHTML = html;
}

async function viewPrisonerDetail(id) {
  const prisoner = await fetch(`/api/prisoners/${id}`).then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = `
    <div class="detail-header">
      <h2>Prisoner Details</h2>
      <button class="btn btn-back" onclick="navigateTo('prisoners')">← Back to List</button>
    </div>
    
    <div class="detail-section">
      <h3>Personal Information</h3>
      <div class="detail-grid">
        <div class="detail-item">
          <label>ID</label>
          <div class="value">${prisoner.PrisonerID}</div>
        </div>
        <div class="detail-item">
          <label>Full Name</label>
          <div class="value">${prisoner.FullName}</div>
        </div>
        <div class="detail-item">
          <label>Age</label>
          <div class="value">${prisoner.Age}</div>
        </div>
        <div class="detail-item">
          <label>Gender</label>
          <div class="value">${prisoner.Gender}</div>
        </div>
        <div class="detail-item">
          <label>Cell Block</label>
          <div class="value">${prisoner.BlockName || 'Unassigned'}</div>
        </div>
        <div class="detail-item">
          <label>Status</label>
          <div class="value"><span class="status-badge status-${prisoner.Status.toLowerCase()}">${prisoner.Status}</span></div>
        </div>
      </div>
    </div>
    
    <div class="detail-section">
      <h3>Sentence Information</h3>
      <div class="detail-grid">
        <div class="detail-item">
          <label>Sentence Length</label>
          <div class="value">${prisoner.SentenceYears} years</div>
        </div>
        <div class="detail-item">
          <label>Admission Date</label>
          <div class="value">${prisoner.AdmissionDate}</div>
        </div>
        <div class="detail-item">
          <label>Release Date</label>
          <div class="value">${prisoner.ReleaseDate}</div>
        </div>
      </div>
    </div>
    
    <div class="detail-section">
      <h3>Criminal Record</h3>
  `;
  
  if (prisoner.crimes && prisoner.crimes.length > 0) {
    html += '<table><thead><tr><th>Crime</th><th>Severity</th><th>Date</th></tr></thead><tbody>';
    prisoner.crimes.forEach(crime => {
      html += `
        <tr>
          <td>${crime.CrimeName}</td>
          <td><span class="status-badge severity-${crime.SeverityLevel.toLowerCase()}">${crime.SeverityLevel}</span></td>
          <td>${crime.CrimeDate}</td>
        </tr>
      `;
    });
    html += '</tbody></table>';
  } else {
    html += '<p>No crimes recorded.</p>';
  }
  
  html += '</div><div class="detail-section"><h3>Visit History</h3>';
  
  if (prisoner.visits && prisoner.visits.length > 0) {
    html += '<table><thead><tr><th>Visitor</th><th>Relation</th><th>Date</th></tr></thead><tbody>';
    prisoner.visits.forEach(visit => {
      html += `
        <tr>
          <td>${visit.VisitorName}</td>
          <td>${visit.RelationToPrisoner}</td>
          <td>${new Date(visit.VisitDate).toLocaleString()}</td>
        </tr>
      `;
    });
    html += '</tbody></table>';
  } else {
    html += '<p>No visits recorded.</p>';
  }
  
  html += '</div>';
  
  content.innerHTML = html;
}

async function renderGuards() {
  const guards = await fetch('/api/guards').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Guards</h2>';
  html += `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Phone</th>
          <th>Shift</th>
          <th>Assigned Cell</th>
        </tr>
      </thead>
      <tbody>
  `;
  
  guards.forEach(g => {
    html += `
      <tr>
        <td>${g.GuardID}</td>
        <td>${g.FullName}</td>
        <td>${g.Phone}</td>
        <td>${g.ShiftTime}</td>
        <td>${g.BlockName || 'Unassigned'}</td>
      </tr>
    `;
  });
  
  html += '</tbody></table>';
  content.innerHTML = html;
}

async function renderStaff() {
  const staff = await fetch('/api/staff').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Staff Members</h2>';
  html += `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Job Type</th>
          <th>Phone</th>
          <th>Shift</th>
          <th>Kitchen</th>
        </tr>
      </thead>
      <tbody>
  `;
  
  staff.forEach(s => {
    html += `
      <tr>
        <td>${s.StaffID}</td>
        <td>${s.FullName}</td>
        <td>${s.JobType}</td>
        <td>${s.Phone}</td>
        <td>${s.ShiftTime}</td>
        <td>${s.RestaurantName || 'Unassigned'}</td>
      </tr>
    `;
  });
  
  html += '</tbody></table>';
  content.innerHTML = html;
}

async function renderCells() {
  const cells = await fetch('/api/cells').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Prison Cells</h2>';
  html += `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Block Name</th>
          <th>Capacity</th>
          <th>Occupied</th>
          <th>Guards Assigned</th>
          <th>Occupancy Rate</th>
        </tr>
      </thead>
      <tbody>
  `;
  
  cells.forEach(c => {
    const rate = Math.round((c.CurrentOccupied / c.Capacity) * 100);
    html += `
      <tr>
        <td>${c.CellID}</td>
        <td>${c.BlockName}</td>
        <td>${c.Capacity}</td>
        <td>${c.CurrentOccupied}</td>
        <td>${c.GuardCount}</td>
        <td>${rate}%</td>
      </tr>
    `;
  });
  
  html += '</tbody></table>';
  content.innerHTML = html;
}

async function renderEmergencies() {
  const emergencies = await fetch('/api/emergencies').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Emergency Events</h2>';
  
  if (emergencies.length === 0) {
    html += '<div class="empty-state"><h3>No emergencies recorded</h3></div>';
  } else {
    html += `
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Type</th>
            <th>Date/Time</th>
            <th>Location</th>
            <th>Cell Block</th>
            <th>Backup Personnel</th>
          </tr>
        </thead>
        <tbody>
    `;
    
    emergencies.forEach(e => {
      html += `
        <tr>
          <td>${e.EmergencyID}</td>
          <td>${e.EmergencyType}</td>
          <td>${new Date(e.EmergencyDate).toLocaleString()}</td>
          <td>${e.Location}</td>
          <td>${e.BlockName || 'N/A'}</td>
          <td>${e.BackupPersonnel || 'None'}</td>
        </tr>
      `;
    });
    
    html += '</tbody></table>';
  }
  
  content.innerHTML = html;
}

async function renderVisits() {
  const visits = await fetch('/api/visits').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Visitor Log</h2>';
  html += `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Prisoner</th>
          <th>Visitor</th>
          <th>Relation</th>
          <th>Visit Date</th>
        </tr>
      </thead>
      <tbody>
  `;
  
  visits.forEach(v => {
    html += `
      <tr>
        <td>${v.VisitID}</td>
        <td>${v.PrisonerName}</td>
        <td>${v.VisitorName}</td>
        <td>${v.RelationToPrisoner}</td>
        <td>${new Date(v.VisitDate).toLocaleString()}</td>
      </tr>
    `;
  });
  
  html += '</tbody></table>';
  content.innerHTML = html;
}

async function renderKitchens() {
  const kitchens = await fetch('/api/kitchens').then(r => r.json());
  const content = document.getElementById('main-content');
  
  let html = '<h2>Kitchen Facilities</h2>';
  html += `
    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Capacity</th>
          <th>Staff Count</th>
        </tr>
      </thead>
      <tbody>
  `;
  
  kitchens.forEach(k => {
    html += `
      <tr>
        <td>${k.RestaurantID}</td>
        <td>${k.RestaurantName}</td>
        <td>${k.Capacity} people</td>
        <td>${k.StaffCount}</td>
      </tr>
    `;
  });
  
  html += '</tbody></table>';
  content.innerHTML = html;
}

// Make functions globally accessible
window.navigateTo = navigateTo;
window.viewPrisonerDetail = viewPrisonerDetail;
