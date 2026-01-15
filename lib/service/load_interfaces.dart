import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ip_set/state/network_state.dart';
import 'package:provider/provider.dart';

Future<List<NetworkInterface>> loadInterfaces(BuildContext context) async {
  try {
    var networkState = context.read<NetworkState>();

    final list = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
    );

    networkState.setInterfaces(list);

    return list;
  } catch (e) {
    return [];
  }
}
