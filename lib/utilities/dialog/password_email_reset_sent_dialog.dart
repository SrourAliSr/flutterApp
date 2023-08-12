import 'package:flutter/material.dart';
import 'package:flutterapp/utilities/dialog/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content:
        'we have sent you an email for resetting your password!, please check your emails',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
