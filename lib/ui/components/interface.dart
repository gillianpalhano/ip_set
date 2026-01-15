import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ip_set/state/network_state.dart';

class InterfaceDropdown extends StatelessWidget {
  const InterfaceDropdown({
    super.key,
    required this.value, // r.interfaceName
    required this.onChanged, // (name) => r.interfaceName = name ?? ''
    this.enabled = true,
    this.label,
    this.forceErrorText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? label;
  final String? forceErrorText;

  @override
  Widget build(BuildContext context) {
    final names = context.select<NetworkState, List<String>>(
      (s) => s.interfaces.map((ni) => ni.name).toList(),
    );

    // Só podemos passar ao Dropdown um value que exista em items
    final selected = (value != null && names.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('${names.join("|")}||$value'), // força rebuild coerente
      isExpanded: true,
      value: selected,
      forceErrorText: forceErrorText,
      items: names
          .map(
            (n) => DropdownMenuItem<String>(
              value: n,
              child: Text(n, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: const OutlineInputBorder(),
        labelText: label ?? 'Interface',
        // Se veio do arquivo e ainda não temos esse nome na lista,
        // mostra como hint (fantasma) até as interfaces carregarem.
        hintText: (selected == null && (value ?? '').isNotEmpty) ? value : null,
      ),
    );
  }
}
