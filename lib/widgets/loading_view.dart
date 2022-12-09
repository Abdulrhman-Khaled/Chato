import 'package:chato_app/constants/color_constants.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child:  Positioned(
        child:  LinearProgressIndicator(
            color: AppColors.spaceCherry,
            backgroundColor: AppColors.spaceCherry.withOpacity(0.5),
          ),
        ), 
    );
  }
}
