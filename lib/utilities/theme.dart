import 'package:flutter/material.dart';

import '../constants/color_constants.dart';


final appTheme = ThemeData(
  primaryColor: AppColors.spaceCherry,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.spaceCherry),
);
