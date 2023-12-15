
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moment/views/alerts/alert_popups.dart';
import 'package:moment/views/authentication/sign_in_page.dart';
import 'package:moment/views/authentication/validation_input_page.dart';

import '../views/landing_page.dart';

class AuthenticationService {

  static void authenticateUser(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if(user == null) {
        print("User is signed out.");
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
      }
      else {
        print("User is signed in");
      }
    });
  }

  static Future<void> signInWithPhoneNumber(BuildContext context, String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    print(phoneNumber);
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {
        if(e.code == 'invalid-phone-number') {
          print("The provided phone number is not valid");
          AlertPopups.showAlertDialog(context, "Error Verifying", "Invalid Phone Number");
        }
      },
      codeSent: (verificationId, resendToken) async {
        print("code sent");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ValidationInputPage(phoneNumber: phoneNumber, verificationId: verificationId, resendToken: resendToken)));
      },
      codeAutoRetrievalTimeout: (verificationId) {}
    );
  }

  static Future<bool> verifyCode(BuildContext context, String verificationId, String smsCode) async {

    FirebaseAuth auth = FirebaseAuth.instance;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    try {
      await auth.signInWithCredential(credential);
      print("sign in success.");
      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return false;
    }

  }

}