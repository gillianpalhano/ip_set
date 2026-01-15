import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    // var swapState = context.watch<SwapState>();

    return Container(
      // color: Colors.deepOrange,
      height: 25,
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.deepOrange, width: 0.8),
        color: Theme.of(context).colorScheme.primary,
        // borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 10),
          const Text(
            'IPSet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 30),
          // if (swapState.getSystem != null)
          // Text(swapState.getSystem!.name, style: TextStyle(fontSize: 16, color: Colors.white)),
          const Expanded(child: SizedBox()),
          // Text(
          //   '© ${DateTime.now().year} DPET - Capacitor Swap',
          //   style: const TextStyle(fontSize: 14, color: Colors.white)
          // ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
