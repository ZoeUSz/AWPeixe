package com.piscicultura.piscicultura_api.dto;

import com.piscicultura.piscicultura_api.entity.Alimentacao;

import java.time.LocalDateTime;
import java.util.UUID;

public record AlimentacaoResponse(
        UUID id,
        UUID tanqueId,
        String origem,
        Integer porcoes,
        String especie,
        LocalDateTime registradoEm) {

    public static AlimentacaoResponse de(Alimentacao a) {
        return new AlimentacaoResponse(a.getId(), a.getTanque().getId(),
                a.getOrigem(), a.getPorcoes(), a.getEspecieNome(),
                a.getRegistradoEm());
    }
}