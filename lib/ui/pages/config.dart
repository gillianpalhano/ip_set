import 'package:flutter/material.dart';
import 'package:ip_set/state/config_state.dart';
import 'package:provider/provider.dart';

class ConfigSettingsPage extends StatefulWidget {
  const ConfigSettingsPage({super.key});

  @override
  State<ConfigSettingsPage> createState() => _ConfigSettingsPageState();
}

class _ConfigSettingsPageState extends State<ConfigSettingsPage> {
  @override
  Widget build(BuildContext context) {
    var configState = context.watch<ConfigState>();

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Configurações',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Tema:', style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
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
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Calcular Gateway Automaticamente:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.close,
                  size: 15,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                Transform.scale(
                  scale: 0.6,
                  child: Switch(
                    value: configState.isCalcGatewayEnabled,
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
                      configState.toggleCalcGateway();
                    },
                    padding: const EdgeInsets.all(0),
                  ),
                ),
                Icon(
                  Icons.check,
                  size: 15,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
