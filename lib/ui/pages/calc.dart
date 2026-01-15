import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ip_set/utils/is_ipv4.dart';
import 'package:ip_set/utils/is_mask.dart';
import 'package:ip_set/utils/network.dart';
import 'package:ip_set/utils/validate.dart';

class ConfigNetworkPage extends StatefulWidget {
  const ConfigNetworkPage({super.key});

  @override
  State<ConfigNetworkPage> createState() => _ConfigNetworkPageState();
}

class _ConfigNetworkPageState extends State<ConfigNetworkPage> {
  final _ipCtrl = TextEditingController();
  final _maskCtrl = TextEditingController();
  final _gwCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _ipKey = GlobalKey<FormFieldState>();
  final _maskKey = GlobalKey<FormFieldState>();
  final _gwKey = GlobalKey<FormFieldState>();

  var _netInfoShow = false;
  var _netInfoIsValid = false;
  var _netInfoMsg = '';
  NetInfo? _netInfo = null;

  Timer? _debounce;
  final Duration _delay = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _ipCtrl.addListener(() => _onChanged('ip'));
    _maskCtrl.addListener(() => _onChanged('mask'));
    _gwCtrl.addListener(() => _onChanged('gw'));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ipCtrl.dispose();
    _maskCtrl.dispose();
    _gwCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String origin) {
    _debounce?.cancel();
    _debounce = Timer(_delay, () {
      if (origin == 'ip' && _ipCtrl.text.isNotEmpty)
        _ipKey.currentState!.validate();
      if (origin == 'mask' && _maskCtrl.text.isNotEmpty)
        _maskKey.currentState!.validate();
      if (origin == 'gw' && _gwCtrl.text.isNotEmpty)
        _gwKey.currentState!.validate();

      final ip = _ipCtrl.text.trim();
      final mask = _maskCtrl.text.trim();
      final gw = _gwCtrl.text.trim();

      if (mask.isNotEmpty && (ip.isNotEmpty || gw.isNotEmpty)) {
        if (isMask(mask) && (isIPv4(ip) || isIPv4(gw))) {
          try {
            final netInfo = networkInfo(
              ip: ip.isNotEmpty ? ip : null,
              gateway: gw.isNotEmpty ? gw : null,
              mask: mask,
            );
            setState(() {
              // atualiza o IP se estiver vazio
              if (ip.isEmpty && netInfo.firstUsable != null) {
                print('Sugestão: ${netInfo.suggestedIp}');
                _ipCtrl.text = netInfo.suggestedIp!;
              }
              // atualiza o gateway se estiver vazio
              if (gw.isEmpty && netInfo.firstUsable != null) {
                _gwCtrl.text = netInfo.firstUsable!;
              }
            });
          } catch (e) {
            // erro ao calcular, não faz nada
          }
        }
      }

      if (ip.isNotEmpty &&
          mask.isNotEmpty &&
          gw.isNotEmpty &&
          _formKey.currentState!.validate()) {
        try {
          final resp = validateIPv4Config(ip: ip, mask: mask, gateway: gw);
          _netInfoShow = true;
          _netInfoIsValid = resp.isValid;
          if (resp.isValid) {
            _netInfoMsg = 'Configuração válida!';
          } else {
            _netInfoMsg = resp.errors.join('\n');
            // _netInfo = null;
          }
          _netInfo = networkInfo(ip: ip, mask: mask);
        } catch (e) {
          // erro ao calcular, não faz nada
        }
      } else {
        setState(() {
          _netInfoShow = false;
          _netInfo = null;
        });
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const hintStyle = TextStyle(color: Color.fromARGB(100, 255, 255, 255));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Calculadora de rede',
            // style: Theme.of(context).textTheme.headlineMedium,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Campo CIDR
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    key: _ipKey,
                    controller: _ipCtrl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'IP',
                      hintText: '192.168.0.2',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.lan_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[.0-9]')),
                    ],
                    // autovalidateMode: AutovalidateMode.disabled,
                    validator: (v) => validateIsIPv4(v),
                  ),
                ),
                const SizedBox(width: 20),
                // Campo Máscara
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    key: _maskKey,
                    controller: _maskCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Máscara (dotted decimal)',
                      hintText: '255.255.255.0',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.lan_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: validateMaskDotted,
                  ),
                ),
                const SizedBox(width: 20),
                // Campo Gateway
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    key: _gwKey,
                    controller: _gwCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Gateway',
                      hintText: '192.168.0.1',
                      hintStyle: hintStyle,
                      prefixIcon: Icon(Icons.lan_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: validateIsIPv4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_netInfoShow)
            Column(
              children: [
                Text(
                  _netInfoMsg,
                  style: TextStyle(
                    color: _netInfoIsValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),

                if (_netInfo != null)
                  Column(
                    children: [
                      Text(
                        'Rede: ${_netInfo!.network}${_netInfo!.maskCidr}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Broadcast: ${_netInfo!.broadcast}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Faixa de IPs: ${_netInfo!.firstUsable} - ${_netInfo!.lastUsable} (${_netInfo!.totalHosts} IPs)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          // Text(
          //   'Exemplos rápidos',
          //   style: Theme.of(context).textTheme.titleMedium,
          // ),
          // const SizedBox(height: 8),
          // const Text('/8  → 255.0.0.0\n/16 → 255.255.0.0\n/24 → 255.255.255.0\n/32 → 255.255.255.255'),
        ],
      ),
    );
  }
}
