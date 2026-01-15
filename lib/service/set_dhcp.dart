import 'package:ip_set/service/run_ps.dart';

Future<String> setDHCPIPv4({
  required String interface, // ex.: "Ethernet"
}) async {
  try {
    await runPS('', admin: true);
    final resp1 = await runPS(
      'netsh interface ipv4 set address name="$interface" source=dhcp',
      admin: true,
    );

    final resp2 = await runPS(
      'netsh interface ipv4 set dns name="$interface" source=dhcp',
      admin: true,
    );

    return '$resp1\n$resp2';
  } catch (e) {
    return 'Erro: $e';
  }
}
