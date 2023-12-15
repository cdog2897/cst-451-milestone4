import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/views/authentication/phone_number_input_page.dart';

import '../../models/app_colors_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  List<Color> colors = [];

  Color randomColor = AppColors.generateRandomContrastColor(Colors.black);

  late Timer timer;
  int i = 0;

  @override
  void initState() {
    colors = AppColors.createGradient(5, AppColors.generateRandomContrastColor(Colors.black), AppColors.generateRandomContrastColor(Colors.black));
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        if(i > 4) i = 0;
        randomColor = colors[i];
        i++;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login or Sign Up", style: TextStyle(color: Colors.black, fontSize: 26),),
            const SizedBox(height: 10,),
            Text("with Phone Number", style: TextStyle(color: Colors.black, fontSize: 26),),
            const SizedBox(height: 30,),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneNumberInputPage()));
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: randomColor,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Enter Phone Number", style: TextStyle(color: Colors.white, fontSize: 26),),
                  )
              ),
            ),
          ],
        ),
      )
    );
  }


}
