// Backend API untuk Aplikasi Expense Tracker
// Jalankan dengan: node server.js

const express = require('express');
const cors = require('cors');
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage (untuk demo, bisa diganti dengan database)
let users = [];
let categories = [];
let expenses = [];
let userIdCounter = 1;
let categoryIdCounter = 1;
let expenseIdCounter = 1;

// ===== USER ENDPOINTS =====

// Get user by username
app.get('/api/users/username/:username', (req, res) => {
  const username = req.params.username;
  const user = users.find(u => u.username === username);
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

// Get user by ID
app.get('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const user = users.find(u => u.userId === id);
  if (user) {
    res.json(user);
  } else {
    res.status(404).json({ error: 'User not found' });
  }
});

// Create user (register)
app.post('/api/users', (req, res) => {
  const { fullname, email, username, password } = req.body;
  
  if (!fullname || !email || !username || !password) {
    return res.status(400).json({ error: 'All fields required' });
  }
  
  // Cek duplicate username
  if (users.find(u => u.username === username)) {
    return res.status(400).json({ error: 'Username already exists' });
  }
  
  const newUser = {
    userId: userIdCounter++,
    fullname,
    email,
    username,
    password,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  
  users.push(newUser);
  console.log(`✅ User created: ${username}`);
  res.status(201).json(newUser);
});

// ===== CATEGORY ENDPOINTS =====

// Get all categories
app.get('/api/categories', (req, res) => {
  console.log(`📋 GET /api/categories - Returning ${categories.length} categories`);
  res.json(categories);
});

// Create category
app.post('/api/categories', (req, res) => {
  const { categoryName } = req.body;
  
  if (!categoryName) {
    return res.status(400).json({ error: 'Category name required' });
  }
  
  const newCategory = {
    categoryId: categoryIdCounter++,
    categoryName,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };
  
  categories.push(newCategory);
  console.log(`✅ Category created: ${categoryName}`);
  res.status(201).json(newCategory);
});

// Update category
app.put('/api/categories/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { categoryName } = req.body;
  
  const index = categories.findIndex(c => c.categoryId === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Category not found' });
  }
  
  categories[index] = {
    ...categories[index],
    categoryName,
    updatedAt: new Date().toISOString(),
  };
  
  console.log(`✅ Category updated: ${id}`);
  res.json(categories[index]);
});

// Delete category
app.delete('/api/categories/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = categories.findIndex(c => c.categoryId === id);
  
  if (index === -1) {
    return res.status(404).json({ error: 'Category not found' });
  }
  
  categories.splice(index, 1);
  console.log(`✅ Category deleted: ${id}`);
  res.json({ message: 'Deleted successfully' });
});

// ===== EXPENSE ENDPOINTS =====

// Get all expenses
app.get('/api/expenses', (req, res) => {
  console.log(`💰 GET /api/expenses - Returning ${expenses.length} expenses`);
  res.json(expenses);
});

// Get expenses by user ID
app.get('/api/expenses/user/:userId', (req, res) => {
  const userId = parseInt(req.params.userId);
  const userExpenses = expenses.filter(e => e.userId === userId);
  console.log(`💰 GET /api/expenses/user/${userId} - Returning ${userExpenses.length} expenses`);
  res.json(userExpenses);
});

// Get expense by ID
app.get('/api/expenses/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const expense = expenses.find(e => e.expenseId === id);
  if (expense) {
    res.json(expense);
  } else {
    res.status(404).json({ error: 'Expense not found' });
  }
});

// Create expense
app.post('/api/expenses', (req, res) => {
  const { userId, title, categoryId, amount, date, description } = req.body;
  
  if (!userId || !title || !categoryId || !amount || !date || !description) {
    return res.status(400).json({ error: 'All fields required' });
  }
  
  const newExpense = {
    expenseId: expenseIdCounter++,
    userId,
    title,
    categoryId,
    amount,
    date,
    description,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    deletedAt: null,
  };
  
  expenses.push(newExpense);
  console.log(`✅ Expense created: ${title} by user ${userId}`);
  res.status(201).json(newExpense);
});

// Update expense
app.put('/api/expenses/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { userId, title, categoryId, amount, date, description } = req.body;
  
  const index = expenses.findIndex(e => e.expenseId === id);
  if (index === -1) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  
  expenses[index] = {
    ...expenses[index],
    userId,
    title,
    categoryId,
    amount,
    date,
    description,
    updatedAt: new Date().toISOString(),
  };
  
  console.log(`✅ Expense updated: ${id}`);
  res.json(expenses[index]);
});

// Delete expense
app.delete('/api/expenses/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const index = expenses.findIndex(e => e.expenseId === id);
  
  if (index === -1) {
    return res.status(404).json({ error: 'Expense not found' });
  }
  
  expenses.splice(index, 1);
  console.log(`✅ Expense deleted: ${id}`);
  res.json({ message: 'Deleted successfully' });
});

// ===== STATISTICS ENDPOINTS =====

// Get statistics for a user
app.get('/api/statistics/:userId', (req, res) => {
  const userId = parseInt(req.params.userId);
  const userExpenses = expenses.filter(e => e.userId === userId);
  
  // Calculate total expense
  const totalExpense = userExpenses.reduce((sum, e) => sum + e.amount, 0);
  
  // Calculate expenses by category
  const expensesByCategory = {};
  userExpenses.forEach(expense => {
    const categoryName = categories.find(c => c.categoryId === expense.categoryId)?.categoryName || 'Unknown';
    expensesByCategory[categoryName] = (expensesByCategory[categoryName] || 0) + expense.amount;
  });
  
  // Calculate monthly expenses
  const expensesByMonth = {};
  userExpenses.forEach(expense => {
    const month = new Date(expense.date).toISOString().substring(0, 7); // YYYY-MM
    expensesByMonth[month] = (expensesByMonth[month] || 0) + expense.amount;
  });
  
  const stats = {
    totalExpenses: userExpenses.length,
    totalAmount: totalExpense,
    expensesByCategory,
    expensesByMonth,
    recentExpenses: userExpenses
      .sort((a, b) => new Date(b.date) - new Date(a.date))
      .slice(0, 5)
  };
  
  console.log(`📊 GET /api/statistics/${userId}`);
  res.json(stats);
});

// ===== UTILITY ENDPOINTS =====

// Setup default categories
app.post('/api/setup-categories', (req, res) => {
  const defaultCategories = [
    'Food',
    'Transportation',
    'Utility',
    'Entertainment',
    'Self Care'
  ];
  
  defaultCategories.forEach(name => {
    categories.push({
      categoryId: categoryIdCounter++,
      categoryName: name,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      deletedAt: null,
    });
  });
  
  console.log(`✅ Created ${defaultCategories.length} default categories`);
  res.json({ 
    message: `${defaultCategories.length} default categories created`,
    categories: categories
  });
});

// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok',
    users: users.length,
    categories: categories.length,
    expenses: expenses.length
  });
});

// Start server
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`
🚀 ===========================================
   Expense Tracker API Server Running!
   ===========================================
   
   📍 URL: http://localhost:${PORT}
   📖 Health: http://localhost:${PORT}/api/health
   🌐 Network: http://0.0.0.0:${PORT}
   
   Ready to accept requests!
   ===========================================
  `);
});

