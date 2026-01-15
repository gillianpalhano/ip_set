import 'package:go_router/go_router.dart';
import 'package:ip_set/ui/pages/cidr.dart';

import '../layout/layout.dart';
import '../pages/main.dart';
import '../pages/calc.dart';
import '../pages/config.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return LayoutMain(child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => EditableNetTablePage()),
        GoRoute(
          path: '/cidr',
          builder: (context, state) => CidrMaskConverterPage(),
        ),
        GoRoute(
          path: '/calc',
          builder: (context, state) => const ConfigNetworkPage(),
        ),
        GoRoute(
          path: '/config',
          builder: (context, state) => const ConfigSettingsPage(),
        ),
      ],
    ),
  ],
);
