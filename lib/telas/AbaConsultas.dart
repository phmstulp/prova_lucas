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

  void _showDialog(Text conteudo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Sintomas"),
          content: conteudo,
          actions: <Widget>[
            // define os botões na base do dialogo
            new FlatButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
            itemCount: _itens.length,
            itemBuilder: (context, indice) {
              return ListTile (
                title: Text(_itens[indice]["protocolo"]),
                subtitle: Text(
                    _itens[indice]["descricao"]
                ),
                contentPadding: EdgeInsets.all(9),
                onTap: () {
                  _showDialog(
                      new Text(
                          _itens[indice]["descricao"]
                              +"\nTemperatura: "+ _itens[indice]["temperatura"]
                              +"\nFebre: " + _itens[indice]["febre"].toString()
                              +"\nDiarréia: " + _itens[indice]["diarreia"].toString()
                              +"\nCoriza: " + _itens[indice]["coriza"].toString()
                              +"\nTosse: " + _itens[indice]["tosse"].toString()
                              +"\nEspirro: " + _itens[indice]["espirro"].toString()
                      )
                  );
                },
              );
            }),
      ),
    );
  }
}
