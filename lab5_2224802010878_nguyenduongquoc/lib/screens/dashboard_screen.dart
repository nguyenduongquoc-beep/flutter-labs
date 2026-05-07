import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/todo_model.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String token;
  const DashboardScreen({super.key, required this.token});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<TodoModel> _todos = [];
  bool _isLoading = true;
  String _userEmail = '';
  late AnimationController _fabAnimController;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fabAnimController.forward();
    _decodeToken();
    _loadTodos();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _decodeToken() {
    try {
      final decoded = JwtDecoder.decode(widget.token);
      setState(() {
        _userEmail = decoded['email'] ??
            decoded[
                'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
            'User';
      });
    } catch (_) {}
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await TodoService.getTodos(widget.token);
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  Future<void> _showAddEditDialog({TodoModel? todo}) async {
    _titleController.text = todo?.title ?? '';
    _descController.text = todo?.description ?? '';

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              todo == null ? Icons.add_task_rounded : Icons.edit_rounded,
              color: const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 10),
            Text(
              todo == null ? 'Thêm công việc' : 'Chỉnh sửa',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                labelStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.title_rounded,
                    color: Color(0xFF6C63FF)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                labelStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: const Icon(Icons.description_rounded,
                    color: Color(0xFF3EC6E0)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _descController.clear();
              Navigator.pop(ctx);
            },
            child: Text('Hủy',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              bool ok;
              if (todo == null) {
                ok = await TodoService.createTodo(
                  widget.token,
                  _titleController.text.trim(),
                  _descController.text.trim(),
                );
              } else {
                ok = await TodoService.updateTodo(
                  widget.token,
                  todo.id,
                  _titleController.text.trim(),
                  _descController.text.trim(),
                  todo.isCompleted,
                );
              }
              _titleController.clear();
              _descController.clear();
              if (ok) {
                _loadTodos();
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Thao tác thất bại'),
                        backgroundColor: Color(0xFFE53935)),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(todo == null ? 'Thêm' : 'Lưu',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleComplete(TodoModel todo) async {
    await TodoService.updateTodo(
      widget.token,
      todo.id,
      todo.title,
      todo.description,
      !todo.isCompleted,
    );
    _loadTodos();
  }

  Future<void> _deleteTodo(String id) async {
    final ok = await TodoService.deleteTodo(widget.token, id);
    if (ok) _loadTodos();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  int get _doneCount => _todos.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12122A),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar Header ──────────────────────────────
          SliverAppBar(
            expandedHeight: 185,
            pinned: true,
            backgroundColor: const Color(0xFF12122A),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3EC6E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Xin chào 👋',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14)),
                                  Text(
                                    _userEmail,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _logout,
                              tooltip: 'Đăng xuất',
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.logout_rounded,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statChip('${_todos.length}', 'Tổng',
                                Icons.list_alt_rounded),
                            const SizedBox(width: 10),
                            _statChip('$_doneCount', 'Hoàn thành',
                                Icons.check_circle_rounded),
                            const SizedBox(width: 10),
                            _statChip('${_todos.length - _doneCount}',
                                'Còn lại', Icons.pending_actions_rounded),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Section Title ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.task_alt_rounded,
                      color: Color(0xFF6C63FF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Danh sách công việc',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'Vuốt trái để thao tác',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // ── Todo List ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF6C63FF))))
                : _todos.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 80,
                                  color:
                                      Colors.white.withValues(alpha: 0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có công việc nào',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.4),
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nhấn + để thêm công việc mới',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _buildTodoCard(_todos[i]),
                          childCount: _todos.length,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimController,
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: const Color(0xFF6C63FF),
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Thêm mới',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          elevation: 8,
        ),
      ),
    );
  }

  // ── Stat chip in header ──────────────────────────────────────
  Widget _statChip(String count, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Todo card with Slidable ──────────────────────────────────
  Widget _buildTodoCard(TodoModel todo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(todo.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showAddEditDialog(todo: todo),
              backgroundColor: const Color(0xFF3EC6E0),
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Sửa',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) => _deleteTodo(todo.id),
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Xóa',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: todo.isCompleted
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: todo.isCompleted
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: () => _toggleComplete(todo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: todo.isCompleted
                      ? const LinearGradient(colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF81C784)
                        ])
                      : null,
                  border: todo.isCompleted
                      ? null
                      : Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2),
                ),
                child: todo.isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                color: todo.isCompleted
                    ? Colors.white38
                    : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: Colors.white38,
              ),
            ),
            subtitle: todo.description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      todo.description,
                      style: TextStyle(
                          color: todo.isCompleted
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.55),
                          fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
            trailing: Icon(
              Icons.swipe_left_alt_rounded,
              color: Colors.white.withValues(alpha: 0.2),
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}
