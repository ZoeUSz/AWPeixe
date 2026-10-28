package com.piscicultura.piscicultura_api.dto;

import com.piscicultura.piscicultura_api.entity.Alerta;

import java.time.LocalDateTime;
import java.util.UUID;

public record AlertaResponse(
        UUID id,
        String tipo,
        String mensagem,
        boolean resolvido,
        LocalDateTime geradoEm,
        LocalDateTime resolvidoEm) {

    public static AlertaResponse de(Alerta a) {
        return new AlertaResponse(a.getId(), a.getTipo(), a.getMensagem(),
                a.isResolvido(), a.getGeradoEm(), a.getResolvidoEm());
    }
}