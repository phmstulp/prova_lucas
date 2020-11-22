import 'package:flutter/material.dart';

class InputCustomizado extends StatelessWidget {
  final String hint;
  final bool obscure;
  final Icon icon;
  final TextEditingController controller;

  InputCustomizado(
      {@required this.hint,
      this.obscure = false,
      this.icon = const Icon(Icons.person),
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: TextField(
        obscureText: this.obscure,
        decoration: InputDecoration(
            icon: this.icon,
            border: InputBorder.none,
            hintText: this.hint,
            hintStyle: TextStyle(color: Colors.pinkAccent[600], fontSize: 18)),
        controller: controller,
      ),
    );
  }
}
