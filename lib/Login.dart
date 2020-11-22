import 'dart:ui';
import 'package:provalucas/InputCustomizado.dart';
import 'package:provalucas/SplashScreen.dart';
import 'package:provalucas/classes/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  AnimationController _controllerAnimacao;
  Animation<double> _animacaoBlur;
  Animation<double> _animacaoFade;
  Animation<double> _animacaoSize;

  _validarCampos() {
    String email = _controllerEmail.text.toString();
    String senha = _controllerSenha.text.toString();

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty) {
        setState(() {
          _mensagemErro = "Login sucesso!";
          print(_mensagemErro);
        });

        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _autenticandoUsuario(usuario);
      } else {
        setState(() {
          _mensagemErro = "Favor preencher a senha!";
          print(_mensagemErro);
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Favor preencher o e-mail utilizando um @!";
        print(_mensagemErro);
      });
    }
  }

  _autenticandoUsuario(Usuario usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaserUser) {
      Navigator.pushReplacementNamed(context, "/splash");
    }).catchError((error) {
      setState(() {
        _mensagemErro = "Erro au autenticar o usuário!" + error.toString();
        print(_mensagemErro);
      });
    });
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    auth.signOut(); //verificou que o usuário está logado, faça o logoff

    if (usuarioLogado != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashScreen()));
    }
  }

  @override
  void initState() {
    _verificarUsuarioLogado();
    super.initState();
    _controllerAnimacao = AnimationController(
        duration: Duration(milliseconds: 4000), vsync: this);
    _animacaoBlur = Tween<double>(begin: 5, end: 0).animate(
        CurvedAnimation(parent: _controllerAnimacao, curve: Curves.ease));
    _animacaoFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _controllerAnimacao, curve: Curves.easeInOutQuint));
    _animacaoSize = Tween<double>(begin: 0, end: 500).animate(
        CurvedAnimation(parent: _controllerAnimacao, curve: Curves.decelerate));
    _controllerAnimacao.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/bg.png"), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AnimatedBuilder(
                animation: _animacaoBlur,
                builder: (context, widget) {
                  return Container(
                    height: 370,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("imagens/fundo.png"),
                            fit: BoxFit.fill)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: _animacaoBlur.value,
                          sigmaY: _animacaoBlur.value),
                    ),
                  );
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _animacaoSize,
                      builder: (context, widget) {
                        return Container(
                          width: _animacaoSize.value,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[200],
                                    blurRadius: 15,
                                    spreadRadius: 4)
                              ]),
                          child: Column(
                            children: <Widget>[
                              InputCustomizado(
                                hint: "Email",
                                obscure: false,
                                icon: Icon(Icons.person),
                                controller: _controllerEmail,
                              ),
                              InputCustomizado(
                                hint: "Senha",
                                obscure: false,
                                icon: Icon(Icons.lock),
                                controller: _controllerSenha,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    AnimatedBuilder(
                        animation: _animacaoSize,
                        builder: (context, widget) {
                          return InkWell(
                            onTap: () {
                              _validarCampos();
                            },
                            child: Container(
                              width: _animacaoSize.value,
                              height: 50,
                              child: Center(
                                child: Text(
                                  "Entrar",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Color.fromRGBO(128, 0, 0, 1),
                                    Color.fromRGBO(128, 0, 0, 1),
                                  ])),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    FadeTransition(
                      opacity: _animacaoFade,
                      child: GestureDetector(
                        child: Text(
                          "Esqueci minha senha!",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, "/recuperasenha");
                        },
                      ),
                    ),
                    FadeTransition(
                      opacity: _animacaoFade,
                      child: GestureDetector(
                        child: Text(
                          "Não possui conta? Cadastre-se!",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/cadastro");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ), //padding: EdgeInsets.all(18),
      ),
    );
  }
}
