import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomFormField extends StatelessWidget {
  String hintText;
  double height;
  bool obscure = false;
  RegExp validationExp;
  final void Function(String?) onSaved;
  CustomFormField({
    super.key,
    required this.hintText,
    this.obscure = false,
    required this.height,
    required this.validationExp,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        onSaved: onSaved,
        validator: (value) {
          if (value != null && validationExp.hasMatch(value)) {
            return null;
          }
          return "Enter a valid ${hintText.toLowerCase()}";
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
        obscureText: obscure,
      ),
    );
  }
}
