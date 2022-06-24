import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tela_moinho/models/lista_alertas.dart';
import 'package:tela_moinho/utils/constants.dart';

class ListaAlertasDao {
  Future<ListaAlertas> getAlertas() async {
    var response = await http.get(
      Uri.parse(
        "$serverURL/idw/rest/injet/ihmweb3/pastore/alertascaixa",
      ),
    );

    if (response.statusCode == 200) {
      print('mandando resposta ListaAlertas');
      // print(response.body);

      return ListaAlertas.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('response.erro ListaAlertas');
      print(response.body);
      throw Exception('Failed to load ListaAlertas');
    }
  }
}
