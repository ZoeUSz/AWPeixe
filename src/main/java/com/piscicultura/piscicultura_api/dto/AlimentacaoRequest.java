package com.piscicultura.piscicultura_api.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;

import java.util.UUID;

/**
 * Corpo do POST /alimentacoes enviado pelo ESP32 quando o dispenser solta comida.
 * Só tanqueId é obrigatório; porções e origem são opcionais.
 * O horário é o do servidor (o ESP32 não precisa de relógio).
 */
public record AlimentacaoRequest(
        @NotNull UUID tanqueId,
        @Positive Integer porcoes,
        @Pattern(regexp = "AUTOMATICA|MANUAL") String origem) {
}
