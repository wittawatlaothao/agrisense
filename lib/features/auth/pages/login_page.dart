import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/utils/validators.dart';
import '../provider/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("เข้าสู่ระบบ Agrisense")),
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
                              await auth.login(email.text, password.text);
                            if (success) {
                            Fluttertoast.showToast(
                              msg: "เข้าสู่ระบบสำเร็จ",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                            Navigator.pushReplacementNamed(context, "/home");
                            } else {
                            Fluttertoast.showToast(
                              msg: "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.SNACKBAR,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                            }
                        }
                      },
                      child: const Text("เข้าสู่ระบบ"),
                    ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/register"),
                child: const Text("ยังไม่มีบัญชี? สมัครสมาชิก"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
