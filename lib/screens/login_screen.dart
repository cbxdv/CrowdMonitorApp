import 'package:crowd_monitor/screens/register_screen.dart';
import 'package:crowd_monitor/widgets/error_dialog.dart';
import 'package:crowd_monitor/widgets/loading_dialog.dart';
import 'package:crowd_monitor/widgets/sized_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedInputField(
                controller: emailController,
                hintText: 'Email',
                inputType: TextInputType.emailAddress,
              ),
              SizedInputField(
                controller: passwordController,
                hintText: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 50),
              OutlinedButton(
                onPressed: () async {
                  final email = emailController.text;
                  final password = passwordController.text;
                  loadingDialog(context: context, text: 'Logging In');
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    navigateToHome();
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    showErrorDialog(context, e.message.toString());
                  } catch (e) {
                    Navigator.pop(context);
                    showErrorDialog(context, e.toString());
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Create new user'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
