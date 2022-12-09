import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../constants/color_constants.dart';
import '../provider/auth_provider.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(
            msg: 'Login Failed', backgroundColor: AppColors.spaceCherry);
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(
            msg: 'Login Cancelled', backgroundColor: AppColors.spaceCherry);
        break;
      case Status.authenticated:
        Fluttertoast.showToast(
            msg: 'Login Successful', backgroundColor: AppColors.spaceCherry);
        break;
      default:
        break;
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.spaceCherry,
    ));
    return Scaffold(
      body: Container(
        color: AppColors.spaceCherry,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 10, top: 50),
                      child: const Text(
                        'Welcome to Chato',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'BTP',
                          fontSize: 55,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Chato is more than just a regular chat app, we will always keep you connected with others',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/images/login.png',
                  )),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/wave.png',
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Center(
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: FloatingActionButton(
                            onPressed: () async {
                              try {
                                bool isSuccess =
                                    await authProvider.handleGoogleSignIn();
                                if (isSuccess) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              } on PlatformException catch (e) {
                                Fluttertoast.showToast(
                                    msg: 'Login Failed',
                                    backgroundColor: AppColors.spaceCherry);
                                debugPrint('debug: $e');
                              }
                            },
                            elevation: 10,
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.spaceCherry,
                            splashColor: AppColors.spaceCherry,
                            child: Image.asset(
                              'assets/images/google.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 150),
                      child: authProvider.status == Status.authenticating
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(right: 40, left: 40),
                              child: LinearProgressIndicator(
                                color: AppColors.spaceCherry,
                                backgroundColor:
                                    AppColors.spaceCherry.withOpacity(0.5),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
