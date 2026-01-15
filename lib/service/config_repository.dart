import 'dart:convert';
import 'dart:io';
import 'package:ip_set/models/app_config.dart';
import 'package:path_provider/path_provider.dart';

class ConfigRepository {
  static const _fileName = 'config.json';

  Future<File> _file() async {
    final dir = await getApplicationSupportDirectory();
    // print('Config directory: $dir');
    await dir.create(recursive: true);
    return File('${dir.path}\\$_fileName');
  }

  Future<AppConfig> load() async {
    final file = await _file();

    if (!await file.exists()) {
      final defaultConfig = AppConfig();
      await save(defaultConfig);
      return defaultConfig;
    }

    final jsonMap = jsonDecode(await file.readAsString());
    return AppConfig.fromJson(jsonMap);
  }

  Future<void> save(AppConfig config) async {
    final file = await _file();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(config.toJson());

    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonStr);
    await tmp.rename(file.path);
  }
}
