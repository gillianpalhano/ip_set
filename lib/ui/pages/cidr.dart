import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ip_set/utils/convert_network.dart';
import 'package:ip_set/utils/validate.dart';

class CidrMaskConverterPage extends StatefulWidget {
  const CidrMaskConverterPage({super.key});

  @override
  State<CidrMaskConverterPage> createState() => _CidrMaskConverterPageState();
}

class _CidrMaskConverterPageState extends State<CidrMaskConverterPage> {
  final _cidrCtrl = TextEditingController();
  final _maskCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _maskDottedKey = GlobalKey<FormFieldState>();
  final _maskCidrKey = GlobalKey<FormFieldState>();

  Timer? _debounce;
  final Duration _delay = const Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _cidrCtrl.addListener(() => _onChanged('cidr'));
    _maskCtrl.addListener(() => _onChanged('mask'));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cidrCtrl.dispose();
    _maskCtrl.dispose();
    super.dispose();
  }

  void _onChanged(String origin) {
    _debounce?.cancel();
    _debounce = Timer(_delay, () {
      if (origin == 'cidr' &&
          _cidrCtrl.text.isNotEmpty &&
          _maskCidrKey.currentState!.validate()) {
        final mask = cidrToDotted(_cidrCtrl.text);
        _maskCtrl.text = mask;
      } else if (origin == 'mask' &&
          _maskCtrl.text.isNotEmpty &&
          _maskDottedKey.currentState!.validate()) {
        final mask = dottedToCidr(_maskCtrl.text.trim()) as String;
        _cidrCtrl.text = mask;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const hintStyle = TextStyle(color: Color.fromARGB(120, 255, 255, 255));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Conversor CIDR ↔ Máscara',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Campo CIDR
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      key: _maskCidrKey,
                      controller: _cidrCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CIDR',
                        hintText: '/24',
                        hintStyle: hintStyle,
                        prefixIcon: Icon(Icons.lan_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[/0-9]')),
                      ],
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (v) => validateMaskCidr(v),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(Icons.sync_alt),
                  const SizedBox(width: 20),
                  // Campo Máscara
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      key: _maskDottedKey,
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
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Exemplos rápidos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            '/8  → 255.0.0.0\n/16 → 255.255.0.0\n/24 → 255.255.255.0\n/32 → 255.255.255.255',
          ),
        ],
      ),
    );
  }
}
