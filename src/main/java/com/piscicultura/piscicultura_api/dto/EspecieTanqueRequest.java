package com.piscicultura.piscicultura_api.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record EspecieTanqueRequest(@NotNull UUID especieId) {
}