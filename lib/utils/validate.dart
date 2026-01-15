import 'package:ip_set/utils/is_mask.dart';

import './is_ipv4.dart';

String? validateIsRequired(String? v, {String field = 'Campo'}) {
  if (v == null || v.trim().isEmpty) return '$field é obrigatório!';
  return null;
}

String? validateIsIPv4(String? v, {bool allowEmpty = false}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;
  if (!isIPv4(s)) return 'IP inválido!';
  return null;
}

String? validateIsNumberRange(
  String? v, {
  int? min,
  int? max,
  bool allowEmpty = false,
  String field = 'Valor',
}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;
  final n = int.tryParse(s);
  // final n = s.length;
  if (n == null) return '$field inválido.';
  if (min != null && n < min) return '$field mínimo é $min!';
  if (max != null && n > max) return '$field máximo é $max!';
  return null;
}

String? validateIsLength(
  String? v, {
  int? min,
  int? max,
  bool allowEmpty = false,
  String field = 'Campo',
}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;
  if (!allowEmpty && s.isEmpty) return '$field é obrigatório.';

  if (min != null && s.length < min) {
    return '$field deve ter pelo menos $min caracteres.';
  }
  if (max != null && s.length > max) {
    return '$field deve ter no máximo $max caracteres.';
  }
  return null;
}

/// Valida máscara em formato CIDR (ex.: /24)
String? validateMaskCidr(String? v, {bool allowEmpty = false}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;

  // if (v == null || v.trim().isEmpty) return 'Informe um prefixo (ex.: /24)';
  if (!isMaskCidr(s)) return 'CIDR inválido. Use /0 … /32';
  return null;
}

String? validateMaskDotted(String? v, {bool allowEmpty = false}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;

  // if (v == null || v.trim().isEmpty) return 'Informe uma máscara (ex.: 255.255.255.0)';
  if (!isMaskDotted(s)) return 'Máscara inválida!';
  return null;
}

/// Valida se é máscara, independente do formato
String? validateMask(String? v, {bool allowEmpty = false}) {
  final s = (v ?? '').trim();
  if (allowEmpty && s.isEmpty) return null;

  if (!isMaskCidr(s) && !isMaskDotted(s))
    return 'Máscara inválida! Use formato CIDR (/24) ou dotted decimal';
  return null;
}
