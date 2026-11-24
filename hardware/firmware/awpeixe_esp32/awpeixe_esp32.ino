// =========================================================
// AWPeixe - FIRMWARE DO ESP32
// Lê temperatura (DS18B20) e pH (vindo do Mega pela Serial2),
// envia para a API, controla aquecedor e fan pela faixa da
// espécie do tanque e aciona o alimentador (motor de passo),
// registrando cada alimentação na API.
//
// Bibliotecas (Gerenciar Bibliotecas na Arduino IDE):
//   OneWire, DallasTemperature, ArduinoJson (versão 7)
// Placa: ESP32 Dev Module
// Monitor Serial: 115200  |  comando "a" = alimentar agora
// =========================================================
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "segredos.h"

// ---------------------------------------------------------
// IDs do banco (os mesmos do simulador.py)
// ---------------------------------------------------------
const char* TANQUE_ID          = "00000000-0000-0000-0000-000000000002";
const char* SENSOR_TEMPERATURA = "00000000-0000-0000-0000-000000000011";
const char* SENSOR_PH          = "00000000-0000-0000-0000-000000000012";

// ---------------------------------------------------------
// 1. SENSOR DE TEMPERATURA (DS18B20 - GPIO 4)
// ---------------------------------------------------------
const int PINO_ONEWIRE = 4;
OneWire oneWire(PINO_ONEWIRE);
DallasTemperature sensors(&oneWire);

const unsigned long INTERVALO_TEMP = 5000;   // lê a cada 5 s
unsigned long tempoAnteriorTemp = 0;
bool aguardandoConversaoTemp = false;
float temperaturaAtual = 0.0;
bool temperaturaValida = false;
unsigned long ultimaTempValidaMs = 0;

// ---------------------------------------------------------
// 2. pH RECEBIDO DO MEGA (Serial2, RX2 - GPIO 16)
// ---------------------------------------------------------
const int PINO_RX2 = 16;
String bufferSerialPH = "";
float phAtual = 0.0;
bool phValido = false;
unsigned long ultimoPhMs = 0;
const unsigned long VALIDADE_PH = 15000;     // pH mais velho que 15 s não é enviado

// ---------------------------------------------------------
// 3. ALIMENTADOR (28BYJ-48 + ULN2003)
// ---------------------------------------------------------
const int IN1_MOTOR = 19;
const int IN2_MOTOR = 18;
const int IN3_MOTOR = 5;
const int IN4_MOTOR = 17;

const int passos[4][4] = {
  {1, 0, 0, 0},
  {0, 1, 0, 0},
  {0, 0, 1, 0},
  {0, 0, 0, 1}
};

// Alimenta a cada 15 s enquanto o tanque tiver uma espécie escolhida no app.
// Para deixar rodando gerando dados, aumente (ex.: 4 h = 4UL * 60 * 60 * 1000).
const unsigned long INTERVALO_ALIMENTACAO = 15UL * 1000;
const int PORCOES_POR_ALIMENTACAO = 1;       // 1 porção = 1 volta do motor
const int PASSOS_POR_VOLTA = 2048;
const unsigned long INTERVALO_PASSO_US = 3000;

unsigned long tempoAnteriorCicloRacao = 0;
unsigned long tempoUltimoPasso = 0;
int passosRestantes = 0;
int indiceFaseAtual = 0;
int porcoesEmAndamento = 0;
int porcoesPendentesEnvio = 0;               // alimentação feita mas ainda não registrada na API

// ---------------------------------------------------------
// 4. RELÉS (ativos em LOW) - CONFIRA QUAL APARELHO ESTÁ EM CADA UM
// ---------------------------------------------------------
const int PINO_RELE_AQUECEDOR = 26;          // IN2 (conferido na bancada em 23/11)
const int PINO_RELE_FAN       = 27;          // IN1

bool aquecedorLigado = false;
bool fanLigada = false;
const float FOLGA = 0.5;                     // histerese em °C

// Faixa usada se a API ainda não respondeu
float tempMin = 24.0;
float tempMax = 28.0;
float phMin = 6.5;
float phMax = 8.5;

// ---------------------------------------------------------
// 5. REDE E API
// ---------------------------------------------------------
const unsigned long INTERVALO_ENVIO = 5000;      // envia leituras a cada 5 s
const unsigned long INTERVALO_FAIXAS = 10000;    // busca a faixa da espécie a cada 10 s
const unsigned long INTERVALO_RECONEXAO = 10000;
unsigned long tempoAnteriorEnvio = 0;
unsigned long tempoAnteriorFaixas = 0;
unsigned long tempoAnteriorReconexao = 0;
bool faixasCarregadas = false;
bool temEspecie = false;                     // só alimenta sozinho se o tanque tiver espécie
String especieAtual = "";

