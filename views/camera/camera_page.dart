import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:moment/models/group_image_model.dart';
import 'package:moment/models/group_model.dart';
import 'package:moment/services/firebase_storage_service.dart';
import 'package:moment/services/firestore_service.dart';
import 'package:moment/views/camera/join_camera_page.dart';
import 'package:pinput/pinput.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../main.dart';
import '../../models/app_colors_model.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  List<Group> currentGroups = List.generate(myGroups.length, (index) => myGroups[index])
      .where((group) => group.endDate!.isAfter(DateTime.now())).toList();

  Group individualGroup = List.generate(myGroups.length, (index) => myGroups[index]).where((group) => group.individual!).first;


  @override
  bool wantKeepAlive = true;
  late Group currentGroup = currentGroups[0];
  bool _isLoading = false;
  late CameraController controller;
  int thisCamera = 0;
  FlashMode _flashMode = FlashMode.auto;
  bool _isCameraInit = false;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;


  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  Future<void> _initializeController() async {
    _isCameraInit = false;
    final CameraController cameraController =
    CameraController(cameras[thisCamera], ResolutionPreset.max, imageFormatGroup: ImageFormatGroup.bgra8888);
    controller = cameraController;
    controller.setFlashMode(_flashMode);

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      if (mounted) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Camera Access Denied"),
                content: const Text("Go to settings and allow camera access."),
                actions: [
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
      }
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
        // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
        // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          showInSnackBar('${e.code}\n${e.description}');
          break;
      }
    }

    if (mounted) {
      setState(() {
        _isCameraInit = true;
      });
    }
  }

  void changeCamera(String groupId) {
    setState(() {
      currentGroup = currentGroups.where((group) => group.groupId == groupId).first;
    });
  }

  void changeFlash() {
    setState(() {
      switch(_flashMode) {
        case FlashMode.auto:
          _flashMode = FlashMode.off;
          break;
        case FlashMode.off:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.auto;
      }
      controller.setFlashMode(_flashMode);
    });
  }

  void doubleTapGesture() {
    setState(() {
      switch (thisCamera) {
        case 0:
          thisCamera = 1;
          break;
        case 1:
          thisCamera = 0;
          break;
        case 2:
          thisCamera = 1;
          break;
        case 3:
          thisCamera = 1;
      }
    });
    _initializeController();
  }

  Future<void> setFocus(TapUpDetails details) async {
    if(controller.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;
      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * controller.value.aspectRatio;
      double xp = x/fullWidth;
      double yp = y/cameraHeight;

      Offset point = Offset(xp, yp);
      print("point: $point");

      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);


      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });


    }
  }

  Future<void> _takePic() async {
    setState(() {
      _isLoading = true;
    });
    if (!controller.value.isInitialized) {}
    if (controller.value.isTakingPicture) {}
    try {
      XFile? picture = await controller.takePicture();

      String imgUrl = await StorageService.uploadCameraImage(picture.path, currentGroup);
      await FirestoreService.addImageToGroup(GroupImage(imgUrl: imgUrl, ownerId: FirebaseAuth.instance.currentUser!.uid, dateTimeTaken: DateTime.now(), localImgPath: picture.path, groupName: currentGroup.groupName), currentGroup);

    } catch (e) {
      print("Failure! $e ");
    }
    setState(() {
      _isLoading = false;
    });
  }

  showQrCode(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: AppColors.background,
        context: context,
        builder: (context) {
          return SizedBox(
            height: 350,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      "Share this Camera with your Friends!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: QrImageView(
                          data: currentGroup.groupId!,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget zoomLevel(BuildContext context) {
    return thisCamera == 1
        ? Container() : cameras.length == 4
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                thisCamera = 3;
              });
              _initializeController();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Text(".5x", style: thisCamera == 3 ? const TextStyle(fontSize: 25, color: Colors.yellow) : const TextStyle(fontSize: 16, color: Colors.grey),),
            )
        ),
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                thisCamera = 0;
              });
              _initializeController();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Text("1x", style: thisCamera == 0 ? const TextStyle(fontSize: 25, color: Colors.yellow) : const TextStyle(fontSize: 16, color: Colors.grey),),
            )
        ),
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                thisCamera = 2;
              });
              _initializeController();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Text("2x", style: thisCamera == 2 ? const TextStyle(fontSize: 25, color: Colors.yellow) : const TextStyle(fontSize: 16, color: Colors.grey),),
            )
        )
      ],
    ) : cameras.length == 3
        ? Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                thisCamera = 2;
              });
              _initializeController();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Text(".5x", style: thisCamera == 2 ? const TextStyle(fontSize: 25, color: Colors.yellow) : const TextStyle(fontSize: 16, color: Colors.grey),),
            )
        ),
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                thisCamera = 0;
              });
              _initializeController();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.bottomCenter,
              child: Text("1x", style: thisCamera == 0 ? const TextStyle(fontSize: 25, color: Colors.yellow) : const TextStyle(fontSize: 16, color: Colors.grey),),
            )
        ),
      ],
    ) : Container();
  }

  void swipeUpShowCameras(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.black,
      isDismissible: true,
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView(
              children: [
                Center(
                  child: Text("My Groups", style: TextStyle(color: AppColors.text, fontSize: 24),),
                ),
                const SizedBox(height:16,),
                SizedBox(
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
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      changeCamera(individualGroup.groupId!);
                                      Navigator.pop(context);
                                    },
                                    child: SizedBox(
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
                ),
                Column(
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
                                      changeCamera(group.groupId!);
                                      Navigator.pop(context);
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
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void joinCamera() {

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
        if(!mounted) return;
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => JoinCameraPage(group: map.values.first)));
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
        return Padding(
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
                    autofocus: false,
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
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _isCameraInit
        ? Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1/controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      HapticFeedback.lightImpact();
                      doubleTapGesture();
                    },
                    onTapUp: (details) {
                      setFocus(details);
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: CameraPreview(controller),
                        ),
                        if(showFocusCircle) Positioned(
                          top: y-20,
                          left: x-20,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                  SafeArea(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        swipeUpShowCameras(context);
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(currentGroup.imgUrl!)
                                    )
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(currentGroup.groupName!, style: TextStyle(color: AppColors.text, fontSize: 24),),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Text(DateFormat('h:mm a').format(currentGroup.endDate!), style: TextStyle(color: AppColors.text, fontSize: 18),),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    )
                  ),
                  Positioned(
                    bottom: 10,
                    child: Column(
                      children: [
                        zoomLevel(context),
                        const SizedBox(height: 10,),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _takePic();
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                ],
              )
            )
          ),
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(

              )
            ],
          )
        ],
      ),
    )
        : const CircularProgressIndicator();
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
