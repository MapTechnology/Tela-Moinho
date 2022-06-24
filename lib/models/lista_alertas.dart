class ListaAlertas {
  List<Alertas>? alertas;

  ListaAlertas({this.alertas});

  ListaAlertas.fromJson(Map<String, dynamic> json) {
    if (json['alertas'] != null) {
      alertas = <Alertas>[];
      json['alertas'].forEach((v) {
        alertas!.add(Alertas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (alertas != null) {
      data['alertas'] = alertas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Alertas {
  String? cdMaquina;
  String? dthrChamada;

  Alertas({this.cdMaquina, this.dthrChamada});

  Alertas.fromJson(Map<String, dynamic> json) {
    cdMaquina = json['cdMaquina'];
    dthrChamada = json['dthrChamada'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cdMaquina'] = cdMaquina;
    data['dthrChamada'] = dthrChamada;
    return data;
  }
}
