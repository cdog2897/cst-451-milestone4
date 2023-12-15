import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment/models/app_colors_model.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/authentication/check_if_user_registered.dart';
import 'package:moment/views/landing_page.dart';


class SetupUsernamePage extends StatefulWidget {
  const SetupUsernamePage({super.key});

  @override
  State<SetupUsernamePage> createState() => _SetupUsernamePageState();
}

class _SetupUsernamePageState extends State<SetupUsernamePage> {

  final TextEditingController _controller = TextEditingController();
  bool isUsernameLoading = false;
  bool isValidUsername = false;

  String? errorMessage;

  Future<void> checkUsername(String username) async {
    setState(() {
      isUsernameLoading = true;
    });
    if(username.length < 6) {
      setState(() {
        isValidUsername = false;
        isUsernameLoading = false;
        errorMessage = "Username too short.";
      });
    }
    else {
      isValidUsername = await FirestoreService.checkIfUsernameUnique(username);

      setState(() {
        isUsernameLoading = false;
        if(!isValidUsername) {
          errorMessage = "Username taken.";
        }
        else {
          errorMessage = null;
        }
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create a Username:", style: TextStyle(color: AppColors.text, fontSize: 24),),
            const SizedBox(height: 16,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                  width: 50,
                ),
                SizedBox(
                  width: 200,
                  height: 70,
                  child: TextField(
                    onChanged: (s) {
                      print(s);
                      checkUsername(s);
                    },
                    maxLength: 16,
                    cursorColor: Colors.white,
                    style: TextStyle(color: AppColors.text, fontSize: 20),
                    decoration: InputDecoration(
                      errorText: errorMessage,
                        labelStyle: TextStyle(color: AppColors.text),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.button),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.button),
                            borderRadius: BorderRadius.circular(10)
                        ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey)
                      )
                    ),
                    controller: _controller,
                    autofocus: true,
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: isUsernameLoading
                          ? CircularProgressIndicator(color: AppColors.button,)
                          : isValidUsername
                            ? const Icon(Icons.check, color: Colors.green,)
                            : Icon(Icons.close, color: AppColors.button,),
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 24,),
            isValidUsername
              ? InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                await FirestoreService.createUser(_controller.text);
                if(!mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LandingPage()), (route) => false);
              },
              child: Container(
                  width: 130,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text("Submit", style: TextStyle(color: AppColors.textSecondary, fontSize: 24),),
                  )
              ),
            )
              : Container(
                width: 130,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Text("Submit", style: TextStyle(color: AppColors.textSecondary, fontSize: 24),),
                )
            )
          ],
        ),
      ),
    );
  }
}
