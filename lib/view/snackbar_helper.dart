import 'package:flutter/material.dart';

const Color litupPrimary = Color.fromRGBO(83, 17, 150, 1);
void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = litupPrimary,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      duration: duration,
    ),
  );
}
