import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final token = await userCredential.user?.getIdToken(true);

      if (token == null) {
        throw Exception('Failed to get Firebase token');
      }

      return token;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
  }) async {
    final completer = Completer<void>();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        // If Android auto-verifies, it doesn't send an SMS.
        // We sign in with the credential so Firebase is authenticated.
        try {
          await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) completer.complete();
          // We MUST call onCodeSent with the verificationId so LoginBloc moves to the OTP screen,
          // otherwise the app hangs on 'loading'. We pass the smsCode if available so they can see it or we auto-submit.
          onCodeSent(credential.verificationId ?? 'auto-verified');
        } catch (e) {
          if (!completer.isCompleted)
            completer.completeError(Exception(e.toString()));
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted)
          completer.completeError(Exception(e.message));
      },
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId);
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  Future<String> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final result = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final token = await result.user?.getIdToken(true);

      if (token == null) {
        throw Exception('Failed to get Firebase token');
      }

      return token;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> signInWithOtp(String verificationId, String otp) async {
    return verifyOtp(verificationId: verificationId, otp: otp);
  }

  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
