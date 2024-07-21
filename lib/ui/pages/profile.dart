import 'package:datty/bloc/profile/bloc.dart';
import 'package:datty/repositories/user_repository.dart';
import 'package:datty/ui/constants.dart';
import 'package:datty/ui/widgets/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Profile extends StatelessWidget {
  final UserRepository userRepository;
  final String userId;

  const Profile({
    Key? key,
    required this.userRepository,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Setup"),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: BlocProvider<ProfileBloc>(
        create: (context) => ProfileBloc(userRepository: userRepository),
        child: ProfileForm(
          userRepository: userRepository,
        ),
      ),
    );
  }
}