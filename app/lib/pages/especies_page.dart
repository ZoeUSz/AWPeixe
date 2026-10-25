import 'package:flutter/material.dart';

import '../api.dart';
import '../models/especie.dart';
import '../theme.dart';

class EspeciesPage extends StatefulWidget {
  const EspeciesPage({super.key});

  @override
  State<EspeciesPage> createState() => _EspeciesPageState();
}

class _EspeciesPageState extends State<EspeciesPage> {
  final _api = ApiClient();

  List<String> _grupos = [];
  List<Especie> _especies = [];
  String? _grupo; // null = todos
  String _busca = '';
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      if (_grupos.isEmpty) {
        _grupos = await _api.fetchGrupos();
      }
      final especies = await _api.fetchEspecies(grupo: _grupo);
      if (!mounted) return;
      setState(() {
        _especies = especies;
        _carregando = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregando = false;
      });
    }
  }

  List<Especie> get _filtradas {
    final q = _busca.trim().toLowerCase();
    if (q.isEmpty) return _especies;
    return _especies
        .where((e) =>
            e.nomeComum.toLowerCase().contains(q) ||
            e.nomeCientifico.toLowerCase().contains(q))
        .toList();
  }

  void _escolherGrupo(String? grupo) {
    _grupo = grupo;
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaMonitor',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borda),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escolher espécie',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text(
              'Selecione a espécie para comparar as leituras com suas faixas ideais.',
              style: TextStyle(color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 360,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar por nome',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borda),
                  ),
                ),
                onChanged: (v) => setState(() => _busca = v),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _grupo == null,
                  onSelected: (_) => _escolherGrupo(null),
                ),
                for (final g in _grupos)
                  ChoiceChip(
                    label: Text(g),
                    selected: _grupo == g,
                    onSelected: (_) => _escolherGrupo(g),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(child: _conteudo()),
          ],
        ),
      ),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: AppColors.neutro),
            const SizedBox(height: 10),
            Text(_erro!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _carregar,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      );
    }
    final lista = _filtradas;
    if (lista.isEmpty) {
      return const Center(child: Text('Nenhuma espécie encontrada.'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: lista.length,
      itemBuilder: (context, i) => _EspecieCard(lista[i]),
    );
  }
}

class _EspecieCard extends StatelessWidget {
  const _EspecieCard(this.especie);

  final Especie especie;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borda),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              especie.nomeComum,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              especie.nomeCientifico,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (especie.grupoHidroquimico != null)
                  _Tag(especie.grupoHidroquimico!, destaque: true),
                const _Tag('Água doce'),
              ],
            ),
            const Spacer(),
            _Fato('pH', especie.faixaPh),
            _Fato('Temperatura', especie.faixaTemp),
            _Fato('Tanque mínimo', especie.tanqueMinimo),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.texto, {this.destaque = false});

  final String texto;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: destaque ? AppColors.primariaClara : const Color(0xFFEEF3F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          color: destaque ? AppColors.primariaEscura : AppColors.textoSecundario,
        ),
      ),
    );
  }
}

class _Fato extends StatelessWidget {
  const _Fato(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo,
              style: const TextStyle(color: AppColors.textoSecundario)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}