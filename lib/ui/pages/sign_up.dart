import 'package:datty/bloc/signup/bloc.dart';
import 'package:datty/repositories/user_repository.dart';
import 'package:datty/ui/constants.dart';
import 'package:datty/ui/widgets/signUpForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUp extends StatelessWidget {
  final UserRepository userRepository;

  const SignUp({required this.userRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 36.0),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => SignUpBloc(
          userRepository: userRepository,
        ),
        child: SignUpForm(
          userRepository: userRepository,
        ),
      ),
    );
  }
}