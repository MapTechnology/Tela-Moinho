import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tela_moinho/models/produtos_op.dart';
import 'package:tela_moinho/utils/constants.dart';

class ProdutosOPDao {
  Future<ProdutoOP> getOpProdutos(String maquina) async {
    var response = await http.get(
      Uri.parse(
        "$serverURL/idw/rest/injet/monitorizacao/pam/moinho/produtosop?cdMaquina=$maquina",
      ),
    );

    if (response.statusCode == 200) {
      print('mandando resposta ListaProdutos');
      // print(response.body);

      return ProdutoOP.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('response.erro ProdutoOP');
      print(response.body);
      throw Exception('Failed to load ProdutoOP');
    }
  }
}
