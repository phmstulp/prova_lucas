import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provalucas/classes/Sintomas.dart';
import 'dart:io';

class AbaSintomas extends StatefulWidget {
  @override
  _AbaSintomasState createState() => _AbaSintomasState();
}

class _AbaSintomasState extends State<AbaSintomas> {
  TextEditingController _controlerDescricao = TextEditingController();
  bool _febre = false;
  bool _diarreia = false;
  bool _coriza = false;
  bool _tosse = false;
  bool _espirro = false;
  double temperatura = 36;
  String label = "36";
  String _mensagemErro = "";
  String numProtocolo = "0";
  int contador = 0;

  List<String> urlImagens = [];

  File _imagem;
  String _idUsuarioLogado = "";
  String _urlImagemRecuperada;
  bool _subindoImagem = false;

  String _mensagemLocalizacao = "";

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _position = CameraPosition(target: LatLng(-24.5518584, -54.0593179), zoom: 10);
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void _recuperaId() async {
    List _itens = [];
    Firestore db = Firestore.instance;
    await db.collection("sintomas").getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        setState(() {
          _itens.add(result.data);
        });
      });
    });
    print(_itens.length);
    numProtocolo = _itens.length.toString();
  }

  Future _recuperarImagem(String origemImagem) async {
    File imagemSelecionada;
    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.camera);
        _imagem = imagemSelecionada;
        if (_imagem != null) {
          _subindoImagem = true;
          _uploadImagem();
        }
        break;
      case "galeria":
        imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);

        break;
    }
    setState(() {
      _imagem = imagemSelecionada;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
        contador++;
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    _idUsuarioLogado = usuarioLogado.uid;

    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz.child("imagens").child(_idUsuarioLogado +"-"+ numProtocolo +"-"+ contador.toString() + ".jpg");

    StorageUploadTask task = arquivo.putFile(_imagem);

    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    urlImagens.add(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  void _limparCampos(){
    _controlerDescricao.text = "";
    _febre = false;
    _diarreia = false;
    _coriza = false;
    _tosse = false;
    _espirro = false;
    temperatura = 31;
    label = "31";
    _mensagemErro = "";
    urlImagens = [];
  }

  _validaCampos() async {
    if (_controlerDescricao.text.isNotEmpty) {
      Firestore db = Firestore.instance;
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseUser usuarioLogado = await auth.currentUser();

      Sintomas sintomas = Sintomas();
      sintomas.protocolo = numProtocolo;
      sintomas.idUsuario = usuarioLogado.uid;
      sintomas.descricao = _controlerDescricao.text.toString();
      sintomas.febre = _febre;
      sintomas.diarreia = _diarreia;
      sintomas.coriza = _coriza;
      sintomas.tosse = _tosse;
      sintomas.espirro = _espirro;
      sintomas.temperatura = temperatura.toString();
      sintomas.urlImagens = urlImagens;
      contador = 0;

      db.collection("sintomas").add(sintomas.toMap());
      _limparCampos();
      _recuperaId();
    }
  }

  _onMapCreate(GoogleMapController googleMapController) {
    _controller.complete(googleMapController);
  }

  _recuperarLocalizacao() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> listaEnderecos = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark endereco = listaEnderecos[0];

    String rua = endereco.thoroughfare;
    String cep = endereco.postalCode;
    String cidade = endereco.subAdministrativeArea ;
    String estado = endereco.administrativeArea;
    String nr = endereco.subThoroughfare;
    String textomarker =
        cep + "\n"
            + rua + " - " + nr + "\n"
            + cidade + " - " + estado;
    setState(() {
      _mensagemLocalizacao = textomarker;
    });
    final Marker marker = Marker(
      markerId: MarkerId("marker"),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: InfoWindow(title: 'Posicao: ' + position.latitude.toString() +' - '+ position.longitude.toString()),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      _position = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 10);
      markers[MarkerId("marker")] = marker;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperaId();
    _limparCampos();
    _recuperarLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CheckboxListTile(
                    title: Text("Febre"),
                    activeColor: Color(0xff800000),
                    value: _febre,
                    onChanged: (bool valor) {
                      setState(() {
                        _febre = valor;
                      });
                    }),
                CheckboxListTile(
                    title: Text("Diarréia"),
                    activeColor: Color(0xff800000),
                    value: _diarreia,
                    onChanged: (bool valor) {
                      setState(() {
                        _diarreia = valor;
                      });
                    }),
                CheckboxListTile(
                    title: Text("Coriza"),
                    activeColor: Color(0xff800000),
                    value: _coriza,
                    onChanged: (bool valor) {
                      setState(() {
                        _coriza = valor;
                      });
                    }),
                CheckboxListTile(
                    title: Text("Tosse"),
                    activeColor: Color(0xff800000),
                    value: _tosse,
                    onChanged: (bool valor) {
                      setState(() {
                        _tosse = valor;
                      });
                    }),
                CheckboxListTile(
                    title: Text("Espirro"),
                    activeColor: Color(0xff800000),
                    value: _espirro,
                    onChanged: (bool valor) {
                      setState(() {
                        _espirro = valor;
                      });
                    }),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextFormField(
                    controller: _controlerDescricao,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Descrição",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),
                Slider(
                    value: temperatura,
                    min: 30,
                    max: 45,
                    label: label,
                    divisions: 100,
                    activeColor: Color(0xff800000),
                    inactiveColor: Color(0xffFA8072),
                    onChanged: (double novoValor){
                      setState(() {
                        temperatura = novoValor;
                        label = novoValor.toString();
                      });
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                      child: Text("Câmera"),
                    ),
                    FlatButton(
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                      child: Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 16),
                  child: RaisedButton(
                      child: Text(
                        "Registrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.red,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validaCampos();
                      }),
                ),
                Center(
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Localização Atual", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 300,
                  child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _position,
                      onMapCreated: _onMapCreate,
                      markers: Set<Marker>.of(markers.values)
                  ),
                ),
                Center(
                  child: Text(
                    _mensagemLocalizacao,
                    style: TextStyle(fontSize: 24, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  height: 300,
                  child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _position,
                      onMapCreated: _onMapCreate,
                      markers: Set<Marker>.of(markers.values)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
