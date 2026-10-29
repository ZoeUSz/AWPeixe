import 'dart:async';

import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../formatacao.dart';
import '../models/alimentacao.dart';
import '../models/status_tanque.dart';
import '../theme.dart';
import 'alertas_page.dart';
import 'alimentacao_page.dart';
import 'especies_page.dart';
import 'historico_page.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  final _api = ApiClient();
  StatusTanque? _status;
  String? _erro;
  bool _buscando = false;
  int _alertasAbertos = 0;
  Alimentacao? _ultimaAlimentacao;
  bool _alimentacaoCarregada = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _atualizar();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _atualizar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _atualizar() async {
    if (_buscando) return;
    _buscando = true;
    try {
      final status = await _api.fetchStatus(tanqueId);
      final abertos = await _contarAlertasAbertos();
      final alimentacoes = await _buscarAlimentacoes();
      if (!mounted) return;
      setState(() {
        _status = status;
        _alertasAbertos = abertos ?? _alertasAbertos;
        if (alimentacoes != null) {
          _alimentacaoCarregada = true;
          _ultimaAlimentacao =
              alimentacoes.isEmpty ? null : alimentacoes.first;
        }
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      _buscando = false;
    }
  }

  // Quantos alertas estão em andamento (null se não deu para consultar).
  Future<int?> _contarAlertasAbertos() async {
    try {
      final alertas = await _api.fetchAlertas(tanqueId);
      return alertas.where((a) => !a.resolvido).length;
    } on ApiException {
      return null;
    }
  }

  // Alimentações mais recentes (null se não deu para consultar).
  Future<List<Alimentacao>?> _buscarAlimentacoes() async {
    try {
      return await _api.fetchAlimentacoes(tanqueId, limite: 1);
    } on ApiException {
      return null;
    }
  }

  void _abrirAlimentacao() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AlimentacaoPage()),
    );
  }

  Future<void> _escolherEspecie() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EspeciesPage()),
    );
    _atualizar();
  }

  void _abrirAlertas() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AlertasPage()),
    );
  }

  void _abrirHistorico() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoricoPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conectado = _erro == null && _status != null;
    // Em tela estreita (celular) os botões viram só ícones.
    final estreito = MediaQuery.sizeOf(context).width < 720;
    final iconeAlertas = Badge(
      isLabelVisible: _alertasAbertos > 0,
      backgroundColor: AppColors.alerta,
      textColor: Colors.white,
      label: Text('$_alertasAbertos'),
      child: Icon(
        _alertasAbertos > 0
            ? Icons.notifications_active
            : Icons.notifications_none,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWPeixe',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (estreito) ...[
            IconButton(
              tooltip: 'Alertas',
              onPressed: _abrirAlertas,
              icon: iconeAlertas,
            ),
            IconButton(
              tooltip: 'Alimentação',
              onPressed: _abrirAlimentacao,
              icon: const Icon(Icons.restaurant),
            ),
            IconButton(
              tooltip: 'Histórico',
              onPressed: _abrirHistorico,
              icon: const Icon(Icons.show_chart),
            ),
          ] else ...[
            TextButton.icon(
              onPressed: _abrirAlertas,
              icon: iconeAlertas,
              label: const Text('Alertas'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _abrirAlimentacao,
              icon: const Icon(Icons.restaurant),
              label: const Text('Alimentação'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: _abrirHistorico,
              icon: const Icon(Icons.show_chart),
              label: const Text('Histórico'),
            ),
            const SizedBox(width: 16),
          ],
          _Conexao(conectado: conectado, compacto: estreito),
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
    final status = _status;
    if (status == null) {
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
                onPressed: _atualizar,
                child: const Text('Tentar de novo'),
              ),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final temperatura = status.parametro('TEMPERATURA');
    final ph = status.parametro('PH');
    // Largura dos cards: 520 no desktop, a largura da tela no celular.
    final larguraCard =
        (MediaQuery.sizeOf(context).width - 48).clamp(0.0, 520.0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cabecalho(status: status, onEscolher: _escolherEspecie),
              const SizedBox(height: 20),
              _BannerStatus(status: status, onEscolher: _escolherEspecie),
              if (_erro != null) ...[
                const SizedBox(height: 10),
                Text('Sem conexão: $_erro (mostrando a última leitura)',
                    style: const TextStyle(color: AppColors.alertaTexto)),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (temperatura != null)
                    SizedBox(width: larguraCard, child: _ParametroCard(temperatura)),
                  if (ph != null)
                    SizedBox(width: larguraCard, child: _ParametroCard(ph)),
                ],
              ),
              if (_alimentacaoCarregada) ...[
                const SizedBox(height: 16),
                _AlimentacaoCard(
                    ultima: _ultimaAlimentacao, onAbrir: _abrirAlimentacao),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Conexao extends StatelessWidget {
  const _Conexao({required this.conectado, this.compacto = false});

  final bool conectado;
  final bool compacto; // só a bolinha, sem texto (celular)

  @override
  Widget build(BuildContext context) {
    final texto = conectado ? 'Sistema conectado' : 'Sem conexão com a API';
    if (compacto) {
      return Padding(
        padding: const EdgeInsets.only(right: 16, left: 4),
        child: Tooltip(
          message: texto,
          child: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: conectado ? AppColors.ok : AppColors.alerta,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: conectado ? AppColors.ok : AppColors.alerta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: conectado ? AppColors.okTexto : AppColors.alertaTexto,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.status, required this.onEscolher});

  final StatusTanque status;
  final VoidCallback onEscolher;

  @override
  Widget build(BuildContext context) {
    final temEspecie = status.especie != null;
    final estreito = MediaQuery.sizeOf(context).width < 720;

    final titulo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VISÃO GERAL',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.primaria,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          status.tanque,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );

    final textos = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Espécie atual',
            style: TextStyle(fontSize: 12, color: AppColors.textoSecundario)),
        Text(
          status.especie ?? 'Nenhuma',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );

    final botao = OutlinedButton(
      onPressed: onEscolher,
      child: Text(temEspecie ? 'Trocar espécie' : 'Escolher espécie'),
    );

    final caixa = Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        mainAxisSize: estreito ? MainAxisSize.max : MainAxisSize.min,
        children: [
          const Icon(Icons.set_meal, color: AppColors.primaria),
          const SizedBox(width: 10),
          if (estreito) Expanded(child: textos) else textos,
          const SizedBox(width: 16),
          botao,
        ],
      ),
    );

    if (estreito) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titulo, const SizedBox(height: 14), caixa],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Expanded(child: titulo), caixa],
    );
  }
}

