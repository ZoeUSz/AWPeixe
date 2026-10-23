package com.piscicultura.piscicultura_api.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public final class Respostas {

    private Respostas() {
    }

    public record LeituraResponse(
            UUID id, UUID sensorId, String tipo,
            BigDecimal valor, LocalDateTime registradoEm) {
    }

    public record TanqueResponse(
            UUID id, String nome, BigDecimal capacidadeLitros,
            UUID especieId, String especieNome) {
    }

    // situacao: OK, ABAIXO, ACIMA, SEM_FAIXA, SEM_LEITURA ou SEM_SENSOR
    public record ParametroStatus(
            String tipo, String unidade, BigDecimal valor,
            BigDecimal min, BigDecimal max,
            String situacao, LocalDateTime registradoEm) {
    }

    // statusGeral: OK, ALERTA, SEM_ESPECIE ou SEM_DADOS
    public record StatusTanqueResponse(
            UUID tanqueId, String tanque,
            UUID especieId, String especie,
            String statusGeral, List<ParametroStatus> parametros) {
    }
}