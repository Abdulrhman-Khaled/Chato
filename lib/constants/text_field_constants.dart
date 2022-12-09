import 'package:flutter/material.dart';
import 'package:chato_app/constants/all_constants.dart';

const kTextInputDecoration = InputDecoration(
  labelStyle: TextStyle(
    color: AppColors.black,
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.lightGrey, width: 2),
    borderRadius: BorderRadius.all(
      Radius.circular(30)
      ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.spaceCherry, width: 2),
    borderRadius: BorderRadius.all(
      Radius.circular(30)
      ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
    borderRadius: BorderRadius.all(
      Radius.circular(30),
    ),
  ),
);
