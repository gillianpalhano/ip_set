import 'package:ip_set/utils/is_ipv4.dart';
import 'package:ip_set/utils/is_mask.dart';
import 'package:ip_set/utils/parse_prefix.dart';

/// Converte mascará CIDR (/24) para máscara em dotted-decimal.
String cidrToDotted(String cidr) {
  if (!isMaskCidr(cidr)) {
    throw FormatException('Máscara CIDR inválida: $cidr');
  }
  final prefix = parsePrefix(cidr)!;
  // constrói inteiro de 32 bits com prefix bits = 1, depois vira 4 octetos
  final bits = prefix == 0 ? 0 : 0xFFFFFFFF << (32 - prefix);
  final a = (bits >> 24) & 0xFF;
  final b = (bits >> 16) & 0xFF;
  final c = (bits >> 8) & 0xFF;
  final d = bits & 0xFF;
  return '$a.$b.$c.$d';
}

/// Converte máscara válida para prefixo (padrão retorna String "/24").
Object dottedToCidr(String mask, {returnInt = false}) {
  if (!isMaskDotted(mask)) {
    throw FormatException('Máscara inválida: $mask');
  }
  final parts = mask.split('.').map((e) => int.parse(e)).toList();
  int bits = 0;
  for (final p in parts) {
    bits = (bits << 8) | (p & 0xFF);
  }
  // conta 1s à esquerda
  int count = 0;
  for (int i = 31; i >= 0; i--) {
    if ((bits & (1 << i)) != 0) {
      count++;
    } else {
      break;
    }
  }
  if (returnInt) {
    return count;
  }
  return '/$count';
}

int ipToInt(String ip) {
  if (!isIPv4(ip)) {
    throw ArgumentError('IPv4 inválido: $ip');
  }
  final p = ip.split('.').map(int.parse).toList();
  return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
}

String intToIp(int x) {
  final a = (x >>> 24) & 0xFF;
  final b = (x >>> 16) & 0xFF;
  final c = (x >>> 8) & 0xFF;
  final d = x & 0xFF;
  return '$a.$b.$c.$d';
}

int maskToInt(String mask) {
  if (!isMask(mask)) {
    throw ArgumentError('Máscara inválida: $mask');
  }
  if (isMaskCidr(mask)) {
    mask = cidrToDotted(mask);
  }
  return ipToInt(mask);
}
