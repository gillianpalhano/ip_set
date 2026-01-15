import 'package:ip_set/utils/convert_network.dart';
import 'package:ip_set/utils/is_ipv4.dart';
import 'package:ip_set/utils/is_mask.dart';
import 'package:ip_set/utils/parse_prefix.dart';

class NetInfo {
  // final String ipBase;           // o IP usado no cálculo (ip ou gateway)
  final String maskDotted;
  final String maskCidr;
  final int prefix; // ex.: 24
  final String network; // endereço de rede
  final String broadcast; // broadcast (se aplicável)
  final String? firstUsable; // null para /31 e /32
  final String? lastUsable; // null para /31 e /32
  final String? suggestedIp; // sugestão de IP (null se não aplicável)
  final int totalHosts; // qtd de hosts utilizáveis (0 p/ /31 e /32)

  NetInfo({
    // required this.ipBase,
    required this.maskDotted,
    required this.maskCidr,
    required this.prefix,
    required this.network,
    required this.broadcast,
    required this.firstUsable,
    required this.lastUsable,
    required this.suggestedIp,
    required this.totalHosts,
  });
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });
}

// Escolhe uma sugestão de IP dentro da faixa utilizável,
// evitando o gateway caso exista.
String? _pickSuggestedIp({
  required int network, // endereço de rede em int
  required int broadcast, // broadcast em int
  int? gwInt, // opcional: evitar sugerir o gateway
}) {
  // Faixa utilizável clássica
  final usableLow = network + 1;
  final usableHigh = broadcast - 1;

  // /31 e /32 (ou redes sem faixa utilizável) caem aqui
  if (usableLow > usableHigh) return null;

  // Preferências: .2, depois .1, depois último utilizável
  final candidates = <int>[usableLow + 1, usableLow, usableHigh];

  for (final c in candidates) {
    if (c < usableLow || c > usableHigh) continue;
    if (gwInt != null && c == gwInt) continue; // não sugerir o gateway
    return intToIp(c);
  }
  return null;
}

NetInfo networkInfo({String? ip, String? gateway, required String mask}) {
  if ((ip == null || ip.isEmpty) && (gateway == null || gateway.isEmpty)) {
    throw ArgumentError('Informe ip OU gateway.');
  }
  if (ip != null && ip.isNotEmpty && !isIPv4(ip)) {
    throw FormatException('IP inválido: $ip');
  }
  if (gateway != null && gateway.isNotEmpty && !isIPv4(gateway)) {
    throw FormatException('Gateway inválido: $gateway');
  }
  if (!isMask(mask)) throw FormatException('Máscara inválida: $mask');

  final maskInt = maskToInt(mask);
  final prefix = isMaskDotted(mask)
      ? dottedToCidr(mask, returnInt: true) as int
      : parsePrefix(mask)!;

  final baseStr = (ip != null && ip.isNotEmpty) ? ip : gateway!;
  final baseInt = ipToInt(baseStr);

  final network = baseInt & maskInt;
  final broadcast = network | (~maskInt & 0xFFFFFFFF);

  String? firstUsable;
  String? lastUsable;
  String? suggestedIp;
  int totalHosts = 0;

  if (prefix <= 30) {
    // Padrão clássico: exclui rede e broadcast
    firstUsable = intToIp(network + 1);

    lastUsable = intToIp(broadcast - 1);
    totalHosts = (1 << (32 - prefix)) - 2;

    final gwInt = (gateway != null && gateway.isNotEmpty)
        ? ipToInt(gateway)
        : null;
    // sugestão: se IP atual for null, use o segundo utilizável (se existir)
    suggestedIp = _pickSuggestedIp(
      network: network,
      broadcast: broadcast,
      gwInt: gwInt,
    );
  } else {
    // /31 e /32 sem faixa utilizável tradicional
    firstUsable = null;
    lastUsable = null;
    totalHosts = 0;
    suggestedIp = _pickSuggestedIp(
      network: network,
      broadcast: broadcast,
      gwInt: (gateway != null && gateway.isNotEmpty) ? ipToInt(gateway) : null,
    );
  }

  return NetInfo(
    // ipBase: baseStr,
    maskDotted: mask,
    maskCidr: '/$prefix',
    prefix: prefix,
    network: intToIp(network),
    broadcast: intToIp(broadcast),
    firstUsable: firstUsable,
    lastUsable: lastUsable,
    totalHosts: totalHosts,
    suggestedIp: suggestedIp,
  );
}

ValidationResult validateIPv4Config({
  required String ip,
  required String mask,
  required String gateway,
}) {
  final errors = <String>[];
  final warnings = <String>[];

  if (!isIPv4(ip)) errors.add('IP inválido: $ip');
  if (!isIPv4(gateway)) errors.add('Gateway inválido: $gateway');
  if (!isMask(mask)) errors.add('Mascara inválida: $mask');
  if (ip == gateway) errors.add('IP e gateway iguais');

  if (errors.isNotEmpty) {
    return ValidationResult(isValid: false, errors: errors);
  }

  final maskInt = maskToInt(mask);

  final prefix = dottedToCidr(mask, returnInt: true) as int;
  final ipInt = ipToInt(ip);
  final gwInt = ipToInt(gateway);

  final network = ipInt & maskInt;
  final broadcast = network | (~maskInt & 0xFFFFFFFF);

  // Mesma sub-rede?
  final gwNetwork = gwInt & maskInt;
  if (gwNetwork != network) {
    errors.add(
      'Gateway não pertence à mesma rede do IP: '
      '${intToIp(network)}/$prefix',
    );
  }

  // IP não pode ser endereço de rede/broadcast (para /0.. /30)
  if (prefix <= 30) {
    if (ipInt == network) errors.add('IP não pode ser o endereço de rede.');
    if (ipInt == broadcast) errors.add('IP não pode ser o broadcast.');
    if (gwInt == network)
      errors.add('Gateway não pode ser o endereço de rede.');
    if (gwInt == broadcast) errors.add('Gateway não pode ser o broadcast.');
  } else if (prefix == 31) {
    // /31 (ponto-a-ponto) pode ser aceitável em alguns cenários, mas avisa
    warnings.add(
      'Prefixo /31: não há hosts utilizáveis no padrão tradicional.',
    );
  } else if (prefix == 32) {
    warnings.add('Prefixo /32: IP único, sem gateway tradicional.');
    // Se /32, gateway igual ao IP normalmente não faz sentido
    if (gwInt != ipInt) {
      warnings.add(
        'Em /32, o gateway costuma ser resolvido por roteamento estático/host-route.',
      );
    }
  }

  return ValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
  );
}
