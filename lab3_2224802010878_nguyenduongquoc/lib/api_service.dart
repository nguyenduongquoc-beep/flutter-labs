import 'package:dio/dio.dart';

class ApiService {
  final Dio dio = Dio();

 
  final String baseUrl = "https://69ddfd47410caa3d47ba6909.mockapi.io";

  //  LẤY DANH SÁCH USER
  Future<List<dynamic>> getUsers(String endpoint) async {
    try {
      final response = await dio.get("$baseUrl/$endpoint");
      return response.data;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  //  ĐĂNG KÝ
  Future<void> register(String endpoint, Map<String, dynamic> data) async {
    try {
      await dio.post("$baseUrl/$endpoint", data: data);
    } catch (e) {
      print("Error: $e");
    }
  }
}