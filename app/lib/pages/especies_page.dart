import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../models/especie.dart';
import '../theme.dart';

class EspeciesPage extends StatefulWidget {
  const EspeciesPage({super.key});

  @override
  State<EspeciesPage> createState() => _EspeciesPageState();
}

class _EspeciesPageState extends State<EspeciesPage> {
  final _api = ApiClient();

  List<Especie> _especies = [];
  String? _termica; // null = todas (Água Fria / Água Tropical)
  String? _ph; // null = todos (Ácido / Neutro / Alcalino)
  String _busca = '';
  bool _carregando = true;
  String? _erro;

  String? _especieEmUsoId; // espécie atual do tanque
  String? _selecionandoId; // espécie sendo enviada à API

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
      final especies = await _api.fetchEspecies();
      final tanque = await _api.fetchTanque(tanqueId);
      if (!mounted) return;
      setState(() {
        _especies = especies;
        _especieEmUsoId = tanque.especieId;
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

  Future<void> _selecionar(Especie especie) async {
    setState(() => _selecionandoId = especie.id);
    final mensagens = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      await _api.definirEspecie(tanqueId, especie.id);
      if (!mounted) return;
      setState(() {
        _especieEmUsoId = especie.id;
        _selecionandoId = null;
      });
      mensagens.showSnackBar(
        SnackBar(content: Text('Espécie do tanque: ${especie.nomeComum}')),
      );
      if (navegador.canPop()) navegador.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _selecionandoId = null);
      mensagens.showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  // Os filtros são aplicados aqui, com as regras do Quadro 6 do relatório.
  List<Especie> get _filtradas {
    final q = _busca.trim().toLowerCase();
    return _especies.where((e) {
      if (_termica != null && e.classeTermica != _termica) return false;
      if (_ph != null && e.classePh != _ph) return false;
      if (q.isEmpty) return true;
      return e.nomeComum.toLowerCase().contains(q) ||
          e.nomeCientifico.toLowerCase().contains(q);
    }).toList();
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
            _LinhaFiltro(
              rotulo: 'Temperatura',
              todos: 'Todas',
              opcoes: const [
                ('Água Fria', 'Água Fria (até 25 °C)'),
                ('Água Tropical', 'Água Tropical (acima de 25 °C)'),
              ],
              selecionado: _termica,
              onSelecionar: (v) => setState(() => _termica = v),
            ),
            const SizedBox(height: 8),
            _LinhaFiltro(
              rotulo: 'pH',
              todos: 'Todos',
              opcoes: const [
                ('Ácido', 'Ácido (até 6,50)'),
                ('Neutro', 'Neutro'),
                ('Alcalino', 'Alcalino (a partir de 7,00)'),
              ],
              selecionado: _ph,
              onSelecionar: (v) => setState(() => _ph = v),
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
        mainAxisExtent: 272,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: lista.length,
      itemBuilder: (context, i) {
        final e = lista[i];
        return _EspecieCard(
          e,
          emUso: e.id == _especieEmUsoId,
          selecionando: e.id == _selecionandoId,
          onSelecionar: () => _selecionar(e),
        );
      },
    );
  }
}

class _EspecieCard extends StatelessWidget {
  const _EspecieCard(
    this.especie, {
    required this.emUso,
    required this.selecionando,
    required this.onSelecionar,
  });

  final Especie especie;
  final bool emUso;
  final bool selecionando;
  final VoidCallback onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: emUso ? AppColors.ok : AppColors.borda,
          width: emUso ? 2 : 1,
        ),
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
                if (emUso)
                  const _Tag('Em uso',
                      fundo: AppColors.okFundo, cor: AppColors.okTexto),
                if (especie.classeTermica != null)
                  _Tag(
                    especie.classeTermica!,
                    fundo: especie.classeTermica == 'Água Fria'
                        ? const Color(0xFFE3F0FA)
                        : const Color(0xFFFDEBD8),
                    cor: especie.classeTermica == 'Água Fria'
                        ? const Color(0xFF1F5F8B)
                        : const Color(0xFF9A5A12),
                  ),
                if (especie.classePh != null)
                  _Tag(
                    'pH ${especie.classePh}',
                    fundo: especie.classePh == 'Ácido'
                        ? const Color(0xFFF3E8FA)
                        : especie.classePh == 'Alcalino'
                            ? const Color(0xFFE0F2EE)
                            : AppColors.primariaClara,
                    cor: especie.classePh == 'Ácido'
                        ? const Color(0xFF6B3A8C)
                        : especie.classePh == 'Alcalino'
                            ? const Color(0xFF1B6B5A)
                            : AppColors.primariaEscura,
                  ),
              ],
            ),
            const Spacer(),
            _Fato('pH', especie.faixaPh),
            _Fato('Temperatura', especie.faixaTemp),
            _Fato('Tanque mínimo', especie.tanqueMinimo),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: emUso
                  ? const OutlinedButton(
                      onPressed: null,
                      child: Text('Espécie selecionada'),
                    )
                  : FilledButton(
                      onPressed: selecionando ? null : onSelecionar,
                      child: Text(selecionando ? 'Selecionando...' : 'Selecionar'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(
    this.texto, {
    this.fundo = const Color(0xFFEEF3F5),
    this.cor = AppColors.textoSecundario,
  });

  final String texto;
  final Color fundo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(texto, style: TextStyle(fontSize: 12, color: cor)),
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

// Uma linha de filtro: rótulo + "Todos" + as opções do relatório.
class _LinhaFiltro extends StatelessWidget {
  const _LinhaFiltro({
    required this.rotulo,
    required this.todos,
    required this.opcoes,
    required this.selecionado,
    required this.onSelecionar,
  });

  final String rotulo;
  final String todos;
  final List<(String, String)> opcoes; // (valor, texto exibido)
  final String? selecionado;
  final ValueChanged<String?> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            rotulo,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textoSecundario,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(todos),
                selected: selecionado == null,
                onSelected: (_) => onSelecionar(null),
              ),
              for (final (valor, texto) in opcoes)
                ChoiceChip(
                  label: Text(texto),
                  selected: selecionado == valor,
                  onSelected: (_) => onSelecionar(valor),
                ),
            ],
          ),
        ),
      ],
    );
  }
}