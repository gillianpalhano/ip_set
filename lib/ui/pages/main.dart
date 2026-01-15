import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ip_set/models/net_row.dart';
import 'package:ip_set/service/set_dhcp.dart';
import 'package:ip_set/service/set_ipv4.dart';
import 'package:ip_set/service/load.dart';
import 'package:ip_set/service/save.dart';
import 'package:ip_set/state/config_state.dart';
import 'package:ip_set/state/network_state.dart';
import 'package:ip_set/utils/deep_copy_net_row.dart';
import 'package:ip_set/utils/is_admin.dart';
import 'package:ip_set/utils/is_ipv4.dart';
import 'package:ip_set/utils/is_mask.dart';
import 'package:ip_set/utils/network.dart';
import 'package:ip_set/ui/components/text_form_field_validate.dart';
import 'package:ip_set/ui/components/confirm_dialog.dart';
import 'package:ip_set/ui/components/scroll_hor.dart';
import 'package:ip_set/ui/components/scroll_vert.dart';
import 'package:ip_set/ui/components/interface.dart';
import 'package:provider/provider.dart';

class EditableNetTablePage extends StatefulWidget {
  const EditableNetTablePage({super.key});

  @override
  State<EditableNetTablePage> createState() => _EditableNetTablePageState();
}

class _EditableNetTablePageState extends State<EditableNetTablePage> {
  final List<NetRow> _rows = [];
  bool _loaded = false;
  final _formKey = GlobalKey<FormState>();

  String interfaceDHCP = '';
  String interfaceDHCPValidator = '';

  // Timer? _editedDebounce;

  String get _defaultFilePath {
    // Mesmo diretório do executável (.exe). Em debug, é o runner.
    final exe = File(Platform.resolvedExecutable);
    final dir = exe.parent.path;
    return '$dir${Platform.pathSeparator}net_table.json';
  }

