package com.piscicultura.piscicultura_api.controller;

import com.piscicultura.piscicultura_api.dto.LeituraRequest;
import com.piscicultura.piscicultura_api.dto.Respostas.LeituraResponse;
import com.piscicultura.piscicultura_api.service.LeituraService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/leituras")
@RequiredArgsConstructor
public class LeituraController {

    private final LeituraService service;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public LeituraResponse registrar(@Valid @RequestBody LeituraRequest req) {
        return service.registrar(req);
    }
}