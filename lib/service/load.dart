import 'dart:convert';
import 'dart:io';

import 'package:ip_set/models/net_row.dart';

Future<List<NetRow>> loadFromDisk(String filePath) async {
  try {
    final f = File(filePath);
    if (await f.exists()) {
      final txt = await f.readAsString();
      final data = jsonDecode(txt);
      final list = (data is List) ? data : <dynamic>[];
      final loaded = <NetRow>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          loaded.add(NetRow.fromJson(item));
        } else if (item is Map) {
          loaded.add(NetRow.fromJson(item.cast<String, dynamic>()));
        }
      }
      return loaded;
      // setState(() {
      //   for (final r in _rows) r.dispose();
      //   _rows
      //     ..clear()
      //     ..addAll(loaded);
      //   _loaded = true;
      // });
    } else {
      // Cria um exemplo inicial (opcional)
      // setState(() {
      // _rows
      // ..clear()
      // ..addAll([
      return [
        NetRow(
          id: '1',
          desc: 'Config rede A',
          ip: '10.0.0.10',
          mask: '255.255.255.0',
          gw: '10.0.0.1',
          dnsJoined: '8.8.8.8;8.8.4.4',
        ),
        NetRow(
          id: '2',
          desc: 'Config rede B',
          ip: '10.0.1.20',
          mask: '255.255.255.0',
          gw: '10.0.1.1',
          dnsJoined: '8.8.8.8;1.1.1.1',
        ),
      ];
      // ]);
      // _loaded = true;
      // });
    }
  } catch (e) {
    // setState(() => _loaded = true);
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Falha ao importar: $e')),
    //   );
    // }
    return [];
  }
}