class _BannerInfo {
  const _BannerInfo({
    required this.fundo,
    required this.borda,
    required this.cor,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    this.acao,
  });

  final Color fundo;
  final Color borda;
  final Color cor;
  final IconData icone;
  final String titulo;
  final String subtitulo;
  final String? acao;
}

class _BannerStatus extends StatelessWidget {
  const _BannerStatus({required this.status, required this.onEscolher});

  final StatusTanque status;
  final VoidCallback onEscolher;

  _BannerInfo _info() {
    switch (status.statusGeral) {
      case 'OK':
        return _BannerInfo(
          fundo: AppColors.okFundo,
          borda: const Color(0xFFBCE4CC),
          cor: AppColors.okTexto,
          icone: Icons.check_circle_outline,
          titulo: 'Tudo certo: parâmetros dentro do ideal',
          subtitulo: 'As leituras estão adequadas para ${status.especie}.',
        );
      case 'ALERTA':
        return _BannerInfo(
          fundo: AppColors.alertaFundo,
          borda: const Color(0xFFF1BCBC),
          cor: AppColors.alertaTexto,
          icone: Icons.warning_amber_rounded,
          titulo:
              'Alerta para ${status.especie ?? 'o tanque'}: ${_descreverAlerta()}',
          subtitulo: _acoes(),
        );
      case 'SEM_ESPECIE':
        return const _BannerInfo(
          fundo: Color(0xFFEDF2F4),
          borda: AppColors.borda,
          cor: Color(0xFF52666E),
          icone: Icons.set_meal,
          titulo: 'Escolha uma espécie para começar',
          subtitulo: 'Assim poderemos comparar as leituras com a faixa ideal.',
          acao: 'Escolher espécie',
        );
      default:
        final desatualizada =
            status.parametros.any((p) => p.situacao == 'DESATUALIZADA');
        return _BannerInfo(
          fundo: AppColors.avisoFundo,
          borda: const Color(0xFFEDCF84),
          cor: AppColors.avisoTexto,
          icone: Icons.schedule,
          titulo: desatualizada
              ? 'Sem leitura recente dos sensores'
              : 'Aguardando dados do sensor',
          subtitulo: desatualizada
              ? 'A última leitura é antiga. Verifique a conexão dos sensores.'
              : 'Os cards serão atualizados assim que chegarem novas leituras.',
        );
    }
  }

