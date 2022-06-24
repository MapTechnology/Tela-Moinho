import 'dart:convert';

import 'package:tela_moinho/models/lista_maquinas.dart';
import 'package:http/http.dart' as http;
import 'package:tela_moinho/utils/constants.dart';

class ListaMaquinasDao {
  Future<ListaMaquinas> getMaquinas() async {
    var response = await http.get(
      Uri.parse(
        "$serverURL/idw/rest/injet/monitorizacao/pam/moinho/maquinas",
      ),
    );

    if (response.statusCode == 200) {
      print('mandando resposta ListaMaquinas');
      // print(response.body);

      return ListaMaquinas.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print('response.erro ListaMaquinas');
      print(response.body);
      throw Exception('Failed to load ListaMaquinas');
    }
  }
}
