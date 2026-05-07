const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// ── In-memory storage (không cần database) ───────────────────
const users = [];   // { id, email, password(hashed), fullName }
const todos = [];   // { id, title, description, isCompleted, userId, createdAt, updatedAt }

const JWT_SECRET = 'Lab5_TodoApp_SuperSecretKey_2224802010878_nguyenduongquoc';
const JWT_EXPIRES = '24h';

let userIdCounter = 1;
let todoIdCounter = 1;

// ── Middleware: verify JWT ────────────────────────────────────
function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Không có token. Vui lòng đăng nhập.' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.sub;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn.' });
  }
}

// ══════════════════════════════════════════════════════════════
//  AUTH ROUTES
// ══════════════════════════════════════════════════════════════

// POST /api/auth/register
app.post('/api/auth/register', async (req, res) => {
  const { email, password, fullName } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email và mật khẩu không được để trống.' });
  }
  const existing = users.find(u => u.email === email);
  if (existing) {
    return res.status(400).json({ message: 'Email đã được sử dụng.' });
  }
  const hashed = await bcrypt.hash(password, 10);
  const user = {
    id: String(userIdCounter++),
    email,
    password: hashed,
    fullName: fullName || '',
  };
  users.push(user);
  console.log(`✅ Đăng ký: ${email}`);
  return res.status(201).json({ message: 'Đăng ký thành công.' });
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email và mật khẩu không được để trống.' });
  }
  const user = users.find(u => u.email === email);
  if (!user) {
    return res.status(401).json({ message: 'Email không tồn tại.' });
  }
  const match = await bcrypt.compare(password, user.password);
  if (!match) {
    return res.status(401).json({ message: 'Mật khẩu không đúng.' });
  }
  const token = jwt.sign(
    { sub: user.id, email: user.email, fullName: user.fullName },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES }
  );
  console.log(`✅ Đăng nhập: ${email}`);
  return res.json({ token, email: user.email, fullName: user.fullName });
});

// ══════════════════════════════════════════════════════════════
//  TODO ROUTES (tất cả cần JWT)
// ══════════════════════════════════════════════════════════════

// GET /api/todos
app.get('/api/todos', authMiddleware, (req, res) => {
  const userTodos = todos
    .filter(t => t.userId === req.userId)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  return res.json(userTodos);
});

// GET /api/todos/:id
app.get('/api/todos/:id', authMiddleware, (req, res) => {
  const todo = todos.find(t => t.id === req.params.id && t.userId === req.userId);
  if (!todo) return res.status(404).json({ message: 'Không tìm thấy công việc.' });
  return res.json(todo);
});

// POST /api/todos
app.post('/api/todos', authMiddleware, (req, res) => {
  const { title, description } = req.body;
  if (!title || title.trim() === '') {
    return res.status(400).json({ message: 'Tiêu đề không được để trống.' });
  }
  const now = new Date().toISOString();
  const todo = {
    id: String(todoIdCounter++),
    title: title.trim(),
    description: description?.trim() || '',
    isCompleted: false,
    userId: req.userId,
    createdAt: now,
    updatedAt: now,
  };
  todos.push(todo);
  console.log(`➕ Tạo todo: "${todo.title}" (user: ${req.userId})`);
  return res.status(201).json(todo);
});

// PUT /api/todos/:id
app.put('/api/todos/:id', authMiddleware, (req, res) => {
  const idx = todos.findIndex(t => t.id === req.params.id && t.userId === req.userId);
  if (idx === -1) return res.status(404).json({ message: 'Không tìm thấy công việc.' });
  const { title, description, isCompleted } = req.body;
  todos[idx] = {
    ...todos[idx],
    title: title?.trim() ?? todos[idx].title,
    description: description?.trim() ?? todos[idx].description,
    isCompleted: isCompleted ?? todos[idx].isCompleted,
    updatedAt: new Date().toISOString(),
  };
  console.log(`✏️  Cập nhật todo id=${req.params.id}`);
  return res.json(todos[idx]);
});

// DELETE /api/todos/:id
app.delete('/api/todos/:id', authMiddleware, (req, res) => {
  const idx = todos.findIndex(t => t.id === req.params.id && t.userId === req.userId);
  if (idx === -1) return res.status(404).json({ message: 'Không tìm thấy công việc.' });
  todos.splice(idx, 1);
  console.log(`🗑️  Xóa todo id=${req.params.id}`);
  return res.status(204).send();
});

// ── Health check ─────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    message: '🚀 Todo API - Lab 5 đang chạy!',
    endpoints: {
      register: 'POST /api/auth/register',
      login: 'POST /api/auth/login',
      todos: 'GET|POST /api/todos',
      todo: 'GET|PUT|DELETE /api/todos/:id',
    }
  });
});

// ── Start server ──────────────────────────────────────────────
const PORT = 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Todo API Server đang chạy tại:`);
  console.log(`   http://localhost:${PORT}`);
  console.log(`   http://10.0.2.2:${PORT}  (Android Emulator)`);
  console.log(`\n📋 Endpoints:`);
  console.log(`   POST /api/auth/register`);
  console.log(`   POST /api/auth/login`);
  console.log(`   GET  /api/todos  (cần JWT)`);
  console.log(`   POST /api/todos  (cần JWT)`);
  console.log(`   PUT  /api/todos/:id  (cần JWT)`);
  console.log(`   DELETE /api/todos/:id  (cần JWT)\n`);
});
