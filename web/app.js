/* ═══════════════════════════════════════════════════════ */
/* AttendEase — Dashboard JavaScript                       */
/* ═══════════════════════════════════════════════════════ */

// ── Sample Data ────────────────────────────────────────

const SAMPLE_ATTENDANCE = [
    { id: 'CS-2024-001', name: 'Arjun Patel', room: 'LAB_101', seat: 'A3', time: '10:02 AM', confidence: 98.5, status: 'Present' },
    { id: 'CS-2024-003', name: 'Neha Gupta', room: 'LAB_101', seat: 'A5', time: '10:03 AM', confidence: 97.1, status: 'Present' },
    { id: 'CS-2024-007', name: 'Rohan Mehta', room: 'LAB_101', seat: 'B1', time: '10:04 AM', confidence: 95.8, status: 'Present' },
    { id: 'CS-2024-012', name: 'Ananya Reddy', room: 'LH_201', seat: 'C2', time: '10:01 AM', confidence: 99.2, status: 'Present' },
    { id: 'CS-2024-015', name: 'Priya Singh', room: 'LAB_101', seat: 'B2', time: '10:05 AM', confidence: 96.2, status: 'Present' },
    { id: 'CS-2024-018', name: 'Vikram Joshi', room: 'LH_201', seat: 'D5', time: '10:08 AM', confidence: 94.7, status: 'Present' },
    { id: 'CS-2024-022', name: 'Rahul Kumar', room: 'LH_201', seat: 'C4', time: '—', confidence: 0, status: 'Absent' },
    { id: 'CS-2024-025', name: 'Meera Nair', room: 'LAB_101', seat: 'D3', time: '10:10 AM', confidence: 97.9, status: 'Present' },
    { id: 'CS-2024-031', name: 'Siddharth Rao', room: 'LAB_102', seat: 'A1', time: '10:12 AM', confidence: 93.4, status: 'Present' },
    { id: 'CS-2024-033', name: 'Kavya Sharma', room: 'LAB_102', seat: 'B4', time: '—', confidence: 0, status: 'Absent' },
];

const SEAT_MAP = {
    'A1': 'CS-2024-009', 'A2': null, 'A3': 'CS-2024-001', 'A4': 'CS-2024-011',
    'A5': 'CS-2024-003', 'A6': null,
    'B1': 'CS-2024-007', 'B2': 'CS-2024-015', 'B3': null, 'B4': 'CS-2024-019',
    'B5': 'CS-2024-021', 'B6': 'CS-2024-023',
    'C1': null, 'C2': 'CS-2024-025', 'C3': 'CS-2024-027', 'C4': null,
    'C5': 'CS-2024-029', 'C6': null,
    'D1': 'CS-2024-031', 'D2': 'CS-2024-033', 'D3': 'CS-2024-035', 'D4': null,
    'D5': null, 'D6': 'CS-2024-037',
    'E1': null, 'E2': 'CS-2024-039', 'E3': null, 'E4': 'CS-2024-041',
    'E5': 'CS-2024-043', 'E6': null,
};

const DAMAGED_SEATS = ['C4', 'D5'];

const ACTIVITY_FEED = [
    { id: 'CS-2024-043', text: 'marked present in <strong>LAB_101</strong>, Seat E5', time: 'Just now', color: '#9aa8ff' },
    { id: 'CS-2024-041', text: 'marked present in <strong>LAB_101</strong>, Seat E4', time: '2 min ago', color: '#ec82fb' },
    { id: 'CS-2024-039', text: 'marked present in <strong>LAB_101</strong>, Seat E2', time: '3 min ago', color: '#c29fff' },
    { id: 'CS-2024-037', text: 'reported <strong>damage</strong> on Seat D5', time: '5 min ago', color: '#ff6e84' },
    { id: 'CS-2024-035', text: 'marked present in <strong>LAB_101</strong>, Seat D3', time: '7 min ago', color: '#9aa8ff' },
    { id: 'CS-2024-033', text: 'marked present in <strong>LAB_101</strong>, Seat D2', time: '8 min ago', color: '#ec82fb' },
    { id: 'CS-2024-031', text: 'session started by <strong>Prof. Sharma</strong>', time: '42 min ago', color: '#4ade80' },
    { id: 'CS-2024-029', text: 'marked present in <strong>LAB_101</strong>, Seat C5', time: '10 min ago', color: '#c29fff' },
    { id: 'SYSTEM', text: '<strong>BLE beacon</strong> activated for LAB_101', time: '43 min ago', color: '#747578' },
];

