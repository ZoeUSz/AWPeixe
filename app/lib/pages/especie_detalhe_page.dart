import 'package:flutter/material.dart';

import '../fotos.dart';
import '../models/especie.dart';
import '../orientacao_ph.dart';
import '../theme.dart';

class EspecieDetalhePage extends StatelessWidget {
  const EspecieDetalhePage({super.key, required this.especie});

  final Especie especie;

  @override
  Widget build(BuildContext context) {
    final e = especie;
    return Scaffold(
      appBar: AppBar(
        title: Text(e.nomeComum,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borda),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: FotoEspecie(
                    nomeCientifico: e.nomeCientifico,
                    nomeComum: e.nomeComum,
                    altura: 200,
                  ),
                ),
                const SizedBox(height: 16),
                Text(e.nomeComum,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(e.nomeCientifico,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textoSecundario)),
                const SizedBox(height: 20),
                _Secao(
                  titulo: 'Características',
                  filhos: [
                    _Linha('Temperamento', e.temperamentoTexto),
                    _Linha('Tamanho adulto', e.tamanhoAdulto),
                    _Linha('Peso adulto', e.pesoAdulto),
                    _Linha('Tanque mínimo', e.tanqueMinimo),
                  ],
                ),
                const SizedBox(height: 16),
                _Secao(
                  titulo: 'Faixas ideais',
                  filhos: [
                    _Linha('pH', e.faixaPh),
                    _Linha('Temperatura', e.faixaTemp),
                    _Linha('Grupo', e.grupoHidroquimico ?? '—'),
                  ],
                ),
                const SizedBox(height: 16),
                _Secao(
                  titulo: 'Se o pH sair da faixa',
                  filhos: [
                    if (e.phMax != null)
                      _Corrigir(
                        titulo: 'pH acima de ${e.faixaPh.split(' a ').last}',
                        acima: true,
                      ),
                    if (e.phMin != null)
                      _Corrigir(
                        titulo: 'pH abaixo de ${e.faixaPh.split(' a ').first}',
                        acima: false,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Comprimento padrão: do focinho ao fim do corpo, sem a nadadeira caudal. Total: inclui a cauda. Fontes: FishBase e SeriouslyFish.',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textoSecundario),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.filhos});

  final String titulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaria)),
          const SizedBox(height: 10),
          ...filhos,
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha(this.rotulo, this.valor);

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(rotulo,
                style: const TextStyle(color: AppColors.textoSecundario)),
          ),
          Expanded(
            child: Text(valor,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _Corrigir extends StatelessWidget {
  const _Corrigir({required this.titulo, required this.acima});

  final String titulo;
  final bool acima;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(acima ? 'Como baixar o pH' : 'Como subir o pH'),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [PassosPh(acima: acima)],
      ),
    );
  }
}