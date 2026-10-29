import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../models/alimentacao.dart';
import '../theme.dart';

// Histórico das vezes em que o dispenser soltou comida.
class AlimentacaoPage extends StatefulWidget {
  const AlimentacaoPage({super.key});

  @override
  State<AlimentacaoPage> createState() => _AlimentacaoPageState();
}

class _AlimentacaoPageState extends State<AlimentacaoPage> {
  final _api = ApiClient();
  List<Alimentacao>? _itens;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final itens = await _api.fetchAlimentacoes(tanqueId, limite: 50);
      if (!mounted) return;
      setState(() {
        _itens = itens;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimentação',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borda),
        ),
      ),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    final itens = _itens;
    if (itens == null) {
      if (_erro != null) return Center(child: Text(_erro!));
      return const Center(child: CircularProgressIndicator());
    }
    if (itens.isEmpty) {
      return const Center(
        child: Text('Nenhuma alimentação registrada ainda.',
            style: TextStyle(color: AppColors.textoSecundario)),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [for (final a in itens) _Linha(a)],
          ),
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.a);

  final Alimentacao a;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borda),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.restaurant, color: AppColors.primaria),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.quando,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(a.detalhe,
                        style: const TextStyle(
                            color: AppColors.textoSecundario)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}