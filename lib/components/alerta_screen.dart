import 'package:flutter/material.dart';

class AlertaScreen extends StatefulWidget {
  final dynamic message;
  const AlertaScreen({Key? key, required this.message}) : super(key: key);

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text(
          'Alerta',
          style: TextStyle(fontSize: 35.0),
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              widget.message.toString(),
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 25.0),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
