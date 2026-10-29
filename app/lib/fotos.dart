import 'package:flutter/material.dart';

import 'theme.dart';

// Fotos das espécies (pasta app/assets/especies, declarada no pubspec.yaml).
// A busca aceita o nome científico ou o nome comum, sem diferenciar maiúsculas,
// acentos, espaços ou hífens.
const _pasta = 'assets/especies/';

const Map<String, String> _fotos = {
  'carassiusauratus': 'Kinguio.jpg',
  'kinguio': 'Kinguio.jpg',
  'paracheirodonaxelrodi': 'NeonCardeal.jpg',
  'neoncardeal': 'NeonCardeal.jpg',
  'daniorerio': 'Paulistinha.jpg',
  'paulistinha': 'Paulistinha.jpg',
  'bettasplendens': 'Betta.jpg',
  'betta': 'Betta.jpg',
  'pterophyllumscalare': 'Acarabandeira.jpg',
  'acarabandeira': 'Acarabandeira.jpg',
  'colossomamacropomum': 'Tambaqui.jpg',
  'tambaqui': 'Tambaqui.jpg',
  'poeciliareticulata': 'Guppy.jpg',
  'guppy': 'Guppy.jpg',
  'oreochromisniloticus': 'TilapiadoNilo.jpg',
  'tilapiadonilo': 'TilapiadoNilo.jpg',
  'labidochromiscaeruleus': 'CiclideodoMalawi.jpg',
  'ciclideoamarelodomalawi': 'CiclideodoMalawi.jpg',
  'ciclideodomalawi': 'CiclideodoMalawi.jpg',
};

String _chave(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  var r = s.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], para[i]);
  }
  return r.replaceAll(RegExp(r'[^a-z]'), '');
}

/// Caminho da foto da espécie, ou null se não houver.
String? caminhoFoto(String? nome) {
  if (nome == null) return null;
  final arquivo = _fotos[_chave(nome)];
  return arquivo == null ? null : '$_pasta$arquivo';
}

/// Foto da espécie com recorte uniforme; se faltar a foto, mostra um ícone.
class FotoEspecie extends StatelessWidget {
  const FotoEspecie({
    super.key,
    required this.nomeCientifico,
    required this.nomeComum,
    this.altura = 120,
  });

  final String nomeCientifico;
  final String nomeComum;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final caminho = caminhoFoto(nomeCientifico) ?? caminhoFoto(nomeComum);
    final vazio = Container(
      height: altura,
      width: double.infinity,
      color: AppColors.primariaClara,
      child: const Icon(Icons.set_meal_outlined,
          size: 40, color: AppColors.primaria),
    );
    if (caminho == null) return vazio;
    return SizedBox(
      height: altura,
      width: double.infinity,
      child: Image.asset(
        caminho,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => vazio,
      ),
    );
  }
}