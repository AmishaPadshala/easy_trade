import 'package:flutter/material.dart';

ShapeDecoration getDropDownShape(BuildContext context) {
  return ShapeDecoration(
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: Theme.of(context).dividerColor,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(5.0),
    ),
  );
}
