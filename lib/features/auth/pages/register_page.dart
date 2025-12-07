import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../provider/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("สมัครสมาชิก Agrisense")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: email,
                validator: Validators.email,
                decoration: const InputDecoration(labelText: "อีเมล"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(labelText: "รหัสผ่าน"),
              ),
              const SizedBox(height: 24),
              auth.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success =
                              await auth.register(email.text, password.text);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("สมัครสำเร็จ!")),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("สมัครสมาชิก"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