  // Ação indicada para cada parâmetro fora da faixa.
  String _acoes() {
    final acoes = <String>[];
    for (final p in status.parametros) {
      if (p.tipo == 'TEMPERATURA' && p.situacao == 'ACIMA') {
        acoes.add('ligar o cooler para resfriar a água');
      } else if (p.tipo == 'TEMPERATURA' && p.situacao == 'ABAIXO') {
        acoes.add('ligar o aquecedor para esquentar a água');
      } else if (p.tipo == 'PH' && p.situacao == 'ACIMA') {
        acoes.add('reduzir o pH da água');
      } else if (p.tipo == 'PH' && p.situacao == 'ABAIXO') {
        acoes.add('elevar o pH da água');
      }
    }
    if (acoes.isEmpty) return 'Verifique o aquário e os equipamentos.';
    final texto = acoes.join('; ');
    return 'Ação: ${texto[0].toUpperCase()}${texto.substring(1)}.';
  }

  String _descreverAlerta() {
    final partes = <String>[];
    for (final p in status.parametros) {
      final nome = p.tipo == 'TEMPERATURA' ? 'temperatura' : 'pH';
      if (p.situacao == 'ACIMA') partes.add('$nome acima do ideal');
      if (p.situacao == 'ABAIXO') partes.add('$nome abaixo do ideal');
    }
    return partes.isEmpty ? 'parâmetro fora do ideal' : partes.join(' e ');
  }

  @override
  Widget build(BuildContext context) {
    final info = _info();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: info.fundo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.borda),
      ),
      child: Row(
        children: [
          Icon(info.icone, color: info.cor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: info.cor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(info.subtitulo, style: TextStyle(color: info.cor)),
              ],
            ),
          ),
          if (info.acao != null)
            FilledButton(onPressed: onEscolher, child: Text(info.acao!)),
        ],
      ),
    );
  }
}

class _ParametroCard extends StatelessWidget {
  const _ParametroCard(this.p);

  final Parametro p;

  bool get _temperatura => p.tipo == 'TEMPERATURA';

  String get _textoBadge {
    switch (p.situacao) {
      case 'OK':
        return 'Dentro da faixa';
      case 'ACIMA':
        return 'Acima da faixa';
      case 'ABAIXO':
        return 'Abaixo da faixa';
      case 'DESATUALIZADA':
        return 'Sem leitura recente';
      case 'SEM_SENSOR':
        return 'Sem sensor';
      case 'SEM_FAIXA':
        return 'Sem faixa';
      default:
        return 'Sem dados';
    }
  }

  String get _ideal {
    if (p.min == null || p.max == null) {
      return 'Escolha uma espécie para ver a faixa ideal';
    }
    final a = formatarNumero(p.min!, semCasasSeInteiro: _temperatura);
    final b = formatarNumero(p.max!, semCasasSeInteiro: _temperatura);
    return 'Ideal: $a a $b${_temperatura ? ' °C' : ''}';
  }

