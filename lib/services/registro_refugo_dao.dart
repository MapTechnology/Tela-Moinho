import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tela_moinho/models/registro_refugo.dart';
import 'package:tela_moinho/utils/constants.dart';

class RegistroRefugoDao {
  Future<RegistroRefugo> registroRefugo(jsonBody) async {
    final response = await http.post(
        Uri.parse(
            '$serverURL/idw/rest/injet/monitorizacao/pam/moinho/registrorefugo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonBody);

    if (response.statusCode == 200) {
      return RegistroRefugo.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      throw Exception('Falha ao registrar refugo');
    }
  }
}
