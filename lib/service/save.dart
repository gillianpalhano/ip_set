import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ip_set/models/net_row.dart';
import 'package:ip_set/utils/is_ipv4.dart';

Future<(bool, String)> saveToDisk(
  BuildContext context,
  final List<NetRow> rows,
  String filePath,
) async {
  try {
    // Validação rápida (opcional): ip/máscara/gw se preenchidos precisam “parecer” IPv4
    String? error;

    for (final r in rows) {
      final ip = r.ipCtrl.text.trim();
      final mask = r.maskCtrl.text.trim();
      // final interfaceName = r.interfaceName.trim();
      final gw = r.gwCtrl.text.trim();
      if (ip.isNotEmpty && !isIPv4(ip)) {
        error = 'IP inválido: ${r.descCtrl.text} → $ip';
        break;
      }
      if (mask.isNotEmpty && !isIPv4(mask)) {
        error = 'Máscara inválida: ${r.descCtrl.text} → $mask';
        break;
      }
      // if (interfaceName.isEmpty) {
      //   error = 'Interface ausente: ${r.descCtrl.text}';
      //   break;
      // }
      if (gw.isNotEmpty && !isIPv4(gw)) {
        error = 'Gateway inválido: ${r.descCtrl.text} → $gw';
        break;
      }
      // DNS: valida superficialmente (aceita vazio)
      final dnss = r.dnsCtrl.text
          .split(RegExp(r'[;,]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      for (final d in dnss) {
        if (!isIPv4(d)) {
          error = 'DNS inválido: ${r.descCtrl.text} → $d';
          break;
        }
      }
      if (error != null) break;
    }

    if (error != null) {
      return (false, error);
    }

    // Reatribui IDs sequenciais (opcional)
    for (var i = 0; i < rows.length; i++) {
      rows[i] = NetRow(
        id: (i + 1).toString(),
        desc: rows[i].descCtrl.text,
        ip: rows[i].ipCtrl.text,
        mask: rows[i].maskCtrl.text,
        interfaceName: rows[i].interfaceName,
        gw: rows[i].gwCtrl.text,
        dnsJoined: rows[i].dnsCtrl.text,
      );
    }

    final list = rows.map((e) => e.toJson()).toList();
    // print('Salvando lista save.dart: $list');
    final f = File(filePath);

    // Cada objeto em uma linha
    final buffer = StringBuffer();
    buffer.writeln('[');
    for (var i = 0; i < list.length; i++) {
      final obj = list[i];
      final isLast = i == list.length - 1;
      buffer.writeln('  ${jsonEncode(obj)}${isLast ? '' : ','}');
      // buffer.writeln('  ${jsonEncode(obj)},')
    }
    buffer.writeln(']');
    await f.writeAsString(buffer.toString());

    return (true, 'Salvo em: ${f.path}');
  } catch (e) {
    return (false, 'Falha ao salvar: $e');
  }
}
