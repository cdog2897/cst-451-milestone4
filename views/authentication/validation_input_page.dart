import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moment/services/authentication_service.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/authentication/check_if_user_registered.dart';
import 'package:moment/views/authentication/setup/setup_username_page.dart';
import 'package:moment/views/home_page.dart';
import 'package:moment/views/landing_page.dart';
import 'package:pinput/pinput.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../models/app_colors_model.dart';
import '../alerts/alert_popups.dart';

class ValidationInputPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  const ValidationInputPage({super.key, required this.phoneNumber, required this.verificationId, required this.resendToken});

  @override
  State<ValidationInputPage> createState() => _ValidationInputPageState();
}

class _ValidationInputPageState extends State<ValidationInputPage> {

  FocusNode focusNode = FocusNode();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  Future<void> authenticate(String smsCode) async {
    setState(() {
      isLoading = true;
    });

    bool isSignedIn = await AuthenticationService.verifyCode(context, widget.verificationId, smsCode);
    if(isSignedIn) {
      if(!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LandingPage()), (route) => false);
    }
    else {
      if(!mounted) return;
      AlertPopups.showAlertDialog(context, "Incorrect Pin", "Please try again.").then((value) => focusNode.requestFocus());
    }

    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Enter the code sent to", style: TextStyle(color: AppColors.text, fontSize: 24),),
          ),
          Center(
            child: Text("(${widget.phoneNumber.substring(2, 5)}) ${widget.phoneNumber.substring(5, 8)}-${widget.phoneNumber.substring(8)}", style: TextStyle(color: AppColors.text, fontSize: 24),),
          ),
          Padding(
            padding: EdgeInsets.all(32),
            child: Pinput(
              length: 6,
              autofocus: true,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              submittedPinTheme: submittedPinTheme,
              validator: (s) {
                return null;
              },
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              showCursor: true,
              onCompleted: (pin) => authenticate(pin),
            )
          ),
          isLoading ? Padding(
            padding: const EdgeInsets.all(30),
            child: SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(color: AppColors.button,),
            ),
          ) : Container()
        ],
      ),
    );
  }
}
