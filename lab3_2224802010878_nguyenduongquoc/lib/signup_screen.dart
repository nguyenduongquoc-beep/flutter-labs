import 'package:flutter/material.dart';
import 'api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  final emailRegex =
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Invalid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              // PASSWORD
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'The field cannot be empty';
                  }
                  if (value.length < 7) {
                    return 'The password must contain at least 7 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // SIGN UP BUTTON
              ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                await api.register("login", {
                  "email": emailController.text.trim(),
                  "password": passwordController.text.trim(),
                });

                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("Thành công"),
                    content: Text("Đăng ký thành công"),
                  ),
                );
              },
              child: const Text("Đăng ký"),
            ),

              const SizedBox(height: 10),

              // BACK BUTTON
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // quay về login
                },
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}