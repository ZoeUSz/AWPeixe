package com.piscicultura.piscicultura_api.dto;

import com.piscicultura.piscicultura_api.entity.Alerta;

import java.time.LocalDateTime;
import java.util.UUID;

public record AlertaResponse(
        UUID id,
        String tipo,
        String especie,
        String mensagem,
        String acao,
        boolean resolvido,
        LocalDateTime geradoEm,
        LocalDateTime resolvidoEm) {

    public static AlertaResponse de(Alerta a) {
        return new AlertaResponse(a.getId(), a.getTipo(), a.getEspecieNome(),
                a.getMensagem(), a.getAcao(), a.isResolvido(),
                a.getGeradoEm(), a.getResolvidoEm());
    }
}