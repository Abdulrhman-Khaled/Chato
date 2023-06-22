import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/chat_user.dart';
import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../constants/text_field_constants.dart';
import '../provider/profile_provider.dart';
import '../widgets/loading_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController? displayNameController;
  TextEditingController? displayStatueController;

  late String currentUserId;

  String id = '';
  String displayName = '';
  String photoUrl = '';
  String aboutMe = '';
  String email = '';

  String profilePicture =
      FirebaseAuth.instance.currentUser!.photoURL.toString();

  bool isLoading = false;
  File? avatarImageFile;
  late ProfileProvider profileProvider;

  final FocusNode focusNodeNickname = FocusNode();

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = profileProvider.getPrefs(FirestoreConstants.id) ?? "";
      displayName =
          profileProvider.getPrefs(FirestoreConstants.displayName) ?? "";
      photoUrl = profileProvider.getPrefs(FirestoreConstants.photoUrl) ?? "";
      aboutMe = profileProvider.getPrefs(FirestoreConstants.aboutMe) ?? "";
      email = profileProvider.getPrefs(FirestoreConstants.email) ?? "";
    });
    displayNameController = TextEditingController(text: displayName);
    displayStatueController = TextEditingController(text: aboutMe);
  }

  getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker
        .pickImage(source: ImageSource.gallery, imageQuality: 25)
        // ignore: body_might_complete_normally_catch_error
        .catchError((onError) {
      Fluttertoast.showToast(msg: onError.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
    if (image == null) {
      Fluttertoast.showToast(
          msg: 'No image chosen!', backgroundColor: AppColors.spaceCherry);
    } else {
      uploadFile(image);
    }
  }

  Future uploadFile(File image) async {
    String fileName = image.path;
    UploadTask uploadTask = profileProvider.uploadImageFile(image, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      ChatUser updateInfo = ChatUser(
          id: id,
          photoUrl: photoUrl,
          displayName: displayName,
          aboutMe: aboutMe,
          email: email);
      profileProvider
          .updateFirestoreData(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((value) async {
        await profileProvider.setPrefs(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void updateFirestoreData() {
    focusNodeNickname.unfocus();
    setState(() {
      isLoading = true;
    });
    ChatUser updateInfo = ChatUser(
        id: id,
        photoUrl: photoUrl,
        displayName: displayName,
        aboutMe: aboutMe,
        email: email);
    profileProvider
        .updateFirestoreData(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((value) async {
      await profileProvider.setPrefs(
          FirestoreConstants.displayName, displayName);
      await profileProvider.setPrefs(
        FirestoreConstants.photoUrl,
        photoUrl,
      );
      await profileProvider.setPrefs(FirestoreConstants.aboutMe, aboutMe);
      await profileProvider.setPrefs(FirestoreConstants.email, email);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: 'Update Done!', backgroundColor: AppColors.spaceCherry);
    }).catchError((onError) {
      Fluttertoast.showToast(msg: 'Update Failed!',backgroundColor: AppColors.spaceCherry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(380),
        child: Stack(
          children: [
            Container(
              color: AppColors.spaceCherry,
              child: Container(
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        const Center(
                          child: Text(
                            'Your Profile',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          bottom: 0,
                          left: 5,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(20),
                          child: avatarImageFile == null
                              ? photoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FullScreenWidget(
                                        backgroundColor: AppColors.spaceCherry,
                                        child: Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                          width: 200,
                                          height: 200,
                                          errorBuilder:
                                              (context, object, stackTrace) {
                                            return FullScreenWidget(
                                              backgroundColor:
                                                  AppColors.spaceCherry,
                                              child: const Icon(
                                                Icons.account_circle,
                                                size: 230,
                                                color: AppColors.white,
                                              ),
                                            );
                                          },
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: AppColors.white,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : FullScreenWidget(
                                      backgroundColor: AppColors.spaceCherry,
                                      child: const Icon(
                                        Icons.account_circle,
                                        size: 230,
                                        color: AppColors.white,
                                      ),
                                    )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.file(
                                    avatarImageFile!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 160,
                          right: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3,
                                color: AppColors.spaceCherry,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  50,
                                ),
                              ),
                              color: AppColors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                color: AppColors.spaceCadet,
                                onPressed: () {
                                  getImage();
                                  setState(() {
                                    profilePicture = photoUrl;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.email.toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Your Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.spaceCherry,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  decoration: kTextInputDecoration.copyWith(
                      hintText: 'Enter your name...'),
                  controller: displayNameController,
                  onChanged: (value) {
                    displayName = value;
                  },
                  focusNode: focusNodeNickname,
                ),
                const SizedBox(
                  height: 15,
                ),
                const Center(
                  child: Text(
                    'Your Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.spaceCherry,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextField(
                  decoration: kTextInputDecoration.copyWith(
                      hintText: 'Enter your current status...'),
                  controller: displayStatueController,
                  onChanged: (value) {
                    aboutMe = value;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.spaceCherry)),
                      onPressed: () {
                        updateFirestoreData();
                      },
                      child: const Text(
                        'Update Your Profile',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          Positioned(
              child: isLoading ? const LoadingView() : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
