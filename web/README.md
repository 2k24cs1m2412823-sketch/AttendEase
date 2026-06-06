# AttendEase — Web Dashboard

> React.js + Tailwind CSS admin panel for teachers and administrators.

## Setup

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build
```

## Features
- **Real-Time Classroom Grid** — Live seat map via Firestore snapshots
- **Attendance Logs** — Searchable, filterable table
- **Damage Incident Feed** — Photo evidence with suspect flagging
- **Export** — Download reports as Excel or PDF

## Tech
- **Vite + React + TypeScript**
- **Tailwind CSS v4** for styling
- **Firebase JS SDK** for real-time data
- **xlsx** for Excel export
- **jspdf + jspdf-autotable** for PDF export
- **recharts** for analytics charts

## Folder Structure
```
src/
├── components/    # Reusable UI components
├── pages/         # Route-level pages
├── hooks/         # Custom React hooks (useFirestore, etc.)
├── services/      # Firebase configuration & API calls
└── App.tsx        # Root component with routing
```

## Note
Run `npx -y create-vite@latest ./ -- --template react-ts` to initialize Vite,
then install the dependencies listed in the parent guide.
