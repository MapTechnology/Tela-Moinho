import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tela_moinho/pages/config_page.dart';
import 'package:tela_moinho/pages/moinho_page.dart';
import 'package:tela_moinho/utils/constants.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  // prefs.remove('server');
  getServer();

  // configuração para manter dispositivo em landscape
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitDown,
  //   DeviceOrientation.portraitUp,
  // ]).then((_) {
  runApp(
    const RestartWidget(
      child: MyApp(),
    ),
  );
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // *botoes de navegação e o status bar do dispositivo somem quando a aplicação está aberta
    // ignore: deprecated_member_use
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        checkboxTheme: CheckboxThemeData(
          side: MaterialStateBorderSide.resolveWith(
              (_) => const BorderSide(width: 1, color: Colors.blue)),
          fillColor: MaterialStateProperty.all(Colors.blue),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: prefs.getString('server') == null
          ? const ConfigPage()
          : const MoinhoPage(),
    );
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({Key? key, required this.child}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
