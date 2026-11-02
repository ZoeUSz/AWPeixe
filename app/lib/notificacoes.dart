import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'models/alerta.dart';
import 'models/alimentacao.dart';

// Notificações do AWPeixe (aparecem na barra do celular, como uma mensagem).
// Funcionam enquanto o app está aberto ou minimizado: quem detecta o evento
// novo é a consulta que o monitoramento faz na API a cada 3 segundos.
class Notificacoes {
  Notificacoes._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _pronto = false;

  // Dois canais: o usuário pode silenciar um sem silenciar o outro
  // (Configurações > Apps > AWPeixe > Notificações).
  // O texto longo (mensagem + ação) aparece inteiro ao expandir a notificação.
  static AndroidNotificationDetails _canalAlertas(String texto) =>
      AndroidNotificationDetails(
        'alertas',
        'Alertas da água',
        channelDescription: 'Temperatura ou pH fora da faixa da espécie',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(texto),
      );

  static const _canalAlimentacao = AndroidNotificationDetails(
    'alimentacao',
    'Alimentação',
    channelDescription: 'Quando o dispenser solta comida',
    importance: Importance.high,
    priority: Priority.high,
  );

  // Chamado uma vez, no main(). Se a plataforma não suportar, o app segue
  // funcionando normalmente, só sem notificações.
  static Future<void> iniciar() async {
    try {
      const config = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
      );
      await _plugin.initialize(config);
      _pronto = true;
    } catch (e) {
      debugPrint('Notificações indisponíveis: $e');
    }
  }

  // Android 13 ou mais novo: pede a permissão de mostrar notificações.
  static Future<void> pedirPermissao() async {
    if (!_pronto) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Permissão de notificação: $e');
    }
  }

  static Future<void> alerta(Alerta a) async {
    final titulo = a.tipo.startsWith('TEMPERATURA')
        ? 'AWPeixe · Alerta de temperatura'
        : 'AWPeixe · Alerta de pH';
    final acao = (a.acao == null || a.acao!.isEmpty) ? '' : '\nAção: ${a.acao}';
    final texto = '${a.mensagem}$acao';
    await _mostrar(a.id, titulo, texto, _canalAlertas(texto));
  }

  static Future<void> alimentacao(Alimentacao al) async {
    await _mostrar(al.id, 'AWPeixe · Alimentação',
        'O dispenser soltou comida: ${al.detalhe}', _canalAlimentacao);
  }

  static Future<void> _mostrar(String chave, String titulo, String texto,
      AndroidNotificationDetails android) async {
    if (!_pronto) return;
    try {
      await _plugin.show(
        chave.hashCode & 0x7fffffff,
        titulo,
        texto,
        NotificationDetails(android: android),
      );
    } catch (e) {
      debugPrint('Falha ao notificar: $e');
    }
  }
}