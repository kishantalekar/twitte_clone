// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitte_clone/common/loading_page.dart';
import 'package:twitte_clone/common/rounded_small_button.dart';
import 'package:twitte_clone/constants/constants.dart';
import 'package:twitte_clone/features/auth/controller/auth_controller.dart';
import 'package:twitte_clone/features/auth/view/login_view.dart';
import 'package:twitte_clone/features/auth/widgets/auth_field.dart';
import 'package:twitte_clone/theme/pallete.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});
  static route() => MaterialPageRoute(builder: (context) => const SignUpView());

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final appBar = UIConstants.appBar();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void signUP() {
    final authController = ref.read(authControllerProvider.notifier);

    authController.signUp(
        email: emailController.text,
        password: passwordController.text,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? const LoadingPage()
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // AuthField(
                      //   controller: nameController,
                      //   title: "Enter your name ",
                      // ),
                      // const SizedBox(
                      //   height: 25,
                      // ),
                      AuthField(
                        controller: emailController,
                        title: "Enter your email addhress",
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      AuthField(
                        controller: passwordController,
                        title: "Enter your Password here ",
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          onTap: signUP,
                          label: "Register",
                          backgroundColor: Pallete.whiteColor,
                          textColor: Pallete.backgroundColor,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: const TextStyle(color: Pallete.blueColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(context, LoginView.route());
                                },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
