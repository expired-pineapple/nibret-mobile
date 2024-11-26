import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final response = await http.post(
        Uri.parse('https://nibret-vercel-django.vercel.app/accounts/google/'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          "access_token": googleAuth.accessToken,
          "id_token": googleAuth.idToken
        }),
      );

      if (response.statusCode == 200) {
        print('User registered successfully');
      } else {
        print('Failed to register user: ${response.body}');
      }
    } catch (error) {
      print('Error signing in with Google: $error');
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(
              'https://nibret-vercel-django.vercel.app/accounts/registration/'),
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode({
            "username":
                "${firstNameController.text.toLowerCase()}${lastNameController.text.toLowerCase()}",
            "email": emailController.text,
            "password1": passwordController.text,
            "password2": confirmPasswordController.text,
            "phone": phoneNumberController.text,
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
          }),
        );

        if (response.statusCode == 201) {
          Fluttertoast.showToast(
              msg:
                  "You have successfully registered. Please log in using your current credentials.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM_RIGHT,
              backgroundColor: Colors.green.withOpacity(0.89),
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          Fluttertoast.showToast(
              msg: response.body,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM_RIGHT,
              backgroundColor: Colors.red.withOpacity(0.89),
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } on SocketException catch (e) {
        Fluttertoast.showToast(
            msg:
                "Failed to connect to the server. Please check your internet connection.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_RIGHT,
            backgroundColor: Colors.red.withOpacity(0.89),
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 44),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 40,
                        width: 48,
                        child: Image.asset("assets/Logo.png")),
                    const SizedBox(width: 10),
                    const Text("NIBRET",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0XFF051C3E))),
                  ],
                ),
                const SizedBox(height: 28),
                const Text("Welcome!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0XFF2E3E5C))),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: buildTextFormField(firstNameController,
                            "First Name", "Please enter first name")),
                    const SizedBox(width: 10),
                    Expanded(
                        child: buildTextFormField(lastNameController,
                            "Last Name", "Please enter last name")),
                  ],
                ),
                const SizedBox(height: 14),
                buildTextFormField(
                    emailController,
                    "Email",
                    "Please enter email",
                    TextInputType.emailAddress,
                    emailValidator),
                const SizedBox(height: 32),
                buildTextFormField(phoneNumberController, "Phone Number",
                    "Invalid phone number"),
                const SizedBox(height: 16),
                buildTextFormField(
                    passwordController,
                    "Password",
                    "Password is required",
                    TextInputType.visiblePassword,
                    passwordValidator),
                const SizedBox(height: 24),
                buildTextFormField(
                    confirmPasswordController,
                    "Confirm Password",
                    "Please confirm your password",
                    TextInputType.visiblePassword, (value) {
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                }),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF163C9F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                          )),
                      child: const Text("Log in",
                          style: TextStyle(color: Color(0XFF163C9F))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(TextEditingController controller,
      String labelText, String validationMessage,
      [TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: labelText, border: const OutlineInputBorder()),
      keyboardType: inputType,
      validator: (value) {
        if (value!.isEmpty) return validationMessage;
        if (validator != null) return validator(value);
        return null;
      },
    );
  }

  String? emailValidator(String? value) {
    if (value!.isEmpty) return "Please enter email";
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return "Invalid Email";
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    if (!RegExp(r'\d').hasMatch(value) ||
        !RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value) ||
        !RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'A number, special character, and an alphabet required.';
    }
    return null;
  }
}
