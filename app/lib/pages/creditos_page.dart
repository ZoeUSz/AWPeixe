import 'package:flutter/material.dart';

import '../theme.dart';

// Créditos das fotos das espécies (Wikimedia Commons).
// Mantenha esta lista igual a assets/especies/CREDITOS.md.
class _Credito {
  const _Credito(this.especie, this.cientifico, this.autor, this.licenca, this.link);

  final String especie;
  final String cientifico;
  final String autor;
  final String licenca;
  final String link;
}

const _commons = 'https://commons.wikimedia.org/wiki/File:';

const _creditos = [
  _Credito('Neon cardeal', 'Paracheirodon axelrodi', 'CHUCAO', 'CC BY-SA 3.0',
      '${_commons}Cardinal_Paracheirodon_axelrodi_(1).jpg'),
  _Credito(
      'Kinguio',
      'Carassius auratus',
      'Duane Raver, U.S. Fish and Wildlife Service',
      'Domínio público',
      '${_commons}Goldfish_carassius_auratus.jpg'),
  _Credito('Paulistinha', 'Danio rerio', 'Pogrebnoj-Alexandroff',
      'CC BY-SA 3.0', '${_commons}Danio_rerio.JPG'),
  _Credito('Betta', 'Betta splendens', 'Denise Chan', 'CC BY-SA 2.0',
      '${_commons}Betta-splendens-male.jpg'),
  _Credito(
      'Acará-bandeira',
      'Pterophyllum scalare',
      'James St. John',
      'CC BY 2.0',
      '${_commons}Pterophyllum_scalare_(freshwater_angelfish)_3_(15533329809).jpg'),
  _Credito('Tambaqui', 'Colossoma macropomum', 'Bloopityboop', 'CC BY-SA 4.0',
      '${_commons}Tambaqui_(Colossoma_macropomum).jpg'),
  _Credito('Guppy', 'Poecilia reticulata', 'Przemysław Malkowski',
      'CC BY-SA 3.0', '${_commons}Guppy_red_male.jpg'),
  _Credito('Tilápia-do-Nilo', 'Oreochromis niloticus',
      'Bjørn Christian Tørrissen', 'CC BY-SA 3.0',
      '${_commons}Oreochromis-niloticus-Nairobi.JPG'),
  _Credito('Ciclídeo amarelo do Malawi', 'Labidochromis caeruleus',
      'Theatrus (Wikipédia em inglês)', 'CC BY-SA 3.0 e GFDL',
      '${_commons}Electric_Yellow_Lab_Cichlid.jpg'),
];

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos das imagens',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borda),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'As fotos das espécies vêm do Wikimedia Commons, sob licenças '
                  'livres, e foram recortadas para caber nos cards. Selecione o '
                  'link para copiá-lo.',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
                const SizedBox(height: 16),
                for (final c in _creditos) _CreditoCard(c),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreditoCard extends StatelessWidget {
  const _CreditoCard(this.c);

  final _Credito c;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.especie,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(c.cientifico,
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textoSecundario)),
            const SizedBox(height: 8),
            Text('Autor: ${c.autor}'),
            Text('Licença: ${c.licenca}'),
            const SizedBox(height: 4),
            SelectableText(
              c.link,
              style: const TextStyle(fontSize: 12, color: AppColors.primaria),
            ),
          ],
        ),
      ),
      ),
    );
  }
}