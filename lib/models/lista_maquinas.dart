class ListaMaquinas {
  List<MaquinasAtivas>? maquinasAtivas;

  ListaMaquinas({this.maquinasAtivas});

  factory ListaMaquinas.fromJson(Map<String, dynamic> json) {
    List<MaquinasAtivas> lista = [];

    for (dynamic i in json['maquinasAtivas']) {
      MaquinasAtivas maquina = MaquinasAtivas.fromJson(i);
      lista.add(maquina);
    }

    return ListaMaquinas(
      maquinasAtivas: lista,
    );
  }
}

class MaquinasAtivas {
  int? idMaquina;
  String? cdMaquina;
  int? sessaoProducao;
  bool? requerFerramenta;
  bool? requerEstrutura;
  bool? requerProduto;
  bool? requerQuantidade;
  bool? requerCDM;
  bool? requerOP;
  String? nrOP;
  int? tipoParPam;
  int? statusFuncionamento;

  MaquinasAtivas({
    this.idMaquina,
    this.cdMaquina,
    this.sessaoProducao,
    this.requerFerramenta,
    this.requerEstrutura,
    this.requerProduto,
    this.requerQuantidade,
    this.requerCDM,
    this.requerOP,
    this.nrOP,
    this.tipoParPam,
    this.statusFuncionamento,
  });

  factory MaquinasAtivas.fromJson(Map<String, dynamic> json) {
    return MaquinasAtivas(
      idMaquina: json['idMaquina'],
      cdMaquina: json['cdMaquina'],
      sessaoProducao: json['sessaoProducao'],
      requerFerramenta: json['requerFerramenta'],
      requerEstrutura: json['requerEstrutura'],
      requerProduto: json['requerProduto'],
      requerQuantidade: json['requerQuantidade'],
      requerCDM: json['requerCDM'],
      requerOP: json['requerOP'],
      nrOP: json['nrOP'],
      tipoParPam: json['tipoParPam'],
      statusFuncionamento: json['statusFuncionamento'],
    );
  }
}
