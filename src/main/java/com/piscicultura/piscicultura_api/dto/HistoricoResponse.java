
package com.piscicultura.piscicultura_api.dto;

import java.util.List;
import java.util.UUID;

public record HistoricoResponse(
        UUID tanqueId,
        List<Ponto> temperatura,
        List<Ponto> ph) {

    public record Ponto(String em, Number valor) {
    }
}