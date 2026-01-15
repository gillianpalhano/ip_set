import 'package:flutter/material.dart';
import 'package:ip_set/service/config_repository.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:ip_set/ui/routes/main.dart';
import 'package:ip_set/state/config_state.dart';
import 'package:ip_set/state/network_state.dart';
import 'package:ip_set/service/load_interfaces.dart';

void main() {
  runApp(App());
  doWhenWindowReady(() {
    final win = appWindow;
    // const initialSize = Size(1300, 600);
    win.minSize = Size(800, 600);
    win.size = Size(1300, 600);
    win.alignment = Alignment.center;
    win.title = "IPSet";
    win.show();
    // win.maximize();
  });
}

final lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.blueGrey[800]!,
  onPrimary: Colors.white,
  secondary: Colors.blueGrey[600]!,
  onSecondary: Colors.white,
  tertiary: Colors.blueGrey[400]!,
  onTertiary: Colors.black,
  surface: Colors.grey[100]!,
  onSurface: Colors.black,
  error: Colors.red,
  onError: Colors.white,
);

final darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.blueGrey[800]!,
  onPrimary: Colors.black,
  secondary: Colors.blueGrey[600]!,
  onSecondary: Colors.black,
  tertiary: Colors.blueGrey[400]!,
  onTertiary: Colors.black,
  surface: Colors.grey[900]!,
  onSurface: Colors.white,
  error: Colors.red[400]!,
  onError: Colors.black,
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ConfigState(ConfigRepository())..load(),
        ),
        ChangeNotifierProvider(create: (_) => NetworkState()),
      ],
      child: Consumer<ConfigState>(
        builder: (context, configState, _) {
          // Chama ao construir o app
          loadInterfaces(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            themeMode: configState.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData(useMaterial3: true, colorScheme: lightScheme),
            darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
