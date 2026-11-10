import 'package:flutter/material.dart';

import '../core/erros.dart';
import '../core/tema.dart';
import 'sa_botao.dart';

/// Mostra dados do Firestore em tempo real com um [StreamBuilder]: indica o
/// carregamento e, se falhar, explica o erro e permite tentar de novo.
class DadosAoVivo<T> extends StatefulWidget {
  /// Cria a consulta. É chamado uma vez, e de novo a cada nova tentativa.
  final Stream<T> Function() consulta;
  final Widget Function(BuildContext context, T dados) construtor;

  const DadosAoVivo({
    super.key,
    required this.consulta,
    required this.construtor,
  });

  @override
  State<DadosAoVivo<T>> createState() => _DadosAoVivoState<T>();
}

class _DadosAoVivoState<T> extends State<DadosAoVivo<T>> {
  late Stream<T> _stream = widget.consulta();
  int _tentativa = 0;

  void _tentarDeNovo() {
    setState(() {
      _stream = widget.consulta();
      _tentativa++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      // A chave descarta o erro anterior quando começa uma nova tentativa.
      key: ValueKey(_tentativa),
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Falha(
            mensagem: mensagemDeErro(snapshot.error!),
            aoTentar: _tentarDeNovo,
          );
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(Espaco.s6),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.construtor(context, snapshot.data as T);
      },
    );
  }
}

class _Falha extends StatelessWidget {
  final String mensagem;
  final VoidCallback aoTentar;

  const _Falha({required this.mensagem, required this.aoTentar});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Espaco.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 40, color: Cores.health),
          const SizedBox(height: Espaco.s2),
          Text(mensagem, textAlign: TextAlign.center, style: Estilos.body),
          const SizedBox(height: Espaco.s3),
          SaBotao(
            rotulo: 'Tentar de novo',
            icone: Icons.refresh,
            aoPressionar: aoTentar,
          ),
        ],
      ),
    );
  }
}
