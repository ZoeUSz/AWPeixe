import 'package:flutter/material.dart';

import 'theme.dart';

// Orientações gerais de aquarismo para corrigir o pH manualmente.
// Servem de apoio ao alerta; não substituem a avaliação do responsável técnico.

const List<String> passosPhAcima = [
  'Confirme a leitura com teste de gotas ou fita, pois o sensor pode estar descalibrado.',
  'Faça trocas parciais de água usando água com pH mais baixo (por exemplo, água mole ou de osmose misturada à da torneira), em partes pequenas.',
  'Use materiais que acidificam de forma natural, como troncos ou folhas secas (amendoeira).',
  'Se precisar de produto, use redutor de pH para aquário na dose do rótulo, aos poucos.',
  'Limpe o fundo, retire sobras e meça de novo depois de algumas horas.',
];

const List<String> passosPhAbaixo = [
  'Confirme a leitura com teste de gotas ou fita, pois o sensor pode estar descalibrado.',
  'Faça trocas parciais de água usando água com pH mais alto e mais dura, em partes pequenas.',
  'Coloque cascalho de coral ou calcário no filtro: eleva o pH e a dureza devagar.',
  'Se precisar de produto, use elevador de pH para aquário na dose do rótulo, aos poucos.',
  'Limpe o fundo e retire sobras de comida, que acidificam a água. Meça de novo depois de algumas horas.',
];

const String avisoPh =
    'Corrija aos poucos, ao longo de horas. Mudanças bruscas de pH estressam os peixes e podem ser mais perigosas do que ficar um pouco fora da faixa.';

class PassosPh extends StatelessWidget {
  const PassosPh({super.key, required this.acima});

  final bool acima;

  @override
  Widget build(BuildContext context) {
    final passos = acima ? passosPhAcima : passosPhAbaixo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < passos.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text('${i + 1}.',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoSecundario)),
                ),
                Expanded(child: Text(passos[i])),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          avisoPh,
          style: const TextStyle(
              fontSize: 12.5, color: AppColors.textoSecundario),
        ),
      ],
    );
  }
}