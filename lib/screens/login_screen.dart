import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nibret/provider/auth_provider.dart';
import 'package:nibret/screens/home_page.dart';
import 'package:nibret/screens/layout_screen.dart';
import 'package:nibret/screens/signup_screen.dart';
import 'package:nibret/widgets/custom_elevated_button.dart';
import 'package:nibret/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> logIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          emailController.text,
          passwordController.text,
        );

        if (!mounted) return;

        Fluttertoast.showToast(
            msg: "Login Success",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_RIGHT,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green.withOpacity(0.89),
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => true,
        );
      } catch (e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_RIGHT,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red.withOpacity(0.89),
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loginWithGoogle();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_RIGHT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red.withOpacity(0.89),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 48,
                          child: Image.asset(
                            "assets/splash_image.png",
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "NIBRET",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                            color: Color(0XFF051C3E),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    const Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w600,
                        color: Color(0XFF2E3E5C),
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      "Please enter your account here",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Roboto',
                        color: Color(0XFF8189B0),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    _buildEmailInput(context),
                    const SizedBox(
                      height: 14,
                    ),
                    _buildPasswordInput(context),
                    const SizedBox(
                      height: 24,
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 14),
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0XFF163C9F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomElevatedButton(
                      onPressed: logIn,
                      text: "Log In",
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.disabled)) {
                              return const Color(0XFF163C9F).withOpacity(0.5);
                            }
                            return const Color(0XFF163C9F);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: Divider()),
                          SizedBox(
                            width: 10,
                          ),
                          Text("or"),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Divider(),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    CustomElevatedButton(
                      onPressed: signInWithGoogle,
                      text: "Continue with Google",
                      buttonTextStyle: const TextStyle(color: Colors.black),
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      leftIcon: Container(
                        margin: const EdgeInsets.only(right: 6),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Image.asset("assets/google.png"),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Color(0XFF2E3E5C),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          )),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Color(0XFF163C9F),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: CustomTextFormField(
        onChange: (value) {
          _formKey.currentState!.validate();
        },
        controller: passwordController,
        labelText: "Password",
        hintText: "Password",
        textInputType: TextInputType.emailAddress,
        contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
        borderDecoration: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0XFFF2F2F2),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter password";
          }
          return null;
        },
      ),
    );
  }

  Padding _buildEmailInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: CustomTextFormField(
        onChange: (value) {
          _formKey.currentState!.validate();
        },
        controller: emailController,
        labelText: "Email",
        hintText: "Email",
        textInputType: TextInputType.emailAddress,
        contentPadding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
        borderDecoration: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0XFFF2F2F2),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return "Please enter email";
          }
          return null;
        },
      ),
    );
  }
}
