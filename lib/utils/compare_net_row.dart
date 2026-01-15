import 'package:flutter/foundation.dart';
import 'package:ip_set/models/net_row.dart';

bool compareNetRow(List<NetRow> a, List<NetRow> b) {
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    final aj = a[i].toJson();
    final bj = b[i].toJson();
    if (!mapEquals(aj, bj)) return false;
  }
  return true;
}
