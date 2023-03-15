import 'package:crowd_monitor/utilities/firestore_utils.dart';
import 'package:crowd_monitor/widgets/error_dialog.dart';
import 'package:crowd_monitor/widgets/loading_dialog.dart';
import 'package:crowd_monitor/widgets/sized_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
        title: const Text('Register'),
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
              const SizedBox(height: 30),
              OutlinedButton(
                onPressed: () async {
                  final email = emailController.text;
                  final password = passwordController.text;
                  loadingDialog(context: context, text: 'Registering');
                  try {
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email, password: password);
                    await addNewUserUploadEntry(email);
                    navigateToHome();
                  } on FirebaseAuthException catch (e) {
                    Navigator.pop(context);
                    showErrorDialog(context, e.message.toString());
                  } catch (e) {
                    Navigator.pop(context);
                    showErrorDialog(context, e.toString());
                  }
                },
                child: const Text('Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
