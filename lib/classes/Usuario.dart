class Usuario {
  String _idUsuario;
  String _nome;
  String _cpf;
  String _rg;
  String _email;
  String _carteiraSus;
  String _senha;
  String _dtNascimento;
  String _cep;
  String _endereco;
  String _cidade;
  String _estado;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this.nome,
      "carteiraSus": this.carteiraSus,
      "email": this.email,
      "senha": this.senha,
      "cpf": this.cpf,
      "rg": this.rg,
      "dtNascimento": this.dtNascimento,
      "cep": this.cep,
      "endereco": this.endereco,
      "cidade": this.cidade,
      "estado": this.estado
    };

    return map;
  }

  String get estado => _estado;

  set estado(String value) {
    _estado = value;
  }

  String get cidade => _cidade;

  set cidade(String value) {
    _cidade = value;
  }

  String get endereco => _endereco;

  set endereco(String value) {
    _endereco = value;
  }

  String get dtNascimento => _dtNascimento;

  set dtNascimento(String value) {
    _dtNascimento = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get carteiraSus => _carteiraSus;

  set carteiraSus(String value) {
    _carteiraSus = value;
  }

  String get cpf => _cpf;

  set cpf(String value) {
    _cpf = value;
  }

  String get rg => _rg;

  set rg(String value) {
    _rg = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get cep => _cep;

  set cep(String value) {
    _cep = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }


}