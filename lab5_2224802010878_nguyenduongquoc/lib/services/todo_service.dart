import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/todo_model.dart';

class TodoService {
  // Get all todos for the authenticated user
  static Future<List<TodoModel>> getTodos(String token) async {
    try {
      final response = await http.get(
        Uri.parse(getTodosUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TodoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create new todo
  static Future<bool> createTodo(
      String token, String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse(createTodoUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'title': title, 'description': description}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update todo (toggle complete or edit)
  static Future<bool> updateTodo(
      String token, String id, String title, String description, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse('$todoBaseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'isCompleted': isCompleted,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // Delete todo by id
  static Future<bool> deleteTodo(String token, String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$todoBaseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
