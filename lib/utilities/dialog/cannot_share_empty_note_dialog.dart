import 'package:flutter/material.dart';
import 'package:flutterapp/utilities/dialog/generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'warning!',
    content: 'you cannot share empty note',
    optionBuilder: () => {
      'ok': null,
    },
  );
}
