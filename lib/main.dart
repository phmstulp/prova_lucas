import 'package:provalucas/RouteGenerator.dart';
import 'package:flutter/material.dart';
import 'Login.dart';

void main() async {
  runApp(MaterialApp(
    home: Login(),
    theme: ThemeData(
        primaryColor: Color(0xff800000), accentColor: Color(0xffFA8072)),
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator
        .generateRoute, //onGenerateRoute é chamado toda vez que uma rota precisa ser inicializada ou aberta

  ));
}