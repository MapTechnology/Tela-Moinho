import 'dart:async';
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tela_moinho/components/alerta_screen.dart';
import 'package:tela_moinho/main.dart';
import 'package:tela_moinho/models/lista_alertas.dart';
import 'package:tela_moinho/models/lista_produtos.dart';
import 'package:tela_moinho/models/produtos_op.dart';
import 'package:tela_moinho/services/lista_alertas_dao.dart';
import 'package:tela_moinho/services/lista_maquinas_dao.dart';
import 'package:tela_moinho/services/lista_produtos_dao.dart';
import 'package:tela_moinho/services/produtos_op_dao.dart';
import 'package:tela_moinho/services/registro_refugo_dao.dart';
import 'package:tela_moinho/utils/constants.dart';

class MoinhoPage extends StatefulWidget {
  const MoinhoPage({Key? key}) : super(key: key);

  @override
  _MoinhoPageState createState() => _MoinhoPageState();
}

class _MoinhoPageState extends State<MoinhoPage> {
  String? _tipoInsercao = "maquina";
  int? _tipoRefugoMaquina = 1;
  int? _tipoRefugoProduto = 5;
  String selectedProduto = "";
  bool isTableLoading = false;
  bool isResponseLoading = false;
  bool erroNaChamada = false;
  bool carregandoChamada = false;
  bool maiorQuePesoBruto = false;
  bool valorZero = false;
  bool valorZeroPesoBruto = false;

  final ListaMaquinasDao _daoMaquinas = ListaMaquinasDao();
  final ListaProdutosDao _daoProdutos = ListaProdutosDao();
  final ProdutosOPDao _daoProdutosOP = ProdutosOPDao();
  final RegistroRefugoDao _daoRegistroRefugo = RegistroRefugoDao();
  final ListaAlertasDao _daoListaAlertas = ListaAlertasDao();

  List<DetalhesProdutos> listaProdutosOp = [];
  List<Produtos> listaProd = [];
  List<Alertas> listaAlertas = [];
  List<String> maquinas = [];
  List produtos = [];

  String cdMaquina = "";
  String nrOP = "";
  String cdMolde = "";
  String cdEstrutura = "";
  String cdProduto = "";
  String pesoLiqProdGr = "";
  TextEditingController pesoBrutoController = TextEditingController();
  TextEditingController taraController = TextEditingController();
  TextEditingController pesoLiqController = TextEditingController();
  TextEditingController qtdPecasController = TextEditingController();
  Object jsonRegistroRefugo = {};
  String _timeString = "";
  final ScrollController controller = ScrollController();

