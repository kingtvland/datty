import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:datty/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import './bloc.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(Uninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final uid = await _userRepository.getUser();
        if (uid != null) {
          final isFirstTime = await _userRepository.isFirstTime(uid);
          if (!isFirstTime) {
            yield AuthenticatedButNotSet(uid);
          } else {
            yield Authenticated(uid);
          }
        } else {
          yield Unauthenticated();
        }
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    final uid = await _userRepository.getUser();
    if (uid != null) {
      final isFirstTime = await _userRepository.isFirstTime(uid);
      if (!isFirstTime) {
        yield AuthenticatedButNotSet(uid);
      } else {
        yield Authenticated(uid);
      }
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    await _userRepository.signOut();
  }
}
