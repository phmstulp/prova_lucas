import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provalucas/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provalucas/classes/Usuario.dart';
import 'package:provalucas/telas/AbaConsultas.dart';
import 'package:provalucas/telas/AbaMedico.dart';
import 'package:provalucas/telas/AbaSintomas.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String _emailUsuarioLogado = "";
  List<String> itensMenu = ["Configurações", "Deslogar"];

  Future _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    setState(() {
      _emailUsuarioLogado = usuarioLogado.email;
    });
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");

  }

  _escolhaMenu(String itemEscolhido) async {
    switch (itemEscolhido){
      case "Configurações":

        break;
      case "Deslogar":
        _deslogarUsuario();
        break;
    }
    print("Item escolhido foi o : " + itemEscolhido);
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Atendimentos Hospitalares"),
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(
              text: "Sintomas",
            ),
            Tab(
              text: "Consultas",
            ),
            Tab(
              text: "Médico",
            )
          ],
        ),

        //botões de ação definidos na lista de itens
        actions: <Widget>[
          PopupMenuButton(
              onSelected: _escolhaMenu, //método para tratar uma das opções escolhidas
              itemBuilder: (context){ //criou as opções de menu
                return itensMenu.map((String item){ //percorre cada item como forma de objeto
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList();
              })
        ],

      ),
      body: TabBarView(
          controller: _tabController,
          children: <Widget>[AbaSintomas(), AbaConsultas(), AbaMedico()]),
    );
  }
}
