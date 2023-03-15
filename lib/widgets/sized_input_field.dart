import 'package:flutter/material.dart';

class SizedInputField extends StatelessWidget {
  const SizedInputField(
      {Key? key,
      required this.controller,
      required this.hintText,
      this.isPassword = false,
      this.inputType})
      : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final TextInputType? inputType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: TextField(
        controller: controller,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: hintText,
        ),
        obscureText: isPassword,
        keyboardType: inputType,
      ),
    );
  }
}
