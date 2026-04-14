import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // EMAIL
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "The field cannot be empty";
                  }
                  final emailRegex =
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return "Invalid email address";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // RESET BUTTON
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Thông báo"),
                        content: const Text("Đã reset password"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // đóng dialog
                            },
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: const Text("Reset Password"),
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