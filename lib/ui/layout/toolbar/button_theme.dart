import 'package:flutter/material.dart';
import 'package:ip_set/state/config_state.dart';
import 'package:provider/provider.dart';

class ButtonThemeComponent extends StatelessWidget {
  const ButtonThemeComponent({super.key});

  @override
  Widget build(BuildContext context) {
    var configState = context.watch<ConfigState>();
    return Row(
      children: [
        // Icon(themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode, size: 15),
        Icon(
          Icons.light_mode,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Transform.scale(
          scale: 0.6,
          child: Switch(
            value: configState.isDarkMode,
            trackOutlineColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.secondary,
            ), // cor do fundo quando pressionado
            activeTrackColor: Theme.of(
              context,
            ).colorScheme.secondary, // fundo quando ativo
            inactiveTrackColor: Theme.of(
              context,
            ).colorScheme.secondary, // fundo quando inativo
            onChanged: (bool value) {
              configState.toggleTheme();
            },
            padding: const EdgeInsets.all(0),
          ),
        ),
        Icon(
          Icons.dark_mode,
          size: 15,
          color: Theme.of(context).colorScheme.secondary,
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
