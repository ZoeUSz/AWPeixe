import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../formatacao.dart';
import '../models/historico.dart';
import '../models/status_tanque.dart';
import '../theme.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  static const _opcoesPontos = [30, 60, 120];

  final _api = ApiClient();
  Historico? _historico;
  StatusTanque? _status;
  String? _erro;
  bool _buscando = false;
  int _pontos = 60;
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
      final historico = await _api.fetchHistorico(tanqueId, pontos: _pontos);
      final status = await _api.fetchStatus(tanqueId);
      if (!mounted) return;
      setState(() {
        _historico = historico;
        _status = status;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      _buscando = false;
    }
  }

  void _mudarPontos(int n) {
    if (n == _pontos) return;
    setState(() => _pontos = n);
    _atualizar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico das leituras',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borda),
        ),
      ),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    final historico = _historico;
    if (historico == null) {
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

    final temperatura = _status?.parametro('TEMPERATURA');
    final ph = _status?.parametro('PH');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _status?.especie == null
                          ? 'Sem espécie selecionada'
                          : 'Faixa ideal de ${_status!.especie}',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textoSecundario),
                    ),
                  ),
                  for (final n in _opcoesPontos) ...[
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Últimas $n'),
                      selected: _pontos == n,
                      onSelected: (_) => _mudarPontos(n),
                    ),
                  ],
                ],
              ),
              if (_erro != null) ...[
                const SizedBox(height: 10),
                Text('Sem conexão: $_erro (mostrando os últimos dados)',
                    style: const TextStyle(color: AppColors.alertaTexto)),
              ],
              const SizedBox(height: 16),
              _GraficoCard(
                titulo: 'Temperatura',
                unidade: '°C',
                pontos: historico.temperatura,
                min: temperatura?.min,
                max: temperatura?.max,
              ),
              const SizedBox(height: 16),
              _GraficoCard(
                titulo: 'pH',
                unidade: '',
                pontos: historico.ph,
                min: ph?.min,
                max: ph?.max,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dois(int n) => n.toString().padLeft(2, '0');

String _hora(DateTime t) => '${_dois(t.hour)}:${_dois(t.minute)}:${_dois(t.second)}';

class _GraficoCard extends StatelessWidget {
  const _GraficoCard({
    required this.titulo,
    required this.unidade,
    required this.pontos,
    required this.min,
    required this.max,
  });

  final String titulo;
  final String unidade;
  final List<PontoHistorico> pontos;
  final double? min; // faixa ideal da espécie (pode ser nula)
  final double? max;

  bool get _temFaixa => min != null && max != null;

  String _fmt(double v) => formatarNumero(v, casas: 1);

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_resumo(),
                style: const TextStyle(color: AppColors.textoSecundario)),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: pontos.isEmpty
                  ? const Center(
                      child: Text('Ainda não há leituras para mostrar.',
                          style: TextStyle(color: AppColors.textoSecundario)),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 28),
                      child: LineChart(_dados()),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _resumo() {
    final partes = <String>[];
    if (pontos.isNotEmpty) {
      final valores = pontos.map((p) => p.valor);
      final menor = valores.reduce(math.min);
      final maior = valores.reduce(math.max);
      final u = unidade.isEmpty ? '' : ' $unidade';
      partes.add('Mín ${_fmt(menor)}$u · Máx ${_fmt(maior)}$u');
    }
    if (_temFaixa) {
      final u = unidade.isEmpty ? '' : ' $unidade';
      partes.add('Faixa ideal (área verde): ${_fmt(min!)} a ${_fmt(max!)}$u');
    } else {
      partes.add('Escolha uma espécie para ver a faixa ideal');
    }
    return partes.join('   |   ');
  }

  LineChartData _dados() {
    // Eixo X = posição da leitura (0, 1, 2...). Se passar mais de 5 minutos
    // entre duas leituras, a linha é interrompida (o sistema ficou fora do ar).
    const limiteLacunaSegundos = 300;
    final spots = <FlSpot>[];
    for (var i = 0; i < pontos.length; i++) {
      if (i > 0 &&
          pontos[i].em.difference(pontos[i - 1].em).inSeconds >
              limiteLacunaSegundos) {
        spots.add(FlSpot.nullSpot);
      }
      spots.add(FlSpot(i.toDouble(), pontos[i].valor));
    }

    var lo = pontos.map((p) => p.valor).reduce(math.min);
    var hi = pontos.map((p) => p.valor).reduce(math.max);
    if (_temFaixa) {
      lo = math.min(lo, min!);
      hi = math.max(hi, max!);
    }
    final folga = (hi - lo) == 0 ? 1.0 : (hi - lo) * 0.15;
    final maxX = math.max((pontos.length - 1).toDouble(), 1.0);

    const estiloEixo =
        TextStyle(fontSize: 11, color: AppColors.textoSecundario);

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: lo - folga,
      maxY: hi + folga,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppColors.borda, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            getTitlesWidget: (v, meta) {
              // Esconde os rótulos das pontas (ficavam sobrepostos).
              if (v == meta.min || v == meta.max) return const SizedBox.shrink();
              return Text(_fmt(v), style: estiloEixo);
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: maxX / 4,
            getTitlesWidget: (v, meta) {
              final i = v.round().clamp(0, pontos.length - 1);
              final t = pontos[i].em;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_hora(t), style: estiloEixo),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) => [
            for (final spot in touchedSpots)
              LineTooltipItem(
                '${_fmt(spot.y)}${unidade.isEmpty ? '' : ' $unidade'}\n'
                '${_hora(pontos[spot.x.round().clamp(0, pontos.length - 1)].em)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
          ],
        ),
      ),
      rangeAnnotations: RangeAnnotations(
        horizontalRangeAnnotations: [
          if (_temFaixa)
            HorizontalRangeAnnotation(
              y1: min!,
              y2: max!,
              color: AppColors.okFundo,
            ),
        ],
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: AppColors.primaria,
          barWidth: 2.5,
          dotData: FlDotData(show: spots.length <= 40),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}