import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tela_moinho/models/lista_produtos.dart';
import 'package:tela_moinho/utils/constants.dart';

class ListaProdutosDao {
  Future<ListaProdutos> getProdutos(String produto) async {
    var response = await http.get(
      Uri.parse(
        "$serverURL/idw/rest/injet/monitorizacao/pam/moinho/produtos?pesquisa=$produto",
      ),
    );

    if (response.statusCode == 200) {
      print('mandando resposta ListaProdutos');
      // print(response.body);

      return ListaProdutos.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('response.erro ListaProdutos');
      print(response.body);
      throw Exception('Failed to load ListaProdutos');
    }
  }
}
