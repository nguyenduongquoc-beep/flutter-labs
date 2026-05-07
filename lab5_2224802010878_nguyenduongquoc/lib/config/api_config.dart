// Base URL for ASP.NET Core backend
// Change this to your server IP when testing on a real device
const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator → localhost

// Auth endpoints
const String loginUrl = '$baseUrl/api/auth/login';
const String registerUrl = '$baseUrl/api/auth/register';

// Todo endpoints
const String todoBaseUrl = '$baseUrl/api/todos';
const String createTodoUrl = todoBaseUrl;
const String getTodosUrl = todoBaseUrl;