const INCIDENTS = [
    {
        seat: 'A3', room: 'LAB_101', reporter: 'CS-2024-001', reporterName: 'Arjun Patel',
        time: 'Today, 10:02 AM', flag: 'GREEN',
        analysis: 'Damage reported 2 mins after sitting. Classified as pre-existing.'
    },
    {
        seat: 'D5', room: 'LAB_101', reporter: 'CS-2024-037', reporterName: 'Aditi Verma',
        time: 'Today, 10:15 AM', flag: 'RED', suspect: 'CS-2024-019',
        analysis: 'Seat occupied by CS-2024-019 until previous session end. Damage reported 23 mins later by CS-2024-037. Flagged for review.'
    },
    {
        seat: 'B2', room: 'LH_201', reporter: 'CS-2024-015', reporterName: 'Priya Singh',
        time: 'Yesterday, 2:15 PM', flag: 'GREEN',
        analysis: 'Damage reported immediately upon sitting. Pre-existing scratch on desk surface.'
    },
    {
        seat: 'C1', room: 'LAB_102', reporter: 'CS-2024-022', reporterName: 'Rahul Kumar',
        time: 'Yesterday, 11:45 AM', flag: 'RED', suspect: 'CS-2024-044',
        analysis: 'Seat occupied by CS-2024-044 in morning session. Chair leg damage discovered by CS-2024-022 in next session, 45 mins gap.'
    },
    {
        seat: 'E6', room: 'LAB_101', reporter: 'CS-2024-025', reporterName: 'Meera Nair',
        time: 'Mar 22, 9:05 AM', flag: 'GREEN',
        analysis: 'Minor scuff mark reported within 1 min of sitting. Pre-existing.'
    },
];

// ── Init ────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
    setCurrentDate();
    renderSeatGrid();
    renderActivityFeed();
    renderAttendanceTable();
    renderIncidents();
    initThresholdSlider();
});

// ── Login ───────────────────────────────────────────────

function handleLogin(event) {
    event.preventDefault();
    const rollNo = document.getElementById('roll-number').value.trim();
    const password = document.getElementById('password').value;

    if (!rollNo || !password) return;

    const btn = document.getElementById('login-btn');
    btn.innerHTML = '<span class="material-icons-round" style="animation:spin 0.8s linear infinite">progress_activity</span>';

    setTimeout(() => {
        document.getElementById('login-page').classList.remove('active');
        document.getElementById('app-shell').classList.add('active');
        btn.innerHTML = '<span>Sign In</span><span class="material-icons-round">arrow_forward</span>';
    }, 800);
}

function handleLogout() {
    document.getElementById('app-shell').classList.remove('active');
    document.getElementById('login-page').classList.add('active');
    document.getElementById('roll-number').value = '';
    document.getElementById('password').value = '';
}

function togglePassword() {
    const input = document.getElementById('password');
    const icon = document.getElementById('pw-icon');
    if (input.type === 'password') {
        input.type = 'text';
        icon.textContent = 'visibility';
    } else {
        input.type = 'password';
        icon.textContent = 'visibility_off';
    }
}

// ── Navigation ──────────────────────────────────────────

function navigateTo(page) {
    // Update sidebar
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.toggle('active', item.dataset.page === page);
    });

    // Update content
    document.querySelectorAll('.content-page').forEach(p => p.classList.remove('active'));
    const target = document.getElementById(`page-${page}`);
    if (target) target.classList.add('active');
}

// ── Date ────────────────────────────────────────────────

function setCurrentDate() {
    const now = new Date();
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    document.getElementById('current-date').textContent = now.toLocaleDateString('en-IN', options);
}

// ── Seat Grid ───────────────────────────────────────────

function renderSeatGrid() {
    const grid = document.getElementById('seat-grid');
    grid.innerHTML = '';

    const rows = ['A', 'B', 'C', 'D', 'E'];
    const cols = [1, 2, 3, 4, 5, 6];

    rows.forEach(row => {
        cols.forEach(col => {
            const seatId = `${row}${col}`;
            const studentId = SEAT_MAP[seatId];
            const isDamaged = DAMAGED_SEATS.includes(seatId);

            const seat = document.createElement('div');
            seat.className = `seat ${isDamaged ? 'damaged' : studentId ? 'occupied' : 'empty'}`;
            seat.innerHTML = `
                <span class="seat-id">${seatId}</span>
                ${studentId ? `<span class="seat-student">${studentId.split('-').pop()}</span>` : ''}
                ${isDamaged ? '<span class="material-icons-round" style="font-size:14px;margin-top:2px">warning</span>' : ''}
            `;
            seat.title = studentId ? `${seatId}: ${studentId}` : `${seatId}: Empty`;
            grid.appendChild(seat);
        });
    });
}

function updateGrid() {
    renderSeatGrid();
}

// ── Activity Feed ───────────────────────────────────────

function renderActivityFeed() {
    const feed = document.getElementById('activity-feed');
    feed.innerHTML = '';

    ACTIVITY_FEED.forEach(item => {
        const initials = item.id.startsWith('CS') ? item.id.split('-').pop().slice(-2) : '⚡';
        const el = document.createElement('div');
        el.className = 'activity-item';
        el.innerHTML = `
            <div class="activity-avatar" style="background:${item.color}">${initials}</div>
            <div>
                <div class="activity-text"><strong>${item.id}</strong> ${item.text}</div>
                <div class="activity-time">${item.time}</div>
            </div>
        `;
        feed.appendChild(el);
    });
}

