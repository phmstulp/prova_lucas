import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AbaConsultas extends StatefulWidget {
  @override
  _AbaConsultasState createState() => _AbaConsultasState();
}

class _AbaConsultasState extends State<AbaConsultas> {
  List _itens = [];

  @override
  void initState() {
    super.initState();
    _listar();
  }

  void _listar() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _itens = [];
    Firestore db = Firestore.instance;
    await db.collection("sintomas").where("idUsuario", isEqualTo: usuarioLogado.uid).getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        setState(() {
          _itens.add(result.data);
          print(_itens);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
            itemCount: _itens.length,
            itemBuilder: (context, indice) {
              return ListTile(
                title: Text(_itens[indice]["protocolo"]),
                subtitle: Text(_itens[indice]["descricao"] +
                    "\n" +
                    _itens[indice]["temperatura"] +
                    "\n" +
                    "Febre: " +
                    _itens[indice]["febre"].toString() +
                    " - " +
                    "Diarréia: " +
                    _itens[indice]["diarreia"].toString() +
                    " - " +
                    "Coriza: " +
                    _itens[indice]["coriza"].toString() +
                    " - " +
                    "Tosse: " +
                    _itens[indice]["tosse"].toString() +
                    " - " +
                    "Espirro: " +
                    _itens[indice]["espirro"].toString()),
              );
            }),
      ),
    );
  }
}
