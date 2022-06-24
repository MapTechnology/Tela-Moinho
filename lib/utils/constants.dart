import 'package:shared_preferences/shared_preferences.dart';

String respostaSucesso = "1";
String respostaFalha = "0";
String serverURL = "";
Exception mensagemErro = Exception();
int tempoDeAtualizacao = 5;

void getServer() async {
  final prefs = await SharedPreferences.getInstance();
  String? server;
  String? port;

  if (prefs.getString('server') == null) {
    server = "";
    port = "";
  } else {
    server = prefs.getString('server');
    port = prefs.getString('port');
    server = server!.trim();
    port = port!.trim();
    serverURL = "http://$server:$port";
  }
}
