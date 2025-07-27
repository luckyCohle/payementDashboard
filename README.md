💳 Payment Dashboard App
A full-stack real-time Payment Dashboard built using NestJS for the backend and Flutter for the frontend.

🔥 Features
🖥️ Backend (NestJS)
REST API for managing payments

JWT-based authentication (/auth/login, /auth/signup)

Role-based access (ADMIN / VIEWER)

Real-time updates via WebSockets (socket.io)

Payment statistics API (/payment/stats)

Filtering & pagination (/payment?status=&method=&page=1)

Payment creation (POST /payment)

Prisma ORM with PostgreSQL

Bonus: Real-time admin/user notifications on payment

📱 Frontend (Flutter)
Login & Signup (with role selection)

Dashboard showing:

Total payments (today/week)

Revenue stats

Failed transactions

Line chart (7-day revenue trend)

Transactions page with filters:

Date range

Payment method

Status

Add Payment form

WebSocket integration for real-time notifications

Secure JWT storage using SharedPreferences

Bottom navigation (like a navbar)

🚀 Local Setup Instructions
⚙️ Prerequisites
Node.js (v18+)

Flutter (v3.10+)

PostgreSQL

Dart

Git

📁 Project Structure
bash
Copy
Edit
paymentDash/
├── backend/              # NestJS backend
└── frontend/             # Flutter frontend
🛠️ Backend Setup
bash
Copy
Edit
cd backend

# 1. Install dependencies
npm install

# 2. Set up .env file
cp .env.example .env
# Add your PostgreSQL DATABASE_URL inside .env

# 3. Setup database
npx prisma migrate dev --name init
npx prisma generate

# 4. Start backend
npm run start:dev
🔌 API Endpoints
Method	Route	Description
POST	/auth/signup	Signup with username, password, role
POST	/auth/login	Login and get JWT
GET	/payment	Get all payments (filters supported)
GET	/payment/stats	Get dashboard stats
GET	/payment/:id	Get single payment
POST	/payment	Create new payment

📱 Frontend Setup
bash
Copy
Edit
cd frontend

# 1. Install dependencies
flutter pub get

# 2. Start emulator or connect real device

# 3. Run the app
flutter run
🛑 Note: If your backend is on a real IP/port, replace http://localhost:3000 with http://<your-local-ip>:3000 in API calls inside Flutter code.

🔔 WebSocket Notifications
Users and Admins are added via socket.emit('addUser', {...}) on login.

Admins receive real-time updates when any user makes a payment.

Send WebSocket events:

makePayment → all relevant users & admins receive notification.

📊 Technologies Used
Backend: NestJS, Prisma, PostgreSQL, WebSockets, JWT, bcrypt

Frontend: Flutter, Provider, Shared Preferences, overlay_support, http

Real-time: socket.io (with platform-socket.io client in Flutter)

✅ Todo / Improvements
Export CSV feature (backend route + frontend button)

Push notifications with Expo

Tests with Jest & Supertest

Dashboard chart enhancements

👨‍💻 Author
Aayush Yadav

