package com.piscicultura.piscicultura_api.controller;

import com.piscicultura.piscicultura_api.dto.AlimentacaoRequest;
import com.piscicultura.piscicultura_api.dto.AlimentacaoResponse;
import com.piscicultura.piscicultura_api.entity.Alimentacao;
import com.piscicultura.piscicultura_api.entity.Tanque;
import com.piscicultura.piscicultura_api.repository.AlimentacaoRepository;
import com.piscicultura.piscicultura_api.repository.TanqueRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class AlimentacaoController {

    private static final int MAX_REGISTROS = 200;

    private final AlimentacaoRepository alimentacoes;
    private final TanqueRepository tanques;

    // Chamado pelo ESP32 quando o dispenser solta comida.
    @PostMapping("/alimentacoes")
    @ResponseStatus(HttpStatus.CREATED)
    @Transactional
    public AlimentacaoResponse registrar(@Valid @RequestBody AlimentacaoRequest req) {
        Tanque tanque = tanques.findById(req.tanqueId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Tanque não encontrado"));

        Alimentacao a = new Alimentacao();
        a.setTanque(tanque);
        a.setPorcoes(req.porcoes());
        if (tanque.getEspecie() != null) {
            a.setEspecieNome(tanque.getEspecie().getNomeComum());
        }
        if (req.origem() != null) {
            a.setOrigem(req.origem());
        }
        return AlimentacaoResponse.de(alimentacoes.save(a));
    }

    @GetMapping("/tanques/{tanqueId}/alimentacoes")
    public List<AlimentacaoResponse> listar(@PathVariable UUID tanqueId,
            @RequestParam(defaultValue = "30") int limite) {
        if (!tanques.existsById(tanqueId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Tanque não encontrado");
        }
        int n = Math.max(1, Math.min(limite, MAX_REGISTROS));
        return alimentacoes
                .findByTanqueIdOrderByRegistradoEmDesc(tanqueId, PageRequest.of(0, n))
                .stream()
                .map(AlimentacaoResponse::de)
                .toList();
    }
}