import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models/especie.dart';

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

  Future<dynamic> _get(String caminho, [Map<String, String>? query]) async {
    final uri = Uri.parse('$apiBaseUrl$caminho').replace(queryParameters: query);
    http.Response resp;
    try {
      resp = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      throw ApiException('Não consegui falar com a API em $apiBaseUrl');
    }
    if (resp.statusCode == 401) {
      throw ApiException('Usuário ou senha da API incorretos (401)');
    }
    if (resp.statusCode != 200) {
      throw ApiException('Erro da API (${resp.statusCode})');
    }
    return jsonDecode(utf8.decode(resp.bodyBytes));
  }

  Future<List<Especie>> fetchEspecies({String? grupo}) async {
    final dados = await _get(
      '/especies',
      grupo == null ? null : {'grupo': grupo},
    ) as List<dynamic>;
    return dados
        .map((e) => Especie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchGrupos() async {
    final dados = await _get('/especies/grupos') as List<dynamic>;
    return dados.map((e) => e.toString()).toList();
  }
}