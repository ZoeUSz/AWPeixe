package com.piscicultura.piscicultura_api.controller;

import com.piscicultura.piscicultura_api.dto.EspecieTanqueRequest;
import com.piscicultura.piscicultura_api.dto.Respostas.StatusTanqueResponse;
import com.piscicultura.piscicultura_api.dto.Respostas.TanqueResponse;
import com.piscicultura.piscicultura_api.service.TanqueService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/tanques")
@RequiredArgsConstructor
public class TanqueController {

    private final TanqueService service;

    @GetMapping
    public List<TanqueResponse> listar() {
        return service.listar();
    }

    @PutMapping("/{id}/especie")
    public TanqueResponse definirEspecie(@PathVariable UUID id,
            @Valid @RequestBody EspecieTanqueRequest req) {
        return service.definirEspecie(id, req.especieId());
    }

    @GetMapping("/{id}/status")
    public StatusTanqueResponse status(@PathVariable UUID id) {
        return service.status(id);
    }
}