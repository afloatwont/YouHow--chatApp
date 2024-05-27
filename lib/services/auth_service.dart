import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  String phoneVerificationID = '';
  bool phoneNumberVerified = false;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((event) {
      authStateChangesStream(event);
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  User? get user {
    return _user;
  }

  Future<bool> signup(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

// Function to send OTP
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91$phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign-in in case the verification is instantly completed (optional)
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          // Handle verification failure if needed
          print(e);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          // OTP code sent successfully
          print("OTP code sent to $phoneNumber");
          phoneVerificationID = verificationId;
          // Optionally, you can store the verification ID for later use
          // For example, you can store it in a state variable
          // _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Code auto-retrieval timeout, if needed
        },
      );
    } catch (e) {
      // Handle any exceptions that may occur during OTP sending
      print(e);
    }
  }

// Function to verify OTP
  Future<bool> verifyOTP(String otpCode) async {
    try {
      // Create a PhoneAuthCredential with the verification ID and OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: phoneVerificationID,
        smsCode: otpCode,
      );

      // Sign in with the credential
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // If the sign-in is successful, return true
      if (userCredential.user != null) {
        return true;
      }
    } catch (e) {
      // Handle verification failure
      print(e);
    }
    // If verification fails, return false
    return false;
  }

  void authStateChangesStream(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
}
