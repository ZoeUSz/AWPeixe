// =========================================================
// AWPeixe - ARDUINO MEGA 2560: LEITURA DE pH
// Lê o módulo PH-4502C no A0 e envia o pH para o ESP32
// pela Serial1 (pino 18 -> divisor -> GPIO 16 do ESP32).
// Monitor Serial: 115200
// =========================================================
const int PINO_PH = A0;

// false = leitura REAL da sonda (use na apresentação e na coleta de dados)
// true  = valor simulado (~7.02), só para testar a comunicação
const bool MODO_SIMULACAO_AQUARIO = false;

// ---------------------------------------------------------
// CALIBRAÇÃO (dois pontos)
// 1. Sonda na solução pH 7: anote a "Tensao" do Monitor Serial
// 2. Lave a sonda, coloque na solução pH 4: anote a tensão
// 3. Preencha os dois valores abaixo e grave de novo
// Os valores atuais reproduzem a fórmula que vocês já usavam
// (3,40 V = pH 7 e 3,5 pH por volt).
// ---------------------------------------------------------
float V_PH7 = 3.40;
float V_PH4 = 4.257;

unsigned long tempoAnteriorEnvio = 0;
const unsigned long INTERVALO_ENVIO = 5000;   // envia a cada 5 s

void setup() {
  Serial.begin(115200);
  Serial1.begin(9600);
  randomSeed(analogRead(A1));

  Serial.println("=========================================");
  Serial.println("  MEGA: TRANSMISSOR pH (A CADA 5s)       ");
  Serial.println(MODO_SIMULACAO_AQUARIO ? "  MODO: SIMULACAO" : "  MODO: LEITURA REAL");
  Serial.println("=========================================");
}

// Mediana aparada: 10 amostras, descarta as 2 menores e as 2 maiores
float lerTensao() {
  int amostras[10];

  for (int i = 0; i < 10; i++) {
    amostras[i] = analogRead(PINO_PH);
    delay(10);
  }

  for (int i = 0; i < 9; i++) {
    for (int j = i + 1; j < 10; j++) {
      if (amostras[i] > amostras[j]) {
        int temp = amostras[i];
        amostras[i] = amostras[j];
        amostras[j] = temp;
      }
    }
  }

  unsigned long soma = 0;
  for (int i = 2; i < 8; i++) {
    soma += amostras[i];
  }

  return (soma / 6.0) * (5.0 / 1024.0);
}

float converterParaPH(float tensao) {
  float inclinacao = (7.0 - 4.0) / (V_PH7 - V_PH4);
  float ph = 7.0 + (tensao - V_PH7) * inclinacao;
  return constrain(ph, 0.0, 14.0);
}

void loop() {
  unsigned long agora = millis();

  if (agora - tempoAnteriorEnvio >= INTERVALO_ENVIO) {
    tempoAnteriorEnvio = agora;

    float tensao = lerTensao();
    float valorPH;

    if (MODO_SIMULACAO_AQUARIO) {
      valorPH = 7.02 + random(-8, 9) / 100.0;
    } else {
      valorPH = converterParaPH(tensao);
    }

    Serial1.println(valorPH, 2);

    Serial.print("[MEGA -> ESP32] Tensao: ");
    Serial.print(tensao, 3);
    Serial.print(" V | pH enviado: ");
    Serial.println(valorPH, 2);
  }
}
