import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomFormField extends StatelessWidget {
  String hintText;
  double height;
  bool obscure = false;
  RegExp validationExp;
  final void Function(String?) onSaved;
  TextInputType keyboard;
  TextEditingController controller;
  List<TextInputFormatter> inputFormatter;
  String onError;
  void Function(String)? onChanged;
  CustomFormField({
    super.key,
    required this.hintText,
    this.obscure = false,
    required this.height,
    required this.validationExp,
    required this.onSaved,
    required this.controller,
    this.keyboard = TextInputType.text,
    required this.inputFormatter,
    required this.onError,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        onSaved: onSaved,
        onChanged: onChanged,
        validator: (value) {
          if (value != null && validationExp.hasMatch(value)) {
            return null;
          }
          return onError;
        },
        keyboardType: keyboard,
        inputFormatters: inputFormatter,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: hintText,
        ),
        obscureText: obscure,
      ),
    );
  }
}
