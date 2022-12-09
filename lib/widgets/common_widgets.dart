import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import 'package:full_screen_image_null_safe/full_screen_image_null_safe.dart';

Widget errorContainer() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: Image.asset(
      'assets/images/img_not_available.jpeg',
      height: 200,
      width: 200,
    ),
  );
}

Widget chatImage({required String imageSrc, required Function onTap}) {
  return FullScreenWidget(
    backgroundColor: AppColors.spaceCherry,
    child: Image.network(
      imageSrc,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext ctx, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.greyColor,
            borderRadius: BorderRadius.circular(10),
          ),
          width: 200,
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.spaceCherry,
              value: loadingProgress.expectedTotalBytes != null &&
                      loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, object, stackTrace) => errorContainer(),
    ),
  );
}

Widget messageBubble(
    {required String chatContent,
    EdgeInsetsGeometry? margin,
    double borderRight = 15,
    double borderLeft = 15,
    Color? color,
    Color? textColor}) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: margin,
    width: 200,
    decoration: BoxDecoration(
      color: color,
      borderRadius:  BorderRadius.only(
        bottomRight: Radius.circular(borderRight),
        bottomLeft: Radius.circular(borderLeft),
        topLeft: const Radius.circular(15),
        topRight: const Radius.circular(15),
      ),
    ),
    child: Text(
      chatContent,
      style: TextStyle(fontSize: 16, color: textColor),
    ),
  );
}