// =========================================================
// RELÉS
// =========================================================
void rele(int pino, bool ligar) {
  digitalWrite(pino, ligar ? LOW : HIGH);
}

// =========================================================
// WI-FI
// =========================================================
void conectarWiFi() {
  Serial.print("[WIFI] Conectando em ");
  Serial.println(WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_SENHA);

  unsigned long inicio = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - inicio < 15000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("[WIFI] Conectado. IP do ESP32: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("[WIFI] Sem conexão. O controle local continua; tento de novo depois.");
  }
}

void manterWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;
  if (millis() - tempoAnteriorReconexao < INTERVALO_RECONEXAO) return;
  tempoAnteriorReconexao = millis();
  Serial.println("[WIFI] Reconectando...");
  WiFi.disconnect();
  WiFi.begin(WIFI_SSID, WIFI_SENHA);
}

// =========================================================
// API
// =========================================================
int postJson(const String& rota, const String& corpo) {
  HTTPClient http;
  http.setTimeout(4000);
  http.begin(String(API_URL) + rota);
  http.setAuthorization(API_USUARIO, API_SENHA);
  http.addHeader("Content-Type", "application/json");
  int codigo = http.POST(corpo);
  http.end();
  return codigo;
}

void enviarLeitura(const char* sensorId, float valor, const char* nome) {
  String corpo = String("{\"sensorId\":\"") + sensorId + "\",\"valor\":" + String(valor, 2) + "}";
  int codigo = postJson("/leituras", corpo);
  Serial.printf("[API] %s %.2f -> HTTP %d\n", nome, valor, codigo);
  if (codigo == 401) Serial.println("[API] Usuário/senha recusados: confira o segredos.h");
}

bool registrarAlimentacao(int porcoes) {
  String corpo = String("{\"tanqueId\":\"") + TANQUE_ID + "\",\"porcoes\":" + porcoes + "}";
  int codigo = postJson("/alimentacoes", corpo);
  Serial.printf("[API] Alimentação de %d porção(ões) -> HTTP %d\n", porcoes, codigo);
  return codigo >= 200 && codigo < 300;
}

void buscarFaixas() {
  HTTPClient http;
  http.setTimeout(4000);
  http.begin(String(API_URL) + "/tanques/" + TANQUE_ID + "/status");
  http.setAuthorization(API_USUARIO, API_SENHA);
  int codigo = http.GET();

  if (codigo != 200) {
    Serial.printf("[API] Faixa da espécie indisponível (HTTP %d). Mantendo %.1f a %.1f °C\n",
                  codigo, tempMin, tempMax);
    http.end();
    return;
  }

  String resposta = http.getString();
  http.end();

  JsonDocument doc;
  if (deserializeJson(doc, resposta)) {
    Serial.println("[API] Resposta do status inválida.");
    return;
  }

  float minAntes = tempMin;
  float maxAntes = tempMax;

  // Espécie do tanque: pode vir como texto ou como objeto, ou nula
  JsonVariant e = doc["especie"];
  String nomeEspecie = "";
  if (e.is<const char*>()) {
    nomeEspecie = e.as<const char*>();
  } else if (e.is<JsonObject>()) {
    const char* nc = e["nomeComum"];
    nomeEspecie = nc ? nc : "espécie definida";
  }
  bool tinhaEspecie = temEspecie;
  temEspecie = nomeEspecie.length() > 0;

  if (nomeEspecie != especieAtual) {
    especieAtual = nomeEspecie;
    if (temEspecie) {
      Serial.printf("[API] Espécie do tanque: %s -> alimentador ativo (a cada %lu s)\n",
                    especieAtual.c_str(), INTERVALO_ALIMENTACAO / 1000);
      // Primeira dosagem logo após escolher a espécie
      tempoAnteriorCicloRacao = millis() - INTERVALO_ALIMENTACAO;
    } else if (tinhaEspecie) {
      Serial.println("[API] Tanque sem espécie -> alimentador e controle de temperatura parados");
    }
  }
  if (temEspecie != tinhaEspecie) controlarTemperatura();

  for (JsonObject p : doc["parametros"].as<JsonArray>()) {
    if (p["min"].isNull() || p["max"].isNull()) continue;
    const char* tipo = p["tipo"];
    if (tipo == nullptr) continue;
    if (strcmp(tipo, "TEMPERATURA") == 0) {
      tempMin = p["min"].as<float>();
      tempMax = p["max"].as<float>();
    } else if (strcmp(tipo, "PH") == 0) {
      phMin = p["min"].as<float>();
      phMax = p["max"].as<float>();
    }
  }

  bool mudou = (tempMin != minAntes) || (tempMax != maxAntes);
  if (!faixasCarregadas || mudou) {
    Serial.printf("[API] Faixa da espécie: temperatura %.1f a %.1f °C | pH %.1f a %.1f\n",
                  tempMin, tempMax, phMin, phMax);
  }
  faixasCarregadas = true;

  // Espécie trocada no app: reavalia os relés na hora, sem esperar a próxima leitura
  if (mudou) controlarTemperatura();
}

