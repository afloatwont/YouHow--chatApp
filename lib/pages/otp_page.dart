// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/services/auth_service.dart';

class VerifyOTP extends StatefulWidget {
  String number;
  VerifyOTP({super.key, required this.number});

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  final TextEditingController _otpController = TextEditingController();
  final GetIt getIt = GetIt.instance;
  late AuthService _authService;

  Future<void> _submitOTP() async {
    if (_otpController.text.length == 6) {
      // Logic to submit the OTP
      final otp = _otpController.text;
      // Validate and submit the OTP
      bool res = await _authService.verifyOTP(otp);
      if (res) {
        Navigator.pop(context, true);
      }
      print('OTP submitted: $otp');
    } else {
      null;
    }
  }

  Future<void> _resendOTP() async {
    // Logic to resend the OTP
    await _authService.sendOTP(widget.number);
    print('OTP resent');
  }

  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter the OTP sent to your mobile number',
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'OTP',
              ),
              maxLength: 6, // Assuming OTP is 6 digits
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOTP,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _resendOTP,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
