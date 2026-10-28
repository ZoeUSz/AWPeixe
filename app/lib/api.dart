import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models/especie.dart';
import 'models/historico.dart';
import 'models/status_tanque.dart';
import 'models/tanque.dart';

class ApiException implements Exception {
  ApiException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$apiUser:$apiPass'))}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Future<dynamic> _enviar(
    String metodo,
    String caminho, {
    Map<String, String>? query,
    Object? corpo,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$caminho').replace(queryParameters: query);
    final req = http.Request(metodo, uri)..headers.addAll(_headers);
    if (corpo != null) req.body = jsonEncode(corpo);

    http.Response resp;
    try {
      final streamed =
          await _client.send(req).timeout(const Duration(seconds: 8));
      resp = await http.Response.fromStream(streamed);
    } catch (_) {
      throw ApiException('Não consegui falar com a API em $apiBaseUrl');
    }

    if (resp.statusCode == 401) {
      throw ApiException('Usuário ou senha da API incorretos (401)');
    }
    if (resp.statusCode == 404) {
      throw ApiException('Item não encontrado na API (404)');
    }
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException('Erro da API (${resp.statusCode})');
    }
    return jsonDecode(utf8.decode(resp.bodyBytes));
  }

  Future<List<Especie>> fetchEspecies({String? grupo}) async {
    final dados = await _enviar(
      'GET',
      '/especies',
      query: grupo == null ? null : {'grupo': grupo},
    ) as List<dynamic>;
    return dados
        .map((e) => Especie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchGrupos() async {
    final dados = await _enviar('GET', '/especies/grupos') as List<dynamic>;
    return dados.map((e) => e.toString()).toList();
  }

  Future<Tanque> fetchTanque(String id) async {
    final dados = await _enviar('GET', '/tanques') as List<dynamic>;
    for (final t in dados) {
      final tanque = Tanque.fromJson(t as Map<String, dynamic>);
      if (tanque.id == id) return tanque;
    }
    throw ApiException('Tanque não encontrado');
  }

  Future<Tanque> definirEspecie(String tanqueId, String especieId) async {
    final dados = await _enviar(
      'PUT',
      '/tanques/$tanqueId/especie',
      corpo: {'especieId': especieId},
    );
    return Tanque.fromJson(dados as Map<String, dynamic>);
  }

  Future<StatusTanque> fetchStatus(String tanqueId) async {
    final dados = await _enviar('GET', '/tanques/$tanqueId/status');
    return StatusTanque.fromJson(dados as Map<String, dynamic>);
  }

  Future<Historico> fetchHistorico(String tanqueId, {int pontos = 60}) async {
    final dados = await _enviar(
      'GET',
      '/tanques/$tanqueId/historico',
      query: {'pontos': '$pontos'},
    );
    return Historico.fromJson(dados as Map<String, dynamic>);
  }
}
