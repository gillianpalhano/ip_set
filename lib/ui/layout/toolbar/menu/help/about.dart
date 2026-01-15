import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/gillianpalhano/ip_set');
Future<void> _abrirLink() async {
  if (!await launchUrl(_url)) {
    throw 'Não foi possível abrir $_url';
  }
}

void aboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Center(
        child: Text(
          'Sobre o IPSet',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 450),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image(image: AssetImage('assets/images/logo_laranja_1000.png'), height: 120),
            SizedBox(width: 40),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('IPSet'),
                Text('Versão 1.0.0'),
                SizedBox(height: 10),
                Text('Desenvolvido por Gillian Palhano'),
                SizedBox(height: 20),
                TextButton(
                  onPressed: _abrirLink,
                  style: ButtonStyle(
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Colors.blue),
                    ),
                  ),
                  child: Text(
                    'Visite o projeto no GitHub',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Fechar',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      ],
    ),
  );
}
