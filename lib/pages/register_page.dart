import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:youhow/consts.dart';
import 'package:youhow/models/user_profile.dart';
import 'package:youhow/pages/otp_page.dart';
import 'package:youhow/services/alert_service.dart';
import 'package:youhow/services/auth_service.dart';
import 'package:youhow/services/database_service.dart';
import 'package:youhow/services/media_service.dart';
import 'package:youhow/services/navigation_service.dart';
import 'package:youhow/services/storage_service.dart';
import 'package:youhow/utils.dart';
import 'package:youhow/widgets/custom_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;

  late NavigationService _navigationService;

  late AlertService _alertService;

  late MediaService _mediaService;

  late StorageService _storageService;

  late DatabaseService _databaseService;

  String? email, password, name, number, confirmPass;

  bool isLoading = false;
  bool phoneVerified = false;

  File? selectedImage;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    requestPermissions().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          children: [
            _headerText(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _loginLink(),
            if (isLoading)
              const Expanded(
                  child: Center(
                child: CircularProgressIndicator(),
              )),
          ],
        ),
      ),
    );
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
            "Let's, get going!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Register an account using the form below",
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

  Widget _registerForm() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      height: MediaQuery.sizeOf(context).height * 0.72,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              pfp(),
              CustomFormField(
                inputFormatter: const [],
                controller: nameController,
                hintText: "Name",
                height: MediaQuery.sizeOf(context).height * 0.09,
                validationExp: NAME_VALIDATION_REGEX,
                onSaved: (value) {
                  name = value;
                },
                onError: "Name must start with a capital letter",
              ),
              Row(
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.09,
                    width: MediaQuery.sizeOf(context).width * 0.67,
                    child: CustomFormField(
                      controller: numberController,
                      hintText: "Mobile Number",
                      onChanged: (p0) {
                        setState(() {
                          phoneVerified = false;
                        });
                      },
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      height: MediaQuery.sizeOf(context).height * 0.09,
                      validationExp: NUMBER_VALIDATION_REGEX,
                      keyboard: TextInputType.number,
                      onSaved: (value) {
                        number = value;
                      },
                      onError: "Number is not verified",
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 0, 15),
                    child: TextButton(
                      onPressed: !phoneVerified
                          ? () async {
                              if (numberController.text.length == 10) {
                                print(
                                    "numbercontroller: ${numberController.text}");
                                print("number: $number");
                                await _authService.sendOTP(
                                  numberController.text,
                                );
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return VerifyOTP(
                                      number: numberController.text,
                                    );
                                  },
                                )).then((value) => setState(() {
                                      phoneVerified = value;
                                    }));
                              } else {
                                null;
                              }
                            }
                          : null,
                      child: !phoneVerified
                          ? const Text(
                              "Verify",
                              textAlign: TextAlign.center,
                            )
                          : const Icon(Icons.verified_rounded,
                              color: Colors.green),
                    ),
                  ),
                ],
              ),
              CustomFormField(
                inputFormatter: const [],
                controller: emailController,
                hintText: "Email",
                height: MediaQuery.sizeOf(context).height * 0.09,
                validationExp: EMAIL_VALIDATION_REGEX,
                onSaved: (value) {
                  email = value;
                },
                onError: "Enter correct email",
              ),
              CustomFormField(
                inputFormatter: const [],
                controller: passwordController,
                hintText: "Password",
                obscure: true,
                height: MediaQuery.sizeOf(context).height * 0.09,
                validationExp: PASSWORD_VALIDATION_REGEX,
                onSaved: (value) {
                  password = value;
                },
                onError:
                    "Length: 8, 1 Uppercase, 1 lowercase, 1 symbol, 1 number",
              ),
              CustomFormField(
                inputFormatter: const [],
                controller: confirmPassController,
                hintText: "Confirm Password",
                obscure: true,
                height: MediaQuery.sizeOf(context).height * 0.09,
                validationExp: PASSWORD_VALIDATION_REGEX,
                onError: "Passwords do not match",
                onSaved: (value) {
                  confirmPass = value;
                },
              ),
              _registerButton(),
            ],
          )),
    );
  }

  Widget pfp() {
    return GestureDetector(
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : const NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
      onTap: () async {
        File? img = await _mediaService.getImageFromGallery();
        setState(() {
          selectedImage = img;
        });
      },
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MaterialButton(
        onPressed: () async {
          try {
            if ((_registerFormKey.currentState?.validate() ?? false) &&
                selectedImage != null &&
                passwordController.text == confirmPassController.text &&
                phoneVerified) {
              setState(() {
                isLoading = true;
              });
              _registerFormKey.currentState!.save();
              print("reg form saved");
              bool res = await _authService.signup(email!, password!);
              _alertService.showToast(text: "On it");
              print("signup: $res");
              if (res) {
                print("if signup true");
                String? pfpurl = await _storageService.uploadUserPfp(
                    file: selectedImage!, uid: _authService.user!.uid);
                if (pfpurl != null) {
                  // _alertService.showToast(text: "Just a little more time!");
                  await _databaseService.createUserProfile(
                    userProfile: UserProfile(
                      number: number,
                      email: email,
                      uid: _authService.user!.uid,
                      name: name,
                      pfpURL: pfpurl,
                    ),
                  );
                }
                _navigationService.pushReplacementNamed('/home');
                _alertService.showToast(
                    text: "Registration Successful!",
                    color: Colors.green,
                    icon: Icons.check);
              }
              setState(() {
                isLoading = false;
              });
            }
          } catch (e) {
            print(e);
            _alertService.showToast(text: e.toString());
          }
        },
        color: Theme.of(context).primaryColor,
        child: const Text(
          "SignUp",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginLink() {
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          child: const Text(
            "Login",
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
          onTap: () {
            _navigationService.pushReplacementNamed('/login');
          },
        ),
      ],
    ));
  }
}
