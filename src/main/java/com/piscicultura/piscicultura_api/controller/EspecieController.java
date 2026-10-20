package com.piscicultura.piscicultura_api.controller;

import com.piscicultura.piscicultura_api.entity.Especie;
import com.piscicultura.piscicultura_api.repository.EspecieRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/especies")
public class EspecieController {

    private final EspecieRepository especieRepository;

    public EspecieController(EspecieRepository especieRepository) {
        this.especieRepository = especieRepository;
    }

    // GET /especies ou GET /especies?grupo=Tropical Neutro
    @GetMapping
    public List<Especie> listar(@RequestParam(required = false) String grupo) {
        if (grupo != null && !grupo.isBlank()) {
            return especieRepository.findByGrupoHidroquimicoIgnoreCase(grupo);
        }
        return especieRepository.findAll();
    }

    // GET /especies/grupos
    @GetMapping("/grupos")
    public List<String> listarGrupos() {
        return especieRepository.findGruposDistintos();
    }

    // GET /especies/{id}
    @GetMapping("/{id}")
    public ResponseEntity<Especie> buscarPorId(@PathVariable UUID id) {
        return especieRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}