  void clearValues() {
    setState(() {
      _tipoRefugoMaquina = 1;
      _tipoRefugoProduto = 5;
      listaProdutosOp = [];
      listaProd = [];
      cdMaquina = "";
      nrOP = "";
      cdMolde = "";
      cdEstrutura = "";
      cdProduto = "";
      pesoLiqProdGr = "";
      jsonRegistroRefugo = {};
      pesoBrutoController.text = "";
      taraController.text = "";
      pesoLiqController.text = "";
      qtdPecasController.text = "";
      valorZeroPesoBruto = false;
      maiorQuePesoBruto = false;
      valorZero = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _daoListaAlertas.getAlertas().then((value) {
      listaAlertas.addAll(value.alertas!);
    });

    _getTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    Timer.periodic(Duration(seconds: tempoDeAtualizacao), (Timer t) {
      listaAlertas.clear();
      _daoListaAlertas.getAlertas().then((value) {
        listaAlertas.addAll(value.alertas!);
        setState(() {});
      });
    });

    setState(() {
      carregandoChamada = true;
    });

    _daoMaquinas.getMaquinas().then((value) {
      if (mounted) {
        setState(() {
          erroNaChamada = false;
          carregandoChamada = false;
        });
      }

      for (var maquina in value.maquinasAtivas!) {
        maquinas.add(maquina.cdMaquina!);
      }
    }).catchError((onError) {
      if (mounted) {
        setState(() {
          erroNaChamada = true;
          mensagemErro = onError;
          carregandoChamada = false;
        });
      }
    });

    _daoProdutos.getProdutos("").then((value) {
      var id = 0;
      for (var produto in value.produtos!) {
        setState(() {
          produtos.add({
            "id": ++id,
            "cdProduto": produto.cdProduto,
            "dsProduto": "$id - ${produto.cdProduto}",
          });
        });
      }
    });
  }

  void _getTime() {
    final String formattedDateTime =
        DateFormat('dd/MM/yyyy\nkk:mm').format(DateTime.now()).toString();
    // setState(() {
    _timeString = formattedDateTime;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Text(
                  _timeString.toString(),
                  style: const TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Center(
                child: Text(
                  'Tela Moinho',
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: InkWell(
                onTap: (() => RestartWidget.restartApp(context)),
                child: const Icon(
                  Icons.refresh,
                  size: 40.0,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
            child: ElevatedButton(
              onPressed: _tipoInsercao == "maquina"
                  ? cdMaquina == "" ||
                          nrOP == "" ||
                          cdMolde == "" ||
                          cdEstrutura == "" ||
                          cdProduto == "" ||
                          pesoLiqProdGr == "" ||
                          taraController.text.isEmpty ||
                          pesoBrutoController.text.isEmpty ||
                          pesoLiqController.text.isEmpty ||
                          qtdPecasController.text.isEmpty
                      ? null
                      : () => enviarRegistroRefugo()
                  : cdProduto == "" ||
                          pesoLiqProdGr == "" ||
                          taraController.text.isEmpty ||
                          pesoBrutoController.text.isEmpty ||
                          pesoLiqController.text.isEmpty ||
                          qtdPecasController.text.isEmpty
                      ? null
                      : () => enviarRegistroRefugo(),
              child: isResponseLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Concluir',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                // shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
          erroNaChamada
              ? PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Configuração'),
                      value: 1,
                      onTap: () => {
                        Future.delayed(
                          const Duration(seconds: 0),
                          () => showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              title: Text(
                                'Configurar Servidor',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: Configuracao(),
                            ),
                          ),
                        )
                      },
                    ),
                  ],
                )
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: carregandoChamada
            ? const Center(child: CircularProgressIndicator())
            : erroNaChamada
                ? const MensagemErro()
                : MediaQuery.of(context).orientation == Orientation.portrait
                    ? portraitOrientation(context)
                    : landscapeOrientation(context),
      ),
    );
  }

  Column portraitOrientation(BuildContext context) {
    return Column(
      children: [
        ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Máquina:',
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                    Visibility(
                      visible: _tipoInsercao == 'maquina',
                      child: DropdownSearch<String>(
                        mode: Mode.MENU,
                        maxHeight: 300,
                        items: maquinas,
                        showSearchBox: true,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "Escolha uma máquina",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isTableLoading = true;
                          });

                          _daoProdutosOP
                              .getOpProdutos(value!)
                              .then((produtoOp) {
                            listaProdutosOp.clear();

                            if (produtoOp.produtos!.length == 1) {
                              setState(() {
                                isTableLoading = false;

                                cdMaquina = value;
                                nrOP = produtoOp.produtos![0].nrOP!;
                                cdMolde = produtoOp.produtos![0].cdMolde!;
                                cdEstrutura =
                                    produtoOp.produtos![0].cdEstrutura!;
                                cdProduto = produtoOp.produtos![0].cdProduto!;
                                pesoLiqProdGr =
                                    produtoOp.produtos![0].pesoLiqGr!;
                              });
                            } else {
                              setState(() {
                                cdMaquina = value;

                                isTableLoading = false;
                              });
                            }

                            for (var produto in produtoOp.produtos!) {
                              setState(() {
                                listaProdutosOp.add(produto);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                leading: Transform.scale(
                  scale: 1.8,
                  child: Radio<String>(
                    value: 'maquina',
                    groupValue: _tipoInsercao,
                    onChanged: (String? value) {
                      setState(() {
                        _tipoInsercao = value;
                      });

                      clearValues();
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Produto:',
                        style: TextStyle(fontSize: 25.0),
                      ),
                    ),
                    Visibility(
                      visible: _tipoInsercao == 'produto',
                      child: DropdownSearch<dynamic>(
                        mode: Mode.MENU,
                        maxHeight: 300,
                        items: produtos.map((e) => e['dsProduto']).toList(),
                        showSearchBox: true,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "Escolha um produto",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isTableLoading = true;
                          });

                          print('value');
                          print(value);

                          var idProduto = value.toString().substring(0, 1);
                          var produtoSelecionado = produtos.where((element) =>
                              element['id'].toString() == idProduto);
                          var cdProd =
                              produtoSelecionado.elementAt(0)['cdProduto'];

                          _daoProdutos.getProdutos(cdProd).then((produto) {
                            listaProd.clear();

                            setState(() {
                              isTableLoading = false;

                              cdProduto = produto.produtos![0].cdProduto!;
                              pesoLiqProdGr = produto.produtos![0].pesoLiqGr!;
                            });

                            for (var produto in produto.produtos!) {
                              setState(() {
                                listaProd.add(produto);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                leading: Transform.scale(
                  scale: 1.8,
                  child: Radio<String>(
                    value: 'produto',
                    groupValue: _tipoInsercao,
                    onChanged: (String? value) {
                      setState(() {
                        _tipoInsercao = value;
                      });

                      clearValues();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),

        // * Tabela
        Visibility(
          visible: _tipoInsercao == 'maquina',
          child: isTableLoading
              ? const CircularProgressIndicator()
              : tabelaMaquina(),
        ),
        Visibility(
          visible: _tipoInsercao == 'produto',
          child: isTableLoading
              ? const CircularProgressIndicator()
              : tabelaProduto(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),

        // * Tipo de Refugo
        Column(
          children: [
            const Text(
              'Tipo do Refugo',
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            Visibility(
              visible: _tipoInsercao == "maquina",
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Canal'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 1,
                          groupValue: _tipoRefugoMaquina,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoMaquina = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Injetora'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 2,
                          groupValue: _tipoRefugoMaquina,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoMaquina = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _tipoInsercao == "maquina",
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Borra'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 3,
                          groupValue: _tipoRefugoMaquina,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoMaquina = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Try-out'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 4,
                          groupValue: _tipoRefugoMaquina,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoMaquina = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _tipoInsercao == "produto",
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Varredura'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 5,
                          groupValue: _tipoRefugoProduto,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoProduto = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Devolução'),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          value: 6,
                          groupValue: _tipoRefugoProduto,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoProduto = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _tipoInsercao == "produto",
              child: ListTile(
                title: const Text('Obsoleto'),
                leading: Transform.scale(
                  scale: 1.7,
                  child: Radio<int>(
                    value: 7,
                    groupValue: _tipoRefugoProduto,
                    onChanged: (int? value) {
                      setState(() {
                        _tipoRefugoProduto = value;
                      });
                    },
                  ),
                ),
              ),
            )
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),

        // * Inputs
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: pesoBrutoController,
                              keyboardType: TextInputType.number,
                              // desabilitado se o usuario ainda nao setou produto
                              enabled: cdProduto == "" ? false : true,
                              onChanged: (String value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    valorZeroPesoBruto = false;
                                  });

                                  EasyDebounce.debounce('calculo',
                                      const Duration(milliseconds: 1000), () {
                                    if (pesoBrutoController.text == "0" ||
                                        pesoBrutoController.text == "0.0") {
                                      setState(() {
                                        valorZeroPesoBruto = true;
                                      });
                                    }
                                  });
                                } else {
                                  setState(() {
                                    valorZeroPesoBruto = false;
                                  });
                                }
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                              decoration: InputDecoration(
                                // filled se o usuario ainda nao setou o produto
                                filled: cdProduto == "" ? true : false,
                                fillColor: cdProduto == ""
                                    ? const Color.fromARGB(255, 223, 221, 221)
                                    : null,
                                labelText: 'Peso Bruto (Kg)',
                                labelStyle: TextStyle(
                                  color: cdProduto == ""
                                      ? Colors.black
                                      : Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório.';
                                }
                                return null;
                              },
                            ),
                            Visibility(
                              visible: valorZeroPesoBruto,
                              child: const Text(
                                'Valor deve ser maior que 0.0',
                                style: TextStyle(
                                    fontSize: 11.0, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: taraController,
                            keyboardType: TextInputType.number,
                            // desabilitado se usuario ainda não informou peso bruto
                            enabled: pesoBrutoController.text.isEmpty ||
                                    valorZeroPesoBruto == true
                                ? false
                                : true,
                            onChanged: (String value) {
                              if (value.isNotEmpty) {
                                EasyDebounce.debounce('calculo',
                                    const Duration(milliseconds: 3000), () {
                                  double peso = double.parse(
                                    pesoBrutoController.text
                                        .replaceAll(',', '.'),
                                  );
                                  double tara = double.parse(
                                    taraController.text.replaceAll(',', '.'),
                                  );

                                  pesoBrutoController.text =
                                      peso.toStringAsFixed(4);
                                  taraController.text = tara.toStringAsFixed(4);

                                  if (tara > peso) {
                                    setState(() {
                                      maiorQuePesoBruto = true;
                                    });
                                  } else if (tara == 0) {
                                    setState(() {
                                      valorZero = true;
                                    });
                                  } else {
                                    double pesoLiq = peso - tara;
                                    double qtdPecas = (pesoLiq * 1000) /
                                        double.parse(pesoLiqProdGr);

                                    setState(() {
                                      maiorQuePesoBruto = false;
                                      valorZero = false;

                                      FocusManager.instance.primaryFocus!
                                          .unfocus();

                                      pesoBrutoController.text =
                                          peso.toStringAsFixed(4);
                                      taraController.text =
                                          tara.toStringAsFixed(4);
                                      pesoLiqController.text =
                                          pesoLiq.toStringAsFixed(4);
                                      qtdPecasController.text =
                                          qtdPecas.toStringAsFixed(4);
                                    });
                                  }
                                });
                              } else if (value.isEmpty) {
                                setState(() {
                                  maiorQuePesoBruto = false;
                                  valorZero = false;

                                  pesoLiqController.text = "";
                                  qtdPecasController.text = "";
                                });
                              }
                            },
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                            decoration: InputDecoration(
                              // filled se usuario ainda não informou peso bruto
                              filled: pesoBrutoController.text.isEmpty ||
                                      valorZeroPesoBruto == true
                                  ? true
                                  : false,
                              fillColor: pesoBrutoController.text.isEmpty ||
                                      valorZeroPesoBruto == true
                                  ? const Color.fromARGB(255, 223, 221, 221)
                                  : null,
                              labelText: 'Peso Tara (Kg)',
                              labelStyle: TextStyle(
                                color: pesoBrutoController.text.isEmpty ||
                                        valorZeroPesoBruto == true
                                    ? Colors.black
                                    : Colors.white,
                                fontFamily: 'Montserrat',
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: maiorQuePesoBruto,
                            child: const Text(
                              'Peso tara deve ser menor que peso bruto',
                              style:
                                  TextStyle(fontSize: 11.0, color: Colors.red),
                            ),
                          ),
                          Visibility(
                            visible: valorZero,
                            child: const Text(
                              'Valor deve ser maior que 0.0',
                              style:
                                  TextStyle(fontSize: 11.0, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextFormField(
                        controller: pesoLiqController,
                        enabled: false,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 223, 221, 221),
                          labelText: 'Peso Líquido (Kg)',
                          labelStyle: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontFamily: 'Montserrat',
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          // disabledBorder: OutlineInputBorder(
                          //   borderSide: BorderSide(color: Colors.grey),
                          // ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: qtdPecasController,
                      enabled: false,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 223, 221, 221),
                        labelText: 'Qtd. Peças',
                        labelStyle: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontFamily: 'Montserrat',
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        // disabledBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.grey),
                        // ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),
        const Text(
          'Chamadas de Caixa em Aberto',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        SizedBox(
          // color: Colors.red,
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.grey),
            child: RawScrollbar(
              controller: controller,
              thumbColor: Colors.grey,
              radius: const Radius.circular(20),
              trackVisibility: true,
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Data/Hora',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Cod.Máquina',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                    ),
                  ],
                  rows: listaAlertas
                      .map(
                        (prod) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                prod.dthrChamada!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                prod.cdMaquina!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Column landscapeOrientation(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Máquina:',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                    Visibility(
                      visible: _tipoInsercao == 'maquina',
                      child: DropdownSearch<String>(
                        mode: Mode.MENU,
                        maxHeight: 300,
                        items: maquinas,
                        showSearchBox: true,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "Escolha uma máquina",
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          labelStyle: TextStyle(color: Colors.black),
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isTableLoading = true;
                          });

                          _daoProdutosOP
                              .getOpProdutos(value!)
                              .then((produtoOp) {
                            listaProdutosOp.clear();

                            if (produtoOp.produtos!.length == 1) {
                              setState(() {
                                isTableLoading = false;

                                cdMaquina = value;
                                nrOP = produtoOp.produtos![0].nrOP!;
                                cdMolde = produtoOp.produtos![0].cdMolde!;
                                cdEstrutura =
                                    produtoOp.produtos![0].cdEstrutura!;
                                cdProduto = produtoOp.produtos![0].cdProduto!;
                                pesoLiqProdGr =
                                    produtoOp.produtos![0].pesoLiqGr!;
                              });
                            } else {
                              setState(() {
                                cdMaquina = value;

                                isTableLoading = false;
                              });
                            }

                            for (var produto in produtoOp.produtos!) {
                              setState(() {
                                listaProdutosOp.add(produto);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                leading: Transform.scale(
                  scale: 1.8,
                  child: Radio<String>(
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.blue),
                    value: 'maquina',
                    groupValue: _tipoInsercao,
                    onChanged: (String? value) {
                      setState(() {
                        _tipoInsercao = value;
                      });

                      clearValues();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Produto:',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                    Visibility(
                      visible: _tipoInsercao == 'produto',
                      child: DropdownSearch<dynamic>(
                        mode: Mode.MENU,
                        maxHeight: 300,
                        items: produtos.map((e) => e['dsProduto']).toList(),
                        showSearchBox: true,
                        dropdownSearchDecoration: const InputDecoration(
                          labelText: "Escolha um produto",
                          labelStyle: TextStyle(color: Colors.black),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isTableLoading = true;
                          });

                          var idProduto = value.toString().substring(0, 1);
                          var produtoSelecionado = produtos.where((element) =>
                              element['id'].toString() == idProduto);
                          var cdProd =
                              produtoSelecionado.elementAt(0)['cdProduto'];

                          _daoProdutos.getProdutos(cdProd).then((produto) {
                            listaProd.clear();

                            setState(() {
                              isTableLoading = false;

                              cdProduto = produto.produtos![0].cdProduto!;
                              pesoLiqProdGr = produto.produtos![0].pesoLiqGr!;
                            });

                            for (var produto in produto.produtos!) {
                              setState(() {
                                listaProd.add(produto);
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
                leading: Transform.scale(
                  scale: 1.8,
                  child: Radio<String>(
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.blue),
                    value: 'produto',
                    groupValue: _tipoInsercao,
                    onChanged: (String? value) {
                      setState(() {
                        _tipoInsercao = value;
                      });

                      clearValues();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),

        // * Tabela
        Visibility(
          visible: _tipoInsercao == 'maquina',
          child: isTableLoading
              ? const CircularProgressIndicator()
              : tabelaMaquina(),
        ),
        Visibility(
          visible: _tipoInsercao == 'produto',
          child: isTableLoading
              ? const CircularProgressIndicator()
              : tabelaProduto(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Divider(thickness: 3),
        ),

        // * Tipo de Refugo
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Tipo do Refugo',
                    style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Visibility(
                    visible: _tipoInsercao == "maquina",
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Canal',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 1,
                                groupValue: _tipoRefugoMaquina,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoMaquina = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Injetora',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 2,
                                groupValue: _tipoRefugoMaquina,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoMaquina = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _tipoInsercao == "maquina",
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Borra',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 3,
                                groupValue: _tipoRefugoMaquina,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoMaquina = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Try-out',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 4,
                                groupValue: _tipoRefugoMaquina,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoMaquina = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _tipoInsercao == "produto",
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Varredura',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 5,
                                groupValue: _tipoRefugoProduto,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoProduto = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Devolução',
                                style: TextStyle(color: Colors.white)),
                            leading: Transform.scale(
                              scale: 1.7,
                              child: Radio<int>(
                                fillColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.blue),
                                value: 6,
                                groupValue: _tipoRefugoProduto,
                                onChanged: (int? value) {
                                  setState(() {
                                    _tipoRefugoProduto = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _tipoInsercao == "produto",
                    child: ListTile(
                      title: const Text('Obsoleto',
                          style: TextStyle(color: Colors.white)),
                      leading: Transform.scale(
                        scale: 1.7,
                        child: Radio<int>(
                          fillColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue),
                          value: 7,
                          groupValue: _tipoRefugoProduto,
                          onChanged: (int? value) {
                            setState(() {
                              _tipoRefugoProduto = value;
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: pesoBrutoController,
                                    keyboardType: TextInputType.number,
                                    // desabilitado se o usuario ainda nao setou produto
                                    enabled: cdProduto == "" ? false : true,
                                    onChanged: (String value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          valorZeroPesoBruto = false;
                                        });

                                        EasyDebounce.debounce('calculo',
                                            const Duration(milliseconds: 1000),
                                            () {
                                          if (pesoBrutoController.text == "0" ||
                                              pesoBrutoController.text ==
                                                  "0.0") {
                                            setState(() {
                                              valorZeroPesoBruto = true;
                                            });
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          valorZeroPesoBruto = false;
                                        });
                                      }
                                    },
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                    ),
                                    decoration: InputDecoration(
                                      // filled se o usuario ainda nao setou o produto
                                      filled: cdProduto == "" ? true : false,
                                      fillColor: cdProduto == ""
                                          ? const Color.fromARGB(
                                              255, 223, 221, 221)
                                          : null,
                                      labelText: 'Peso Bruto (Kg)',
                                      labelStyle: TextStyle(
                                        color: cdProduto == ""
                                            ? Colors.black
                                            : Colors.white,
                                        fontFamily: 'Montserrat',
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Campo obrigatório.';
                                      }
                                      return null;
                                    },
                                  ),
                                  Visibility(
                                    visible: valorZeroPesoBruto,
                                    child: const Text(
                                      'Valor deve ser maior que 0.0',
                                      style: TextStyle(
                                          fontSize: 11.0, color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: taraController,
                                  keyboardType: TextInputType.number,
                                  // desabilitado se usuario ainda não informou peso bruto
                                  enabled: pesoBrutoController.text.isEmpty ||
                                          valorZeroPesoBruto == true
                                      ? false
                                      : true,
                                  onChanged: (String value) {
                                    if (value.isNotEmpty) {
                                      EasyDebounce.debounce('calculo',
                                          const Duration(milliseconds: 2000),
                                          () {
                                        double peso = double.parse(
                                          pesoBrutoController.text
                                              .replaceAll(',', '.'),
                                        );
                                        double tara = double.parse(
                                          taraController.text
                                              .replaceAll(',', '.'),
                                        );

                                        pesoBrutoController.text =
                                            peso.toStringAsFixed(4);
                                        taraController.text =
                                            tara.toStringAsFixed(4);

                                        if (tara > peso) {
                                          setState(() {
                                            maiorQuePesoBruto = true;
                                          });
                                        } else if (tara == 0) {
                                          setState(() {
                                            valorZero = true;
                                          });
                                        } else {
                                          double pesoLiq = peso - tara;
                                          double qtdPecas = (pesoLiq * 1000) /
                                              double.parse(pesoLiqProdGr);

                                          setState(() {
                                            maiorQuePesoBruto = false;
                                            valorZero = false;

                                            FocusManager.instance.primaryFocus!
                                                .unfocus();

                                            pesoBrutoController.text =
                                                peso.toStringAsFixed(4);
                                            taraController.text =
                                                tara.toStringAsFixed(4);
                                            pesoLiqController.text =
                                                pesoLiq.toStringAsFixed(4);
                                            qtdPecasController.text =
                                                qtdPecas.toStringAsFixed(4);
                                          });
                                        }
                                      });
                                    } else if (value.isEmpty) {
                                      setState(() {
                                        maiorQuePesoBruto = false;
                                        valorZero = false;

                                        pesoLiqController.text = "";
                                        qtdPecasController.text = "";
                                      });
                                    }
                                  },
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                  ),
                                  decoration: InputDecoration(
                                    // filled se usuario ainda não informou peso bruto
                                    filled: pesoBrutoController.text.isEmpty ||
                                            valorZeroPesoBruto == true
                                        ? true
                                        : false,
                                    fillColor:
                                        pesoBrutoController.text.isEmpty ||
                                                valorZeroPesoBruto == true
                                            ? const Color.fromARGB(
                                                255, 223, 221, 221)
                                            : null,
                                    labelText: 'Peso Tara (Kg)',
                                    labelStyle: TextStyle(
                                      color: pesoBrutoController.text.isEmpty ||
                                              valorZeroPesoBruto == true
                                          ? Colors.black
                                          : Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: maiorQuePesoBruto,
                                  child: const Text(
                                    'Peso tara deve ser menor que peso bruto',
                                    style: TextStyle(
                                        fontSize: 11.0, color: Colors.red),
                                  ),
                                ),
                                Visibility(
                                  visible: valorZero,
                                  child: const Text(
                                    'Valor deve ser maior que 0.0',
                                    style: TextStyle(
                                        fontSize: 11.0, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextFormField(
                              controller: pesoLiqController,
                              enabled: false,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 223, 221, 221),
                                labelText: 'Peso Líquido (Kg)',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Montserrat',
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                // disabledBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(color: Colors.grey),
                                // ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obrigatório.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: qtdPecasController,
                            enabled: false,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                            ),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(255, 223, 221, 221),
                              labelText: 'Qtd. Peças',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              // disabledBorder: OutlineInputBorder(
                              //   borderSide: BorderSide(color: Colors.grey),
                              // ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Divider(thickness: 3, color: Colors.grey),
        ),
        const Text(
          'Chamadas de Caixa em Aberto',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        SizedBox(
          // color: Colors.red,
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.grey),
            child: RawScrollbar(
              controller: controller,
              thumbColor: Colors.grey,
              radius: const Radius.circular(20),
              trackVisibility: true,
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Data/Hora',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Cod.Máquina',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                    ),
                  ],
                  rows: listaAlertas
                      .map(
                        (prod) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                prod.dthrChamada!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                prod.cdMaquina!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  enviarRegistroRefugo() {
    setState(() {
      isResponseLoading = true;
    });

    if (_tipoInsercao == 'maquina') {
      jsonRegistroRefugo = jsonEncode(<String, dynamic>{
        "tipoRefugo": _tipoRefugoMaquina,
        "cdMaquina": cdMaquina,
        "nrOP": nrOP,
        "cdMolde": cdMolde,
        "cdEstrutura": cdEstrutura,
        "cdProduto": cdProduto,
        "pesoLiqProdGr": pesoLiqProdGr,
        "taraKg": taraController.text,
        "pesoBrutoKg": pesoBrutoController.text,
        "pesoLiquidoKg": pesoLiqController.text,
        "qtdPcs": qtdPecasController.text
      });

      _daoRegistroRefugo.registroRefugo(jsonRegistroRefugo).then((value) async {
        print('value');
        print(value.statusResposta);

        if (value.statusResposta == respostaSucesso) {
          clearValues();

          setState(() {
            isResponseLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF198754),
              padding: EdgeInsets.symmetric(vertical: 25.0),
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Sucesso ao registrar o refugo!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          setState(() {
            isResponseLoading = false;
          });

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertaScreen(
                message: 'Houve um erro ao enviar o registro.',
              );
            },
          );
        }
      });

      // tipo produto
    } else {
      jsonRegistroRefugo = jsonEncode(<String, dynamic>{
        "tipoRefugo": _tipoRefugoProduto,
        "cdProduto": cdProduto,
        "pesoLiqProdGr": pesoLiqProdGr,
        "taraKg": taraController.text,
        "pesoBrutoKg": pesoBrutoController.text,
        "pesoLiquidoKg": pesoLiqController.text,
        "qtdPcs": qtdPecasController.text
      });

      _daoRegistroRefugo.registroRefugo(jsonRegistroRefugo).then((value) async {
        print('value');
        print(value.statusResposta);

        if (value.statusResposta == respostaSucesso) {
          clearValues();

          setState(() {
            isResponseLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF198754),
              padding: EdgeInsets.symmetric(vertical: 25.0),
              behavior: SnackBarBehavior.floating,
              content: Text(
                'Sucesso ao registrar o refugo!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else {
          setState(() {
            isResponseLoading = false;
          });

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AlertaScreen(
                message: 'Houve um erro ao enviar o registro.',
              );
            },
          );
        }
      });
    }
  }

  Theme tabelaMaquina() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey),
      child: DataTable(
        columnSpacing: 50,
        dataRowHeight:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? 75
                : 50,
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'OP',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Cd. Produto',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Desc.',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Peso Liq.\n(gramas)',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ),
        ],
        rows: listaProdutosOp
            .map(
              (prod) => DataRow(
                color: prod.cdProduto == selectedProduto
                    ? MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 166, 215, 238))
                    : MaterialStateProperty.all<Color>(Colors.black),
                selected: prod.cdProduto == selectedProduto,
                onLongPress: () {
                  setState(() {
                    selectedProduto = prod.cdProduto!;

                    nrOP = prod.nrOP!;
                    cdMolde = prod.cdMolde!;
                    cdEstrutura = prod.cdEstrutura!;
                    cdProduto = prod.cdProduto!;
                    pesoLiqProdGr = prod.pesoLiqGr!;
                  });
                },
                onSelectChanged: (val) {
                  setState(() {
                    selectedProduto = prod.cdProduto!;

                    nrOP = prod.nrOP!;
                    cdMolde = prod.cdMolde!;
                    cdEstrutura = prod.cdEstrutura!;
                    cdProduto = prod.cdProduto!;
                    pesoLiqProdGr = prod.pesoLiqGr!;
                  });
                },
                cells: [
                  DataCell(
                    Text(
                      prod.nropExibicao!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      prod.cdProduto!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      prod.dsProduto!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      prod.pesoLiqGr!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Theme tabelaProduto() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.grey),
      child: DataTable(
        columnSpacing: 50,
        dataRowHeight:
            MediaQuery.of(context).orientation == Orientation.portrait
                ? 75
                : 50,
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Cd. Produto',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Desc.',
              style:
                  TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Peso Liq.\n(gramas)',
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ),
          ),
        ],
        rows: listaProd
            .map(
              (prod) => DataRow(
                cells: [
                  DataCell(
                    Text(
                      prod.cdProduto!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      prod.dsProduto!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  DataCell(
                    Text(
                      prod.pesoLiqGr!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class MensagemErro extends StatelessWidget {
  const MensagemErro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            '${mensagemErro.toString()}. Link servidor: $serverURL',
            style: const TextStyle(color: Colors.white, fontSize: 40.0),
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Vá para menu para alterar o servidor',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

class Configuracao extends StatelessWidget {
  const Configuracao({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController serverController = TextEditingController();
    final TextEditingController portController = TextEditingController();

    prefs.getString('server') != null
        ? serverController.text = prefs.getString('server')!
        : serverController.text = "";

    prefs.getString('port') != null
        ? portController.text = prefs.getString('port')!
        : portController.text = "";

    return SingleChildScrollView(
      child: SizedBox(
        height: 250.0,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Servidor',
                ),
                controller: serverController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o servidor';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TextFormField(
                  onTap: () {},
                  decoration: const InputDecoration(
                    labelText: 'Porta',
                  ),
                  controller: portController,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a porta';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      prefs.setString('server', serverController.text);
                      prefs.setString('port', portController.text);
                      getServer();
                      Navigator.pop(context);
                      RestartWidget.restartApp(context);
                    }
                  },
                  child: const Text(
                    'Finalizar',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 25.0),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
