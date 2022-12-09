import 'dart:async';
import 'package:chato_app/screens/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../models/chat_user.dart';
import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../provider/auth_provider.dart';
import '../provider/home_provider.dart';
import '../utilities/debouncer.dart';
import '../utilities/keyboard_utils.dart';
import '../widgets/loading_view.dart';
import 'chat_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  final String _textSearch = "";
  bool isLoading = false;

  List<QueryDocumentSnapshot> listMessages = [];

  late AuthProvider authProvider;
  late String currentUserId;
  late HomeProvider homeProvider;

  Debouncer searchDebouncer = Debouncer(milliseconds: 300);
  StreamController<bool> buttonClearController = StreamController<bool>();
  TextEditingController searchTextEditingController = TextEditingController();

  Future<void> googleSignOut() async {
    authProvider.googleSignOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    buttonClearController.close();
  }

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    homeProvider = context.read<HomeProvider>();
    if (authProvider.getFirebaseUserId()?.isNotEmpty == true) {
      currentUserId = authProvider.getFirebaseUserId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false);
    }

    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.spaceCherry,
    ));
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              'Chato',
              style: TextStyle(
                fontFamily: 'BTP',
                color: AppColors.white,
                fontSize: 30,
              ),
            ),
            backgroundColor: AppColors.spaceCherry,
            actions: [
              IconButton(
                  onPressed: () => googleSignOut(),
                  icon: const Icon(Icons.logout)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()));
                  },
                  icon: const Icon(Icons.person)),
            ]),
        body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap back button again to exit!'),
            backgroundColor: AppColors.spaceCherry,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: homeProvider.getFirestoreData(
                          FirestoreConstants.pathUserCollection,
                          _limit,
                          _textSearch),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          if ((snapshot.data?.docs.length ?? 0) > 0) {
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) => buildItem(
                                  context, snapshot.data?.docs[index]),
                              controller: scrollController,
                            );
                          } else {
                            return Center(
                              child: Image.asset(
                                'assets/images/nomessage.png',
                                height: 250,
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.spaceCherry,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                child:
                    isLoading ? const LoadingView() : const SizedBox.shrink(),
              ),
            ],
          ),
        ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? documentSnapshot) {
    final firebaseAuth = FirebaseAuth.instance;
    if (documentSnapshot != null) {
      ChatUser userChat = ChatUser.fromDocument(documentSnapshot);
      if (userChat.id == currentUserId) {
        return const SizedBox.shrink();
      } else {
        return Column(
          children: [
            TextButton(
              style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      AppColors.spaceCherry.withOpacity(0.5))),
              onPressed: () {
                if (KeyboardUtils.isKeyboardShowing()) {
                  KeyboardUtils.closeKeyboard(context);
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              peerId: userChat.id,
                              peerAvatar: userChat.photoUrl,
                              peerNickname: userChat.displayName,
                              userAvatar: firebaseAuth.currentUser!.photoURL!,
                            )));
              },
              child: ListTile(
                focusColor: AppColors.spaceCherry,
                hoverColor: AppColors.spaceCherry,
                leading: userChat.photoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: FullScreenWidget(
                          backgroundColor: AppColors.spaceCherry,
                          child: Image.network(
                            userChat.photoUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            loadingBuilder: (BuildContext ctx, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                      color: AppColors.spaceCherry,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null),
                                );
                              }
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return FullScreenWidget(
                                  backgroundColor: AppColors.spaceCherry,
                                  child: const Icon(Icons.account_circle,
                                      size: 50));
                            },
                          ),
                        ),
                      )
                    : FullScreenWidget(
                        backgroundColor: AppColors.spaceCherry,
                        child: const Icon(
                          Icons.account_circle,
                          size: 50,
                        ),
                      ),
                title: Text(
                  userChat.displayName,
                  style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  userChat.aboutMe.isNotEmpty
                      ? userChat.aboutMe
                      : "Hello i'm using chato!",
                  style: const TextStyle(
                    color: AppColors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const Divider(),
          ],
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