  @override
  void initState() {
    super.initState();
    _loadFromDisk();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      final nextId = (_rows.length + 1).toString();
      _rows.add(NetRow(id: nextId));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  _loadFromDisk() async {
    var networkState = context.read<NetworkState>();
    final loaded = await loadFromDisk(_defaultFilePath); // importar automático
    networkState.setNetworkTableOriginal(deepCopyRows(loaded));

    setState(() {
      for (final r in _rows) {
        r.dispose();
      }
      _rows
        ..clear()
        ..addAll(loaded);

      // for (final r in _rows) {
      //   // _attachListenersEdited(r);
      //   // _attachListenersCalcGateway(r);
      //   _attachListeners(r);
      // }
      _loaded = true;
    });
  }

  _saveToDisk() async {
    var networkState = context.read<NetworkState>();
    // validação antes de salvar
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Corrija os erros antes de salvar.')),
        );
      }
      return;
    }

    final (resp, msg) = await saveToDisk(context, _rows, _defaultFilePath);

    if (resp) setState(() {});
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    networkState.setNetworkTableOriginal(deepCopyRows(_rows));
    networkState.setEdited(false);
  }

  _executeDHCP() async {
    if (interfaceDHCP.isEmpty) {
      setState(() {
        interfaceDHCPValidator = 'Selecione uma interface!';
      });
      return;
    }
    final resp = await setDHCPIPv4(interface: interfaceDHCP);
    if (mounted && resp.isNotEmpty)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp)));
  }

  _executeRow(index) async {
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Corrija os erros antes de aplicar.')),
        );
      }
      return;
    }

    final r = _rows[index];
    final isValid = validateIPv4Config(
      ip: r.ipCtrl.text,
      mask: r.maskCtrl.text,
      gateway: r.gwCtrl.text,
    );
    if (!isValid.isValid) {
      final confirm = await confirmDialog(
        context,
        title: 'Configuração inválida',
        message: 'Tem certeza que deseja aplicar essa configuração?',
        confirmText: 'Aplicar mesmo assim!',
        icon: Icons.warning,
        barrierDismissible: true,
        isDanger: true,
      );
      if (!confirm) {
        return;
      }
    }

    final dns = _rows[index].dnsCtrl.text
        .split(RegExp(r'[;,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final resp = await setStaticIPv4(
      ip: _rows[index].ipCtrl.text,
      mask: _rows[index].maskCtrl.text,
      interfaceName: _rows[index].interfaceName,
      gw: _rows[index].gwCtrl.text,
      dnsServers: dns,
    );

    if (mounted && resp.isNotEmpty)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resp)));
    if (mounted && resp.isEmpty)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Configuração aplicada com sucesso.")),
      );
  }

  _validateConfig(int index) {
    final r = _rows[index];
    final result = validateIPv4Config(
      ip: r.ipCtrl.text,
      mask: r.maskCtrl.text,
      gateway: r.gwCtrl.text,
    );
    if (mounted) {
      if (result.isValid) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Configuração válida.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erros:\n${result.errors.join('\n')}')),
        );
      }
    }
  }

  // Recalcula isEdited quando algo mudar
  // void _recomputeEdited() {
  //   var networkState = context.read<NetworkState>();
  //   final original = networkState.getNetworkTableOriginal;

  //   final originalJson = jsonEncode(original.map((r) => r.toJson()).toList());
  //   final currentJson = jsonEncode(_rows.map((r) => r.toJson()).toList());

  //   if (originalJson != currentJson) {
  //     networkState.setEdited(true);
  //   } else {
  //     networkState.setEdited(false);
  //   }
  // }
  // void _recomputeEditedDebounced() {
  //   _editedDebounce?.cancel();
  //   _editedDebounce = Timer(const Duration(milliseconds: 250), _recomputeEdited);
  // }

  // Criando listeners em IP e mascara para calcular gateway automaticamente
  void _calcGateway(r) {
    var configState = context.read<ConfigState>();
    final ip = r.ipCtrl.text;
    final mask = r.maskCtrl.text;
    final gw = r.gwCtrl.text;

    if (configState.isCalcGatewayEnabled &&
        gw.isEmpty &&
        isIPv4(ip) &&
        isMask(mask)) {
      try {
        final netInfo = networkInfo(ip: ip, mask: mask);
        setState(() {
          r.gwCtrl.text = netInfo.firstUsable ?? '';
        });
      } catch (e) {
        // erro ao calcular, não faz nada
      }
    }
  }

  // Criando listeners
  void _attachListeners(NetRow r) {
    // for (final c in [r.descCtrl, r.ipCtrl, r.maskCtrl, r.gwCtrl, r.dnsCtrl]) {
    //   c.addListener(_recomputeEditedDebounced);
    // }
    for (final c in [r.ipCtrl, r.maskCtrl]) {
      c.addListener(() => _calcGateway(r));
    }
  }

  DataRow _buildRow(int index) {
    final r = _rows[index];
    for (final r in _rows) {
      _attachListeners(r);
      //   _attachListenersEdited(r);
      //   _attachListenersCalcGateway(r);
    }
    return DataRow(
      cells: [
        DataCell(
          IconButton(
            tooltip: isAdmin()
                ? 'Aplicar'
                : 'Aplicar: Necessita permissão de Administrador',
            icon: const Icon(Icons.play_arrow),
            iconSize: 30,
            disabledColor: Colors.grey,
            color: Colors.green,
            onPressed: !isAdmin() ? () => _executeRow(index) : null,
          ),
        ),

        DataCell(
          TextFormFieldValidate(
            controller: r.descCtrl,
            field: 'Descrição',
            isRequired: true,
            maxLength: 50,
            hintText: 'Descrição',
          ),
        ),
        DataCell(
          TextFormFieldValidate(
            controller: r.ipCtrl,
            field: 'IP',
            isRequired: true,
            isIPv4: true,
          ),
        ),
        DataCell(
          TextFormFieldValidate(
            controller: r.maskCtrl,
            field: 'Máscara',
            isRequired: true,
            isMask: true,
            hintText: '255.255.255.0',
          ),
        ),
        DataCell(
          TextFormFieldValidate(
            controller: r.gwCtrl,
            field: 'Gateway',
            isIPv4: true,
            hintText: '0.0.0.1',
          ),
        ),
        DataCell(
          TextFormFieldValidate(
            controller: r.dnsCtrl,
            field: 'DNS',
            hintText: '8.8.8.8;1.1.1.1',
          ),
        ),

        DataCell(
          SizedBox(
            width: 200,
            child: FormField<String>(
              validator: (value) {
                if ((r.interfaceName.isEmpty)) {
                  return 'Selecione uma interface';
                }
                return null;
              },
              builder: (state) {
                return InterfaceDropdown(
                  value: r.interfaceName,
                  label: 'Interface',
                  forceErrorText: state.hasError ? state.errorText! : null,
                  onChanged: (name) {
                    setState(() {
                      r.interfaceName = name ?? '';
                      // _recomputeEdited();
                    });
                    state.validate();
                  },
                );
              },
            ),
          ),
        ),

        // Coluna de ações
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Validar configuração',
                icon: const Icon(Icons.check_circle, color: Colors.green),
                iconSize: 20,
                onPressed: () {
                  _validateConfig(index);
                },
              ),
              IconButton(
                tooltip: 'Excluir',
                icon: const Icon(Icons.delete, color: Colors.red),
                iconSize: 15,
                onPressed: () async {
                  // final confirm = await confirmDelete(context);
                  final confirm = await confirmDialog(
                    context,
                    title: 'Confirmar exclusão',
                    message: 'Tem certeza que deseja excluir esta linha?',
                    confirmText: 'Excluir',
                    isDanger: true,
                    icon: Icons.delete_forever,
                    barrierDismissible: false,
                  );
                  if (confirm) {
                    _removeRow(index);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // var networkState = context.watch<NetworkState>();
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return ScrollVerticalComponent(
      child: Column(
        children: [
          if (!isAdmin())
            Text(
              'Você não está executando o programa como Administrador! Obrigatório para alterar o IP.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                height: 4,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 30),
              // Botão de salvar
              IconButton(
                tooltip: 'Salvar',
                icon: const Icon(Icons.save),
                onPressed: _saveToDisk,
                // color: networkState.getIsEdited ? Colors.red : Colors.grey,
                color: Colors.green,
              ),
              const SizedBox(width: 30),
              // Container de definir DHCP
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: InterfaceDropdown(
                          value: interfaceDHCP,
                          onChanged: (name) => setState(() {
                            interfaceDHCP = name ?? '';
                            if (interfaceDHCP.isNotEmpty) {
                              interfaceDHCPValidator = '';
                            }
                          }),
                          forceErrorText: interfaceDHCPValidator.isEmpty
                              ? null
                              : interfaceDHCPValidator,
                          label: 'Interface',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Tooltip(
                        message: isAdmin()
                            ? 'Definir DHCP'
                            : 'Definir DHCP: Necessita permissão de Administrador',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                          ),
                          onPressed: isAdmin() ? () => _executeDHCP() : null,
                          child: Row(
                            children: [
                              const Text(
                                'Definir DHCP',
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.play_arrow, color: Colors.green),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ScrollHorizontalComponent(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Container(
                margin: const EdgeInsets.only(bottom: 11),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 1),
                      bottom: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: DataTable(
                      columnSpacing: 20,
                      // dataRowMinHeight: 40,
                      columns: const [
                        DataColumn(label: Text('Aplicar')),
                        DataColumn(label: Text('Descrição')),
                        DataColumn(label: Text('IP')),
                        DataColumn(label: Text('Máscara')),
                        DataColumn(label: Text('Gateway')),
                        DataColumn(label: Text('DNS (; separados)')),
                        DataColumn(label: Text('Interface')),
                        DataColumn(label: Text('Ações')),
                      ],
                      rows: List.generate(_rows.length, _buildRow),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addRow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 10), // espaço para o rodapé
        ],
      ),
    );
  }
}
