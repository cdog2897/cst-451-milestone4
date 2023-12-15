import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../main.dart';
import '../../models/app_colors_model.dart';
import '../../models/group_model.dart';
import '../../services/firebase_storage_service.dart';
import '../../services/firestore_service.dart';

class CurrentGroupsPage extends StatefulWidget {
  final Function changeCamera;
  const CurrentGroupsPage({super.key, required this.changeCamera});

  @override
  State<CurrentGroupsPage> createState() => _RelivePageState();
}

class _RelivePageState extends State<CurrentGroupsPage> {
  final TextEditingController _groupNameController = TextEditingController();

  List<Group> currentGroups = List.generate(myGroups.length, (index) => myGroups[index])
      .where((group) => group.endDate!.isAfter(DateTime.now()) && !group.individual!).toList();

  Group individualGroup = List.generate(myGroups.length, (index) => myGroups[index]).where((group) => group.individual!).first;


  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 100,
      onRefresh: () async {
        myGroups = await FirestoreService.getMyGroups();
        setState(() {
          currentGroups = List.generate(myGroups.length, (index) => myGroups[index])
              .where((group) => group.endDate!.isAfter(DateTime.now()) && !group.individual!).toList();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView(
              children: [
                individualGroupCamera(),
                currentGroupCameras(),
              ],
            ),
            createGroupButton(),
            joinGroupButton(),
          ],
        ),
      ),
    );
  }

  Widget individualGroupCamera() {
    return SizedBox(
      width: double.maxFinite,
      height: 280,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 30,
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.background
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(individualGroup.endDate!.difference(DateTime.now()).inDays.toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("days  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                            Text(individualGroup.endDate!.difference(DateTime.now()).inHours.remainder(24).toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("hours  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                            Text(individualGroup.endDate!.difference(DateTime.now()).inMinutes.remainder(60).toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("minutes  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                          ],
                        ),
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(individualGroup.imgUrl!)
                            )
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.camera_alt_rounded, color: AppColors.text,),
                            Icon(Icons.arrow_forward_ios, color: AppColors.text,),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
          Container(
            width: 200,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.background
            ),
            child: Column(
              children: [
                const SizedBox(height: 8,),
                Text("${currentUser.displayName}'s", style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Camera", style: TextStyle(color: AppColors.text, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget currentGroupCameras() {
    return Column(
      children: [
        for(var group in currentGroups) Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 16, left: 16),
          child: Container(
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.background
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(group.groupName!, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 18),),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.endDate!.difference(DateTime.now()).inDays.toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("days  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                            Text(group.endDate!.difference(DateTime.now()).inHours.remainder(24).toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("hours  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                            Text(group.endDate!.difference(DateTime.now()).inMinutes.remainder(60).toString(), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.button),),
                            Text("minutes  ", style: TextStyle(color: AppColors.text, fontSize: 18),),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 200,
                        color: Colors.black,
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 40,),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(group.imgUrl!)
                                )
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 200,
                        color: Colors.black,
                      ),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.changeCamera(group.groupId!);
                          DefaultTabController.of(context).animateTo(1);
                        },
                        child: Container(
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: AppColors.text,),
                              Icon(Icons.arrow_forward_ios, color: AppColors.text,),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }


  void joinCamera(BuildContext context) {

    bool isAuthenticating = false;

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

    Future<void> authenticate(String pin) async {
      isAuthenticating = true;
      Map<bool, Group> map = await FirestoreService.groupExists(pin);
      if(map.keys.first == true) {
        await FirestoreService.joinGroup(map.values.first);
      }
      isAuthenticating = false;
    }

    showModalBottomSheet(
        backgroundColor: AppColors.background,
        useSafeArea: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        context: context,
        builder: (context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("Enter the group code", style: TextStyle(color: AppColors.text, fontSize: 24),),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(32),
                          child: Pinput(
                            length: 4,
                            autofocus: true,
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
                      isAuthenticating ? Padding(
                        padding: const EdgeInsets.all(30),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: AppColors.button,),
                        ),
                      ) : Container()
                    ],
                  )
              )
          );
        }
    );
  }

  Widget createGroupButton() {
    return Positioned(
      bottom: 5,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          createGroupBottomSheet();
        },
        child: Container(
          width: 120,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.button
          ),
          child: const Center(
            child: Text(
              "Create a Group",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget joinGroupButton() {
    return Positioned(
      bottom: 5,
      right: 5,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          joinGroupBottomSheet();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.button
          ),
          child: const Center(
              child: Icon(Icons.qr_code_2_rounded, size: 32,)
          ),
        ),
      ),
    );
  }

  // JOIN A GROUP:
  joinGroupBottomSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MobileScanner(
              controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.noDuplicates
              ),
              onDetect: (capture) {
                print(capture.barcodes[0].rawValue);
              },
            ),
          );
        }
    );
  }

  // CREATE A GROUP:

  createGroupBottomSheet() {
    int currentPage = 0;
    File? finalImage;
    Group finalGroup = Group();

    showModalBottomSheet(
        useSafeArea: true,
        isDismissible: false,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: AppColors.background,
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setModalState) {

            void changePage(int pageNumber, Group group) {
              finalGroup = group;
              setModalState(() {
                currentPage = pageNumber;
              });
            }

            void updatePhoto(File? image) {
              setModalState((){
                finalImage = image;
              });
            }

            Future<void> submitGroup(File image) async {
              setModalState((){
                currentPage = 2;
              });
              String imgUrl = await StorageService.uploadGroupImage(image.path);
              finalGroup.imgUrl = imgUrl;
              await FirestoreService.createGroup(finalGroup);
              setModalState(() {
                currentPage = 3;
              });
            }

            return currentPage == 0
                ? createGroupBottomSheetPage1(context, changePage) : currentPage == 1
                ? createGroupBottomSheetPage2(context, changePage, updatePhoto, finalImage, submitGroup) : currentPage == 2
                ? createGroupBottomSheetPage3(context)
                : createGroupBottomSheetPage4(context, finalGroup);
          });
        }).then((value) {
          setState(() {});
    });
  }

  Widget createGroupBottomSheetPage1(BuildContext context, Function(int, Group) changePage) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                      alignment: Alignment.topLeft,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.close)
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  changePage(1, Group(groupName: _groupNameController.text));
                },
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text("Submit", style: TextStyle(fontSize: 24),),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Enter Camera Name:", style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 16,),
                  TextField(
                    controller: _groupNameController,
                    autofocus: true,
                    maxLength: 25,
                    style: TextStyle(color: AppColors.text, fontSize: 24),
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.button
                            )
                        )
                    ),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  Widget createGroupBottomSheetPage2(BuildContext context, Function(int, Group) changePage, Function(File?) updatePhoto, File? image, Function(File) submitGroup) {

    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await ImagePicker().pickImage(source: source);
      image = pickedFile != null ? File(pickedFile.path) : null;
      updatePhoto(image);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    changePage(0, Group());
                  },
                  child: Container(
                      alignment: Alignment.topLeft,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.arrow_back_ios)
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    if(image == null ) return;
                    HapticFeedback.lightImpact();
                    submitGroup(image!);
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                      color: image == null ? Colors.grey : AppColors.button,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text("Submit", style: TextStyle(fontSize: 24),),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text("Select Album Photo", style: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 16,),
                  image == null
                      ? Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/images/empty_profile.png")
                        )
                    ),
                  )
                      : ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.file(image!, fit: BoxFit.cover,),
                    ),
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          try {
                            await _pickImage(ImageSource.camera);
                          } catch(e) {
                            print(e.toString());
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.button
                          ),
                          child: const Center(
                            child: Text("From Camera"),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16,),
                      InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          try {
                            await _pickImage(ImageSource.gallery);
                          } catch(e) {
                            print(e.toString());
                          }

                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.button
                          ),
                          child: const Center(
                            child: Text("From Gallery"),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          )
      ),
    );
  }

  Widget createGroupBottomSheetPage3(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget createGroupBottomSheetPage4(BuildContext context, Group group) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.close),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Share this camera with your friends!", style: TextStyle(color: Colors.white),),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: group.groupId!,
                  ),
                )

              ],
            ),
          ],
        )
    );
  }

  Widget topRow() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("@${currentUser.username}", style: TextStyle(color: AppColors.text),)
        ],
      ),
    );
  }

}
