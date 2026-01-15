import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:ip_set/utils/validate.dart';

class TextFormFieldValidate extends StatefulWidget {
  const TextFormFieldValidate({
    super.key,
    required this.controller,
    this.field = 'campo',
    this.isRequired = false,
    this.isIPv4 = false,
    this.isMask = false,
    this.minValue,
    this.maxValue,
    this.minLength,
    this.maxLength,
    this.validationDelay = const Duration(milliseconds: 1000),
    this.keyboardType = TextInputType.number,
    // this.inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    this.hintText = '0.0.0.0',
  });

  final TextEditingController controller;
  final String field;
  final bool isRequired;
  final bool isIPv4;
  final bool isMask;
  final int? minValue;
  final int? maxValue;
  final int? minLength;
  final int? maxLength;

  /// Tempo de espera após parar de digitar para validar
  final Duration validationDelay;

  final TextInputType keyboardType;
  // final List<TextInputFormatter> inputFormatters;
  final String hintText;

  @override
  State<TextFormFieldValidate> createState() => _TextFormFieldValidateState();
}

class _TextFormFieldValidateState extends State<TextFormFieldValidate> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  Timer? _debounce;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Valida ao perder o foco imediatamente (sem debounce)
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _debounce?.cancel();
        _fieldKey.currentState?.validate();
      }
    });

    // Dispara validação com debounce
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(widget.validationDelay, () {
      // dispara a validação após o delay
      _fieldKey.currentState?.validate();
    });
  }

  @override
  void didUpdateWidget(covariant TextFormFieldValidate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const hintStyle = TextStyle(color: Color.fromARGB(30, 255, 255, 255));
    return TextFormField(
      key: _fieldKey,
      focusNode: _focusNode,
      controller: widget.controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hintText,
        hintStyle: hintStyle,
        isDense: true,
      ),
      keyboardType: widget.keyboardType,
      // inputFormatters: widget.inputFormatters,
      autovalidateMode:
          AutovalidateMode.disabled, // debounce controla a validação
      validator: (v) {
        if (widget.isRequired) {
          final r = validateIsRequired(v, field: widget.field);
          if (r != null) return r;
        }
        if (widget.isIPv4) {
          final r = validateIsIPv4(v, allowEmpty: !widget.isRequired);
          if (r != null) return r;
        }
        if (widget.isMask) {
          final r = validateMaskDotted(v, allowEmpty: !widget.isRequired);
          if (r != null) return r;
        }
        if (widget.minValue != null || widget.maxValue != null) {
          final r = validateIsNumberRange(
            v,
            min: widget.minValue,
            max: widget.maxValue,
            allowEmpty: !widget.isRequired,
            field: widget.field,
          );
          if (r != null) return r;
        }
        if (widget.minLength != null || widget.maxLength != null) {
          final r = validateIsLength(
            v,
            min: widget.minLength,
            max: widget.maxLength,
            allowEmpty: !widget.isRequired,
            field: widget.field,
          );
          if (r != null) return r;
        }
        return null; // válido
      },
    );
  }
}
