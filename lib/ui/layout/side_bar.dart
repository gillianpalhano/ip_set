import 'package:ip_set/state/config_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ip_set/ui/layout/side_bar_item.dart';
import 'package:provider/provider.dart';

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({super.key});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  int selectedIndex = 0;
  bool isExpanded = false;

  final List<_MenuItem> items = const [
    _MenuItem(
      index: 0,
      icon: Icons.play_arrow,
      label: 'Trocar IP',
      route: '/',
      position: 'top',
    ),
    _MenuItem(
      index: 1,
      icon: Icons.sync_alt,
      label: 'Conversor',
      route: '/cidr',
      position: 'top',
    ),
    _MenuItem(
      index: 2,
      icon: Icons.lan_outlined,
      label: 'Calculadora',
      route: '/calc',
      position: 'top',
    ),

    _MenuItem(
      index: 3,
      icon: Icons.settings,
      label: 'Configuração',
      route: '/config',
      position: 'bottom',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    var configState = context.watch<ConfigState>();
    final topItems = items.where((item) => item.position == 'top').toList();
    final bottomItems = items
        .where((item) => item.position == 'bottom')
        .toList();

    return Container(
      width: isExpanded ? 160 : 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.primary, // Cor da borda
            width: 0.0,
          ), // Espessura da borda
        ),
      ),
      child: Column(
        children: [
          ...List.generate(topItems.length, (index) {
            final item = topItems[index];
            final isSelected = selectedIndex == item.index;

            return SidebarItem(
              icon: item.icon,
              label: item.label,
              isSelected: isSelected,
              isExpanded: isExpanded,
              isDarkMode: configState.isDarkMode,
              onTap: () {
                setState(() {
                  if (selectedIndex == item.index) {
                    isExpanded = !isExpanded;
                  } else {
                    selectedIndex = item.index;
                    context.go(item.route);
                  }
                });
              },
            );
          }),

          const Spacer(),

          ...List.generate(bottomItems.length, (index) {
            final item = bottomItems[index];
            final isSelected = selectedIndex == item.index;

            return SidebarItem(
              icon: item.icon,
              label: item.label,
              isSelected: isSelected,
              isExpanded: isExpanded,
              isDarkMode: configState.isDarkMode,
              onTap: () {
                setState(() {
                  if (selectedIndex == item.index) {
                    isExpanded = !isExpanded;
                  } else {
                    selectedIndex = item.index;
                    context.go(item.route);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }
}

class _MenuItem {
  final int index;
  final IconData icon;
  final String label;
  final String route;
  final String position;

  const _MenuItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.route,
    required this.position,
  });
}
