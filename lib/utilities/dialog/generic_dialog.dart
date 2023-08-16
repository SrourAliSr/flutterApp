import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map(
          (optionTitle) {
            final values = options[optionTitle];
            return TextButton(
              onPressed: () {
                if (values != null) {
                  Navigator.of(context).pop(values);
                } else {
                  Navigator.of(context).pop();
                }
              },
              style: const ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Color.fromRGBO(0, 0, 0, 0))),
              child: Text(
                optionTitle,
              ),
            );
          },
        ).toList(),
      );
    },
  );
}
