import 'dart:io';

import 'package:ip_set/utils/is_admin.dart';

Future<String> runPS(String script, {bool admin = false}) async {
  if (!Platform.isWindows) {
    throw 'Somente Windows é suportado';
  }

  if (admin && isAdmin() == false) {
    throw 'Necessário privilégios de administrador';
  }

  final result = await Process.run('powershell', [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    script,
  ], runInShell: false);
  if (result.exitCode != 0) {
    throw ProcessException(
      'powershell',
      [],
      result.stderr.isNotEmpty ? result.stderr : result.stdout,
      result.exitCode,
    );
  }

  // print(result.stdout);
  return (result.stdout as String).trim();
}
