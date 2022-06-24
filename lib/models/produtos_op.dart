class ProdutoOP {
  List<DetalhesProdutos>? produtos;

  ProdutoOP({this.produtos});

  factory ProdutoOP.fromJson(Map<String, dynamic> json) {
    List<DetalhesProdutos> lista = [];

    for (dynamic i in json['produtos']) {
      DetalhesProdutos produto = DetalhesProdutos.fromJson(i);
      lista.add(produto);
    }

    return ProdutoOP(
      produtos: lista,
    );
  }
}

class DetalhesProdutos {
  String? nrOP;
  String? nropExibicao;
  String? cdMolde;
  String? cdEstrutura;
  String? cdProduto;
  String? dsProduto;
  String? pesoLiqGr;

  DetalhesProdutos({
    this.nrOP,
    this.nropExibicao,
    this.cdMolde,
    this.cdEstrutura,
    this.cdProduto,
    this.dsProduto,
    this.pesoLiqGr,
  });

  factory DetalhesProdutos.fromJson(Map<String, dynamic> json) {
    return DetalhesProdutos(
      nrOP: json['nrOP'],
      nropExibicao: json['nropExibicao'],
      cdMolde: json['cdMolde'],
      cdEstrutura: json['cdEstrutura'],
      cdProduto: json['cdProduto'],
      dsProduto: json['dsProduto'],
      pesoLiqGr: json['pesoLiqGr'],
    );
  }
}
