import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _subscription;

  User? currentUser;

  bool initialized = false;

  AuthController() {
    _listen();
  }

  void _listen() {
    _subscription = _auth.authStateChanges().listen((user) {
      currentUser = user;

      initialized = true;

      notifyListeners();
    });
  }

  bool get isLoggedIn => currentUser != null;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
