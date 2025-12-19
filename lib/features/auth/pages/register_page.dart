import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade400,
              Colors.green.shade700,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),
                        Icon(
                          Icons.person_add,
                          size: 64,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "สมัครสมาชิก",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Agrisense",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: email,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "อีเมล",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: password,
                          obscureText: true,
                          validator: Validators.password,
                          decoration: InputDecoration(
                            labelText: "รหัสผ่าน",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 32),
                        auth.isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success =
                                          await auth.register(email.text, password.text);
                                      if (success) {
                                        Fluttertoast.showToast(
                                          msg: "สมัครสำเร็จ!",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: "การสมัครล้มเหลว กรุณาลองใหม่",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.TOP,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "สมัครสมาชิก",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