// =========================================================
// SENSORES
// =========================================================
void atualizarLeituraPH() {
  while (Serial2.available() > 0) {
    char c = (char)Serial2.read();

    if (c == '\n') {
      bufferSerialPH.trim();
      if (bufferSerialPH.startsWith("PH:")) bufferSerialPH.remove(0, 3);
      if (bufferSerialPH.length() > 0) {
        float valor = bufferSerialPH.toFloat();
        if (valor > 0.0 && valor < 14.0) {
          phAtual = valor;
          phValido = true;
          ultimoPhMs = millis();
          Serial.printf("[pH - MEGA] %.2f\n", phAtual);
        } else {
          Serial.printf("[pH - MEGA] Valor descartado: %s\n", bufferSerialPH.c_str());
        }
      }
      bufferSerialPH = "";
    } else if (c != '\r') {
      bufferSerialPH += c;
      if (bufferSerialPH.length() > 20) bufferSerialPH = "";   // lixo na linha
    }
  }
}

void atualizarTemperatura() {
  unsigned long agoraMs = millis();

  if (!aguardandoConversaoTemp && (agoraMs - tempoAnteriorTemp >= INTERVALO_TEMP)) {
    sensors.requestTemperatures();
    tempoAnteriorTemp = agoraMs;
    aguardandoConversaoTemp = true;
  }

  if (aguardandoConversaoTemp && (agoraMs - tempoAnteriorTemp >= 750)) {
    float tempC = sensors.getTempCByIndex(0);
    aguardandoConversaoTemp = false;

    // -127 = sensor desconectado | 85 = leitura falsa de partida
    if (tempC == DEVICE_DISCONNECTED_C || tempC == 85.0 || tempC < -10.0 || tempC > 60.0) {
      temperaturaValida = false;
      Serial.println("[TEMPERATURA] ERRO (verifique fios / resistor 4.7k) - nada é enviado");
    } else {
      temperaturaAtual = tempC;
      temperaturaValida = true;
      ultimaTempValidaMs = agoraMs;
      Serial.printf("[TEMPERATURA] %.2f °C\n", temperaturaAtual);
    }
    controlarTemperatura();
  }
}

// =========================================================
// CONTROLE EM MALHA FECHADA (aquecedor e fan)
// =========================================================
void controlarTemperatura() {
  if (!temEspecie) {
    // Tanque sem espécie: não há faixa para comparar, aquecedor e fan ficam desligados
    if (aquecedorLigado || fanLigada) Serial.println("[CONTROLE] Tanque sem espécie: aquecedor e fan desligados");
    aquecedorLigado = false;
    fanLigada = false;
  } else if (!temperaturaValida) {
    // Sem leitura confiável: desliga tudo por segurança
    if (aquecedorLigado || fanLigada) Serial.println("[CONTROLE] Sensor sem leitura: aquecedor e fan desligados");
    aquecedorLigado = false;
    fanLigada = false;
  } else {
    bool aquecedorAntes = aquecedorLigado;
    bool fanAntes = fanLigada;

    if (!aquecedorLigado && temperaturaAtual < tempMin) aquecedorLigado = true;
    if (aquecedorLigado && temperaturaAtual >= tempMin + FOLGA) aquecedorLigado = false;

    if (!fanLigada && temperaturaAtual > tempMax) fanLigada = true;
    if (fanLigada && temperaturaAtual <= tempMax - FOLGA) fanLigada = false;

    // Nunca os dois juntos: água abaixo do mínimo desliga a fan,
    // água acima do máximo desliga o aquecedor
    if (temperaturaAtual < tempMin) fanLigada = false;
    if (temperaturaAtual > tempMax) aquecedorLigado = false;

    if (aquecedorLigado != aquecedorAntes)
      Serial.printf("[CONTROLE] Aquecedor %s (%.2f °C, faixa %.1f a %.1f)\n",
                    aquecedorLigado ? "LIGADO" : "desligado", temperaturaAtual, tempMin, tempMax);
    if (fanLigada != fanAntes)
      Serial.printf("[CONTROLE] Fan %s (%.2f °C, faixa %.1f a %.1f)\n",
                    fanLigada ? "LIGADA" : "desligada", temperaturaAtual, tempMin, tempMax);
  }

  rele(PINO_RELE_AQUECEDOR, aquecedorLigado);
  rele(PINO_RELE_FAN, fanLigada);
}

