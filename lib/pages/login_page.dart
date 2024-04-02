import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/consts.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/widgets/custom_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;

  late NavigationService _navigationService;

  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  String? email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _headerText(),
          _loginForm(),
          _loginButton(),
          _createAccountLink(),
        ],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, Welcome back!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Hello again, you've been missed",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
          key: _loginFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomFormField(
                hintText: "Email",
                height: MediaQuery.sizeOf(context).height * 0.1,
                validationExp: EMAIL_VALIDATION_REGEX,
                onSaved: (value) {
                  email = value;
                },
              ),
              CustomFormField(
                hintText: "Password",
                obscure: true,
                height: MediaQuery.sizeOf(context).height * 0.1,
                validationExp: PASSWORD_VALIDATION_REGEX,
                onSaved: (value) {
                  password = value;
                },
              ),
            ],
          )),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState!.save();
            bool result = await _authService.login(email!, password!);
            print("result: $result");
            if (result) {
              _alertService.showToast(
                  text: "Successfully logged in!",
                  icon: Icons.check,
                  color: Colors.green);
              _navigationService.pushReplacementNamed('/home');
            } else {
              _alertService.showToast(
                text: "Failed to login, Please try again!",
                icon: Icons.error,
                color: Color.fromARGB(255, 255, 17, 0),
              );
            }
            print("youhowoow");
          }
        },
        color: Theme.of(context).primaryColor,
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLink() {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Don't have an account? "),
        GestureDetector(
          child: const Text(
            "SignUp",
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
          onTap: () {
            _navigationService.pushNamed('/register');
          },
        ),
        // TextButton(onPressed: () {}, child: const Text("SignUp")),
      ],
    ));
  }
}
