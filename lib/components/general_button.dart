import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function function;
  final BoxDecoration decoration;
  GeneralButton({
    this.text,
    this.color,
    this.function,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
      child: Material(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        elevation: 5.0,
        child: Container(
          decoration: decoration,
          child: TextButton(
            onPressed: function,
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
