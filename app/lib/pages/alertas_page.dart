import 'dart:async';

import 'package:flutter/material.dart';

import '../api.dart';
import '../config.dart';
import '../models/alerta.dart';
import '../theme.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  final _api = ApiClient();
  List<Alerta>? _alertas;
  String? _erro;
  bool _buscando = false;
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
      final alertas = await _api.fetchAlertas(tanqueId);
      if (!mounted) return;
      setState(() {
        _alertas = alertas;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } finally {
      _buscando = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas',
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
    final alertas = _alertas;
    if (alertas == null) {
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

    final abertos = alertas.where((a) => !a.resolvido).toList();
    final resolvidos = alertas.where((a) => a.resolvido).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_erro != null) ...[
                Text('Sem conexão: $_erro (mostrando os últimos dados)',
                    style: const TextStyle(color: AppColors.alertaTexto)),
                const SizedBox(height: 12),
              ],
              _Resumo(abertos: abertos.length),
              const SizedBox(height: 24),
              if (alertas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nenhum alerta registrado até agora.',
                    style: TextStyle(color: AppColors.textoSecundario),
                  ),
                ),
              if (abertos.isNotEmpty) ...[
                const _Titulo('Em andamento'),
                for (final a in abertos) _AlertaCard(a),
              ],
              if (resolvidos.isNotEmpty) ...[
                if (abertos.isNotEmpty) const SizedBox(height: 16),
                const _Titulo('Resolvidos'),
                for (final a in resolvidos) _AlertaCard(a),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({required this.abertos});

  final int abertos;

  @override
  Widget build(BuildContext context) {
    final tudoOk = abertos == 0;
    final cor = tudoOk ? AppColors.okTexto : AppColors.alertaTexto;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tudoOk ? AppColors.okFundo : AppColors.alertaFundo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tudoOk ? const Color(0xFFBCE4CC) : const Color(0xFFF1BCBC),
        ),
      ),
      child: Row(
        children: [
          Icon(
            tudoOk ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: cor,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              tudoOk
                  ? 'Nenhum alerta em andamento'
                  : abertos == 1
                      ? '1 alerta em andamento'
                      : '$abertos alertas em andamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.primaria,
        ),
      ),
    );
  }
}

String _dois(int n) => n.toString().padLeft(2, '0');

String _dataHora(DateTime t) =>
    '${_dois(t.day)}/${_dois(t.month)} ${_dois(t.hour)}:${_dois(t.minute)}:${_dois(t.second)}';

String _duracao(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  if (s < 60) return '$s s';
  if (s < 3600) return '${s ~/ 60} min ${s % 60} s';
  return '${s ~/ 3600} h ${(s % 3600) ~/ 60} min';
}

class _AlertaCard extends StatelessWidget {
  const _AlertaCard(this.a);

  final Alerta a;

  @override
  Widget build(BuildContext context) {
    final aberto = !a.resolvido;
    final detalhe = aberto
        ? 'Desde ${_dataHora(a.geradoEm)} · há ${_duracao(DateTime.now().difference(a.geradoEm))}'
        : 'Início ${_dataHora(a.geradoEm)} · resolvido ${_dataHora(a.resolvidoEm ?? a.geradoEm)}'
            '${a.resolvidoEm == null ? '' : ' · durou ${_duracao(a.resolvidoEm!.difference(a.geradoEm))}'}';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: aberto ? AppColors.alerta : AppColors.borda,
          width: aberto ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: aberto ? AppColors.alertaFundo : AppColors.okFundo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                a.temperatura ? Icons.thermostat : Icons.science_outlined,
                size: 20,
                color: aberto ? AppColors.alertaTexto : AppColors.okTexto,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.mensagem,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detalhe,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textoSecundario),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: aberto ? AppColors.alertaFundo : AppColors.okFundo,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                aberto ? 'Em andamento' : 'Resolvido',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: aberto ? AppColors.alertaTexto : AppColors.okTexto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
