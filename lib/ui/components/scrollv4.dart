import 'package:flutter/material.dart';
import 'package:ip_set/ui/components/scroll_hor.dart';
import 'package:ip_set/ui/components/scroll_vert.dart';

class ScrollComponent extends StatefulWidget {
  final Widget child;

  const ScrollComponent({required this.child, super.key});

  @override
  State<ScrollComponent> createState() => _ScrollComponentState();
}

class _ScrollComponentState extends State<ScrollComponent> {
  @override
  Widget build(BuildContext context) {
    return ScrollVerticalComponent(
      child: ScrollHorizontalComponent(child: widget.child),
    );
  }
}
