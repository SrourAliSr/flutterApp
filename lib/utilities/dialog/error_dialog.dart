import 'package:flutter/material.dart';
import 'package:flutterapp/utilities/dialog/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error has been occured!',
    content: text,
    optionBuilder: () => {
      'Ok': null,
    },
  );
}
