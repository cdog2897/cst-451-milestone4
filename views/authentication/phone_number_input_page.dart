import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:moment/services/authentication_service.dart';
import 'package:moment/views/authentication/validation_input_page.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../models/app_colors_model.dart';

class PhoneNumberInputPage extends StatefulWidget {
  const PhoneNumberInputPage({super.key});

  @override
  State<PhoneNumberInputPage> createState() => _PhoneNumberInputPageState();
}

class _PhoneNumberInputPageState extends State<PhoneNumberInputPage> {

  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  final TextEditingController _controller = TextEditingController();
  String phoneNumber = "";

  Color buttonColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign up or Login:", style: TextStyle(color: AppColors.text, fontSize: 24),),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 75,
                      child: IntlPhoneField(
                        controller: _controller,
                        dropdownTextStyle: TextStyle(color: AppColors.text),
                        dropdownIcon: Icon(Icons.arrow_drop_down, color: AppColors.text,),
                        autofocus: true,
                        cursorColor: AppColors.text,
                        style: TextStyle(color: AppColors.text, fontSize: 24),
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: AppColors.text),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.button),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.button),
                                borderRadius: BorderRadius.circular(10)
                            )
                        ),
                        initialCountryCode: 'US',
                        onChanged: (phone) {
                          if(_controller.text.length == 10) {
                            setState(() {
                              buttonColor = AppColors.button;
                              phoneNumber = phone.completeNumber;
                            });
                          }
                          else {
                            setState(() {
                              buttonColor = AppColors.text;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 5,),
                    _controller.text.length == 10
                        ? isLoading == false
                        ? InkWell(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        HapticFeedback.lightImpact();
                        if(!mounted) return;
                        AuthenticationService.signInWithPhoneNumber(context, phoneNumber);
                      },
                      child: Container(
                          width: 100,
                          height: 58,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.button,
                              border: Border.all()
                          ),
                          child: Center(
                            child: Text("Submit", style: TextStyle(color: AppColors.textSecondary, fontSize: 24),),
                          )
                      ),
                    )
                        : InkWell(
                      onTap: () {
                      },
                      child: Container(
                          width: 100,
                          height: 58,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                              border: Border.all()
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          )
                      ),
                    )
                        : InkWell(
                      onTap: (){
                      },
                      child: Container(
                          width: 100,
                          height: 58,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey,
                              border: Border.all()
                          ),
                          child: Center(
                            child: Text("Submit", style: TextStyle(color: AppColors.textSecondary, fontSize: 24),),
                          )
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }


}
