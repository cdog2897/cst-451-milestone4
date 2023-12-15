import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/app_colors_model.dart';
import '../../models/group_model.dart';
import 'dart:io';

import '../../services/firebase_storage_service.dart';
import '../../services/firestore_service.dart';

class CreateNewCameraBottomSheet {

  final BuildContext context;
  final TextEditingController _groupNameController = TextEditingController();
  CreateNewCameraBottomSheet({required this.context});

  bool isLoading = false;

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

            void profilePicLoading() {
              print("loading");
              setModalState(() {
                isLoading = !isLoading;
              });
            }

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
                ? createGroupBottomSheetPage2(context, changePage, updatePhoto, finalImage, submitGroup, profilePicLoading) : currentPage == 2
                ? createGroupBottomSheetPage3(context)
                : createGroupBottomSheetPage4(context, finalGroup);
          });
        }).then((value) {
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

  Widget createGroupBottomSheetPage2(BuildContext context, Function(int, Group) changePage, Function(File?) updatePhoto, File? image, Function(File) submitGroup, Function() profilePicLoading) {

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
                  isLoading ? Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle
                    ),
                    child: const CircularProgressIndicator(),
                  ) :
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
                            profilePicLoading();
                            await _pickImage(ImageSource.camera);
                            profilePicLoading();
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
                          profilePicLoading();
                          try {
                            await _pickImage(ImageSource.gallery);
                          } catch(e) {
                            print(e.toString());
                          }
                          profilePicLoading();
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

}