// =========================================================
// ALIMENTADOR
// =========================================================
void desligarBobinas() {
  digitalWrite(IN1_MOTOR, LOW);
  digitalWrite(IN2_MOTOR, LOW);
  digitalWrite(IN3_MOTOR, LOW);
  digitalWrite(IN4_MOTOR, LOW);
}

void iniciarAlimentacao(int porcoes) {
  if (passosRestantes > 0) return;           // já está girando
  porcoesEmAndamento = porcoes;
  passosRestantes = PASSOS_POR_VOLTA * porcoes;
  Serial.printf(">> [ALIMENTADOR] Iniciando dosagem (%d volta(s))...\n", porcoes);
}

void atualizarAlimentador() {
  unsigned long agoraMs = millis();
  unsigned long agoraUs = micros();

  if (temEspecie && passosRestantes == 0 && (agoraMs - tempoAnteriorCicloRacao >= INTERVALO_ALIMENTACAO)) {
    tempoAnteriorCicloRacao = agoraMs;
    iniciarAlimentacao(PORCOES_POR_ALIMENTACAO);
  }

  if (passosRestantes > 0 && (agoraUs - tempoUltimoPasso >= INTERVALO_PASSO_US)) {
    tempoUltimoPasso = agoraUs;

    digitalWrite(IN1_MOTOR, passos[indiceFaseAtual][0]);
    digitalWrite(IN2_MOTOR, passos[indiceFaseAtual][1]);
    digitalWrite(IN3_MOTOR, passos[indiceFaseAtual][2]);
    digitalWrite(IN4_MOTOR, passos[indiceFaseAtual][3]);

    indiceFaseAtual = (indiceFaseAtual + 1) % 4;
    passosRestantes--;

    if (passosRestantes == 0) {
      desligarBobinas();
      tempoAnteriorCicloRacao = millis();
      porcoesPendentesEnvio += porcoesEmAndamento;
      porcoesEmAndamento = 0;
      Serial.println(">> [ALIMENTADOR] Dosagem concluída! Bobinas desligadas.");
    }
  }
}

// =========================================================
// ENVIO PERIÓDICO PARA A API
// =========================================================
void comunicarComAPI() {
  // Nada de rede enquanto o motor gira: o HTTP trava o loop e o motor engasga
  if (passosRestantes > 0) return;
  if (WiFi.status() != WL_CONNECTED) return;

  unsigned long agora = millis();

  if (!faixasCarregadas || agora - tempoAnteriorFaixas >= INTERVALO_FAIXAS) {
    tempoAnteriorFaixas = agora;
    buscarFaixas();
  }

  if (agora - tempoAnteriorEnvio >= INTERVALO_ENVIO) {
    tempoAnteriorEnvio = agora;

    if (temperaturaValida && agora - ultimaTempValidaMs < 2 * INTERVALO_TEMP) {
      enviarLeitura(SENSOR_TEMPERATURA, temperaturaAtual, "Temperatura");
    }
    if (phValido && agora - ultimoPhMs < VALIDADE_PH) {
      enviarLeitura(SENSOR_PH, phAtual, "pH");
    }

    if (porcoesPendentesEnvio > 0 && registrarAlimentacao(porcoesPendentesEnvio)) {
      porcoesPendentesEnvio = 0;
    }
  }
}

// =========================================================
// COMANDOS PELO MONITOR SERIAL
// =========================================================
void lerComandos() {
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c == 'a' || c == 'A') {
      Serial.println("[COMANDO] Alimentação manual");
      iniciarAlimentacao(PORCOES_POR_ALIMENTACAO);
    }
  }
}

// =========================================================
void setup() {
  Serial.begin(115200);

  pinMode(PINO_RELE_AQUECEDOR, OUTPUT);
  pinMode(PINO_RELE_FAN, OUTPUT);
  rele(PINO_RELE_AQUECEDOR, false);
  rele(PINO_RELE_FAN, false);

  pinMode(IN1_MOTOR, OUTPUT);
  pinMode(IN2_MOTOR, OUTPUT);
  pinMode(IN3_MOTOR, OUTPUT);
  pinMode(IN4_MOTOR, OUTPUT);
  desligarBobinas();

  Serial2.begin(9600, SERIAL_8N1, PINO_RX2, -1);

  sensors.begin();
  sensors.setWaitForConversion(false);

  delay(500);
  Serial.println("=========================================================");
  Serial.println("  AWPeixe - ESP32 | comando 'a' = alimentar agora");
  Serial.println("=========================================================");

  conectarWiFi();

  // Primeira alimentação só depois de um intervalo completo
  tempoAnteriorCicloRacao = millis();
}

void loop() {
  lerComandos();
  atualizarLeituraPH();
  atualizarTemperatura();
  atualizarAlimentador();
  manterWiFi();
  comunicarComAPI();
}