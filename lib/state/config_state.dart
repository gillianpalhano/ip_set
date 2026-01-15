import 'package:flutter/material.dart';
import 'package:ip_set/models/app_config.dart';
import 'package:ip_set/service/config_repository.dart';

class ConfigState extends ChangeNotifier {
  final ConfigRepository _repo;

  // calcular gateway automaticamente
  bool _isCalcGatewayEnabled = true;
  bool get isCalcGatewayEnabled => _isCalcGatewayEnabled;

  // tema da aplicação
  bool _darkMode = true; // darkMode.system;
  bool get isDarkMode => _darkMode;

  ConfigState(this._repo);

  Future<void> load() async {
    final AppConfig config = await _repo.load();
    // if (config.versionFileConfig < versionFileConfig) {
    //   // Handle migrations here if needed in the future
    // }
    _isCalcGatewayEnabled = config.isCalcGatewayEnabled;
    _darkMode = config.darkMode;
    notifyListeners();
  }

  Future<void> toggleCalcGateway() async {
    _isCalcGatewayEnabled = !_isCalcGatewayEnabled;
    notifyListeners();

    await _repo.save(AppConfig(isCalcGatewayEnabled: _isCalcGatewayEnabled));
  }

  Future<void> toggleTheme() async {
    _darkMode = !_darkMode;
    notifyListeners();

    await _repo.save(AppConfig(darkMode: _darkMode));
  }
}
