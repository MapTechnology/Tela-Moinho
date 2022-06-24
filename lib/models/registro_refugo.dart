class RegistroRefugo {
  int? tipoRefugo;
  String? cdMaquina;
  String? nrOP;
  String? cdMolde;
  String? cdEstrutura;
  String? cdProduto;
  String? pesoLiqProdGr;
  String? taraKg;
  String? pesoBrutoKg;
  String? pesoLiquidoKg;
  String? qtdPcs;
  String? statusResposta;

  RegistroRefugo({
    this.tipoRefugo,
    this.cdMaquina,
    this.nrOP,
    this.cdMolde,
    this.cdEstrutura,
    this.cdProduto,
    this.pesoLiqProdGr,
    this.taraKg,
    this.pesoBrutoKg,
    this.pesoLiquidoKg,
    this.qtdPcs,
    this.statusResposta,
  });

  factory RegistroRefugo.fromJson(Map<String, dynamic> json) {
    return RegistroRefugo(
      tipoRefugo: json['tipoRefugo'],
      cdMaquina: json['cdMaquina'],
      nrOP: json['nrOP'],
      cdMolde: json['cdMolde'],
      cdEstrutura: json['cdEstrutura'],
      cdProduto: json['cdProduto'],
      pesoLiqProdGr: json['pesoLiqProdGr'],
      taraKg: json['taraKg'],
      pesoBrutoKg: json['pesoBrutoKg'],
      pesoLiquidoKg: json['pesoLiquidoKg'],
      qtdPcs: json['qtdPcs'],
      statusResposta: json['statusResposta'],
    );
  }
}
