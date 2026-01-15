import 'package:ip_set/models/net_row.dart';

List<NetRow> deepCopyRows(List<NetRow> rows) {
  return rows.map((r) => NetRow.fromJson(r.toJson())).toList();
}
