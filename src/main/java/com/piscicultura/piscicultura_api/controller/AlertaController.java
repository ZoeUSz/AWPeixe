package com.piscicultura.piscicultura_api.controller;

import com.piscicultura.piscicultura_api.dto.AlertaResponse;
import com.piscicultura.piscicultura_api.repository.AlertaRepository;
import com.piscicultura.piscicultura_api.repository.TanqueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/tanques")
@RequiredArgsConstructor
public class AlertaController {

    private static final int MAX_ALERTAS = 200;

    private final AlertaRepository alertas;
    private final TanqueRepository tanques;

    @GetMapping("/{tanqueId}/alertas")
    public List<AlertaResponse> listar(@PathVariable UUID tanqueId,
            @RequestParam(defaultValue = "50") int limite) {
        if (!tanques.existsById(tanqueId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tanque não encontrado");
        }
        int n = Math.max(1, Math.min(limite, MAX_ALERTAS));
        return alertas
                .findByTanqueIdOrderByResolvidoAscGeradoEmDesc(tanqueId, PageRequest.of(0, n))
                .stream()
                .map(AlertaResponse::de)
                .toList();
    }
}