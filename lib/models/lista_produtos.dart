class ListaProdutos {
  List<Produtos>? produtos;

  ListaProdutos({this.produtos});

  factory ListaProdutos.fromJson(Map<String, dynamic> json) {
    List<Produtos> lista = [];

    for (dynamic i in json['produtos']) {
      Produtos produto = Produtos.fromJson(i);
      lista.add(produto);
    }

    return ListaProdutos(
      produtos: lista,
    );
  }
}

class Produtos {
  String? cdProduto;
  String? dsProduto;
  String? pesoLiqGr;

  Produtos({this.cdProduto, this.dsProduto, this.pesoLiqGr});

  factory Produtos.fromJson(Map<String, dynamic> json) {
    return Produtos(
      cdProduto: json['cdProduto'],
      dsProduto: json['dsProduto'],
      pesoLiqGr: json['pesoLiqGr'],
    );
  }
}
