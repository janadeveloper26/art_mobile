import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart' show FirebaseAuthPlatform;

class FirebaseAuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  Future<void> initialize() async {
    try {
      // In google_sign_in 7.0.0+, initialization is mandatory.
      await _googleSignIn.initialize();
      
      // signInSilently is replaced by attemptLightweightAuthentication in 7.0.0+
      if (!kIsWeb) {
        await _googleSignIn.attemptLightweightAuthentication();
      }
    } catch (e) {
      debugPrint('FirebaseAuthService: GoogleSignIn initialization failed: $e');
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      // signIn is replaced by authenticate in 7.0.0+
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return await userCredential.user?.getIdToken();
    } catch (e) {
      debugPrint('FirebaseAuthService: Google Sign In error: $e');
      return null;
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    if (kIsWeb) {
      try {
        final ConfirmationResult result = await _auth.signInWithPhoneNumber(
          phoneNumber,
          RecaptchaVerifier(
            auth: FirebaseAuthPlatform.instance,
          ),
        );
        codeSent(result.verificationId, null);
      } catch (e) {
        if (e is FirebaseAuthException) {
          verificationFailed(e);
        } else {
          verificationFailed(FirebaseAuthException(code: 'unknown', message: e.toString()));
        }
      }
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<String?> signInWithOtp(String verificationId, String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