  String get _atualizado {
    final t = p.registradoEm;
    if (t == null) return 'Sem leituras ainda';
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 5) return 'Atualizado agora';
    if (s < 60) return 'Atualizado há $s s';
    if (s < 3600) return 'Atualizado há ${s ~/ 60} min';
    return 'Atualizado há ${s ~/ 3600} h';
  }

  @override
  Widget build(BuildContext context) {
    final fora = p.foraDaFaixa;
    final ok = p.situacao == 'OK';
    final antiga = p.situacao == 'DESATUALIZADA';
    final fundoBadge = fora
        ? AppColors.alertaFundo
        : ok
            ? AppColors.okFundo
            : antiga
                ? AppColors.avisoFundo
                : const Color(0xFFEEF3F5);
    final textoBadge = fora
        ? AppColors.alertaTexto
        : ok
            ? AppColors.okTexto
            : antiga
                ? AppColors.avisoTexto
                : AppColors.textoSecundario;
    final corValor = fora
        ? AppColors.alertaTexto
        : antiga
            ? AppColors.neutro
            : AppColors.texto;
    final valor = p.valor == null
        ? '—'
        : formatarNumero(p.valor!, casas: _temperatura ? 1 : 2);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: fora ? AppColors.alerta : AppColors.borda,
          width: fora ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: fora
                        ? AppColors.alertaFundo
                        : AppColors.primariaClara,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _temperatura ? Icons.thermostat : Icons.science_outlined,
                    size: 20,
                    color: fora ? AppColors.alertaTexto : AppColors.primariaEscura,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: fundoBadge,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _textoBadge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textoBadge,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _temperatura ? 'Temperatura' : 'pH',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textoSecundario,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: corValor,
                  ),
                ),
                if (_temperatura && p.valor != null) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('°C',
                        style: TextStyle(fontSize: 18, color: corValor)),
                  ),
                ],
                if (p.situacao == 'ACIMA')
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Icon(Icons.arrow_upward, color: corValor),
                  ),
                if (p.situacao == 'ABAIXO')
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Icon(Icons.arrow_downward, color: corValor),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(_ideal,
                style: const TextStyle(color: AppColors.textoSecundario)),
            const SizedBox(height: 14),
            if (p.valor != null && p.min != null && p.max != null && !antiga)
              _Medidor(valor: p.valor!, min: p.min!, max: p.max!, fora: fora)
            else
              const SizedBox(height: 18),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 14, color: AppColors.neutro),
                const SizedBox(width: 6),
                Text(_atualizado,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.neutro)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Barra com a faixa ideal em verde e um marcador na posição da leitura.
class _Medidor extends StatelessWidget {
  const _Medidor({
    required this.valor,
    required this.min,
    required this.max,
    required this.fora,
  });

  final double valor;
  final double min;
  final double max;
  final bool fora;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final largura = c.maxWidth;
        final amplitude = (max - min) == 0 ? 1.0 : (max - min);
        final lo = min - amplitude * 0.5;
        final hi = max + amplitude * 0.5;
        double pos(double v) =>
            (((v - lo) / (hi - lo)).clamp(0.0, 1.0)).toDouble() * largura;

        final inicio = pos(min);
        final fim = pos(max);
        final x = pos(valor);

        return SizedBox(
          height: 18,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF0F2),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              Positioned(
                left: inicio,
                width: fim - inicio,
                top: 5,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.okFundo,
                    border: Border.all(color: const Color(0xFFBCE4CC)),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              Positioned(
                left: x - 8,
                top: 1,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: fora ? AppColors.alerta : AppColors.primaria,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Última vez em que o dispenser soltou comida.
class _AlimentacaoCard extends StatelessWidget {
  const _AlimentacaoCard({required this.ultima, required this.onAbrir});

  final Alimentacao? ultima;
  final VoidCallback onAbrir;

  @override
  Widget build(BuildContext context) {
    final a = ultima;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1056),
      child: SizedBox(
        width: double.infinity,
        child: Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borda),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: const Icon(Icons.restaurant, color: AppColors.primaria),
          title: Text(
            a == null
                ? 'Nenhuma alimentação registrada'
                : 'Última alimentação: ${a.quando}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: a == null
              ? null
              : Text(a.detalhe),
          trailing:
              TextButton(onPressed: onAbrir, child: const Text('Ver todas')),
        ),
      ),
      ),
    );
  }
}