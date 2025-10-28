# Expense Tracker Backend API

Backend API untuk aplikasi Expense Tracker Flutter.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Jalankan server:
```bash
npm start
# atau untuk development mode
npm run dev
```

3. Server akan berjalan di `http://localhost:3000`

## API Endpoints

### Users
- `GET /api/users/:id` - Get user by ID
- `GET /api/users/username/:username` - Get user by username
- `POST /api/users` - Register new user

### Categories
- `GET /api/categories` - Get all categories
- `POST /api/categories` - Create category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category

### Expenses
- `GET /api/expenses` - Get all expenses
- `GET /api/expenses/user/:userId` - Get expenses by user ID
- `GET /api/expenses/:id` - Get expense by ID
- `POST /api/expenses` - Create expense
- `PUT /api/expenses/:id` - Update expense
- `DELETE /api/expenses/:id` - Delete expense

### Statistics
- `GET /api/statistics/:userId` - Get statistics for a user

### Utilities
- `POST /api/setup-categories` - Setup default categories
- `GET /api/health` - Health check

## Notes

- Data disimpan in-memory (hilang setelah restart server)
- Untuk production, gunakan database seperti PostgreSQL atau MongoDB