// ── Attendance Table ────────────────────────────────────

function renderAttendanceTable(data) {
    const tbody = document.getElementById('attendance-tbody');
    tbody.innerHTML = '';

    const records = data || SAMPLE_ATTENDANCE;

    records.forEach(row => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td><strong>${row.id}</strong></td>
            <td>${row.name}</td>
            <td>${row.room}</td>
            <td>${row.seat}</td>
            <td>${row.time}</td>
            <td>
                ${row.confidence > 0 ? `
                <div class="confidence-bar">
                    <div class="conf-track"><div class="conf-fill" style="width:${row.confidence}%"></div></div>
                    <span>${row.confidence}%</span>
                </div>` : '—'}
            </td>
            <td><span class="status-badge ${row.status.toLowerCase()}">${row.status}</span></td>
        `;
        tbody.appendChild(tr);
    });

    document.getElementById('table-count').textContent = `Showing 1-${records.length} of 127 records`;
}

function filterTable() {
    const search = document.getElementById('search-input').value.toLowerCase();
    const room = document.getElementById('filter-room').value;
    const status = document.getElementById('filter-status').value;

    const filtered = SAMPLE_ATTENDANCE.filter(row => {
        const matchSearch = !search || row.id.toLowerCase().includes(search) || row.name.toLowerCase().includes(search);
        const matchRoom = !room || row.room === room;
        const matchStatus = !status || row.status === status;
        return matchSearch && matchRoom && matchStatus;
    });

    renderAttendanceTable(filtered);
}

// ── Damage Incidents ────────────────────────────────────

function renderIncidents(filter) {
    const feed = document.getElementById('incident-feed');
    feed.innerHTML = '';

    const filtered = filter ? INCIDENTS.filter(i => i.flag === filter) : INCIDENTS;

    filtered.forEach(incident => {
        const card = document.createElement('div');
        card.className = 'glass-card incident-card';
        card.innerHTML = `
            <div class="incident-thumb">
                <span class="material-icons-round">photo_camera</span>
            </div>
            <div class="incident-body">
                <div class="incident-header">
                    <span class="incident-title">Seat ${incident.seat} — ${incident.room}</span>
                    <span class="incident-time">${incident.time}</span>
                </div>
                <div class="incident-reporter">
                    Reported by <strong>${incident.reporterName}</strong> (${incident.reporter})
                </div>
                <span class="incident-flag ${incident.flag.toLowerCase()}">
                    ${incident.flag === 'GREEN' ? '✓ Pre-existing' : '⚠ Suspect Identified'}
                </span>
                ${incident.suspect ? `
                    <div class="incident-suspect">
                        <span class="material-icons-round">person_alert</span>
                        Primary Suspect: <strong>${incident.suspect}</strong>
                    </div>
                ` : ''}
                <div class="incident-analysis" style="${incident.flag === 'GREEN' ? 'border-left-color: #4ade80; background: rgba(74,222,128,0.04)' : ''}">
                    ${incident.analysis}
                </div>
            </div>
        `;
        feed.appendChild(card);
    });
}

function filterDamage() {
    const filter = document.getElementById('damage-filter').value;
    renderIncidents(filter || null);
}

// ── Settings ────────────────────────────────────────────

function initThresholdSlider() {
    const slider = document.getElementById('threshold-slider');
    const display = document.getElementById('threshold-value');
    if (slider && display) {
        slider.addEventListener('input', () => {
            display.textContent = parseFloat(slider.value).toFixed(2);
        });
    }
}

// ── Export ───────────────────────────────────────────────

function exportExcel() {
    // In production: use xlsx library
    const csv = SAMPLE_ATTENDANCE.map(r =>
        `${r.id},${r.name},${r.room},${r.seat},${r.time},${r.confidence},${r.status}`
    ).join('\n');
    const header = 'Student ID,Name,Room,Seat,Time,Confidence,Status\n';
    downloadFile(header + csv, 'attendance_export.csv', 'text/csv');
}

function exportPDF() {
    // In production: use jspdf + autoTable
    alert('PDF export requires jspdf library. In production, this generates a formatted attendance report.');
}

function downloadFile(content, filename, mimeType) {
    const blob = new Blob([content], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    a.click();
    URL.revokeObjectURL(url);
}

function showStartSession() {
    alert('Session creation dialog would open here.\nIn production: select room, subject, seat count → start BLE beacon.');
}

// ── CSS Animation for spinner ───────────────────────────
const style = document.createElement('style');
style.textContent = `@keyframes spin { to { transform: rotate(360deg); } }`;
document.head.appendChild(style);
