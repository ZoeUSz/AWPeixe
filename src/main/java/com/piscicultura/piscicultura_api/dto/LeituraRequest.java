package com.piscicultura.piscicultura_api.dto;

import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.UUID;

public record LeituraRequest(
        @NotNull UUID sensorId,
        @NotNull BigDecimal valor) {
}
