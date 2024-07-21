import 'package:datty/bloc/authentication/authentication_bloc.dart';
import 'package:datty/bloc/blocDelegate.dart';
import 'package:datty/repositories/user_repository.dart';
import 'package:datty/ui/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/authentication/authentication_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final UserRepository _userRepository = UserRepository();

  Bloc.observer = SimpleBlocDelegate() as BlocObserver;

  runApp(BlocProvider(
    create: (context) => AuthenticationBloc(userRepository: _userRepository)
      ..add(AppStarted()),
    child: Home(userRepository: _userRepository),
  ));
}

class SimpleBlocDelegate {
}