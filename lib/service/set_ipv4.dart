import 'package:ip_set/service/run_ps.dart';

Future<String> setStaticIPv4({
  required String ip, // ex.: "10.10.20.50"
  required String mask, // ex.: 24
  required String interfaceName, // ex.: "Ethernet"
  String? gw, // ex.: "10.10.20.1"
  List<String>? dnsServers, // ex.: ["1.1.1.1","8.8.8.8"]
}) async {
  try {
    final gwPart = (gw == null || gw.isEmpty) ? 'none' : gw;
    var resp = '';
    // Remove IPs anteriores (evita conflito)
    resp = await runPS(
      'netsh interface ipv4 set address "$interfaceName" static $ip $mask $gwPart',
      admin: true,
    );

    if (resp.isNotEmpty) {
      return resp;
    }
    // Define DNS
    if (dnsServers != null && dnsServers.isNotEmpty) {
      resp = await runPS(
        'netsh interface ipv4 set dns name="$interfaceName" source=dhcp',
        admin: true,
      ); // limpa DNS anterior
      for (int i = 0; i < dnsServers.length; i++) {
        final dns = dnsServers[i];
        resp = await runPS(
          'netsh interface ipv4 add dns name="$interfaceName" address=$dns index=${i + 1}',
          admin: true,
        );
      }
    }

    return resp;
  } catch (e) {
    return 'Erro: $e';
  }
}
