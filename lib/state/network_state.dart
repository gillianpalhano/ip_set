import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ip_set/models/net_row.dart';

class NetworkState extends ChangeNotifier {
  String get defaultFilePath {
    // Mesmo diretório do executável (.exe). Em debug, é o runner.
    final exe = File(Platform.resolvedExecutable);
    final dir = exe.parent.path;
    return '$dir${Platform.pathSeparator}net_table.json';
  }

  // Indica se houve edição nos dados
  bool isEdited = false;
  void setEdited(bool value) {
    isEdited = value;
    notifyListeners();
  }

  bool get getIsEdited => isEdited;

  // Tabela de redes original
  List<NetRow> networkTableOriginal = [];
  void setNetworkTableOriginal(List<NetRow> list) {
    networkTableOriginal = list;
    notifyListeners();
  }

  List<NetRow> get getNetworkTableOriginal => networkTableOriginal;

  // Interface selecionada
  String interfaceNameSelected = '';
  void setInterface() {
    interfaceNameSelected = interfaceNameSelected;
    notifyListeners();
  }

  String get getInterface => interfaceNameSelected;

  // Lista de interfaces
  List<NetworkInterface> interfaces = [];
  setInterfaces(List<NetworkInterface> list) {
    interfaces = list;
    notifyListeners();
  }

  List<NetworkInterface> get getInterfaces => interfaces;
}
