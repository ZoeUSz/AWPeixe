package com.piscicultura.piscicultura_api.controller;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.piscicultura.piscicultura_api.dto.HistoricoResponse;
import com.piscicultura.piscicultura_api.dto.HistoricoResponse.Ponto;
import com.piscicultura.piscicultura_api.entity.Leitura;
import com.piscicultura.piscicultura_api.repository.HistoricoLeituraRepository;
import com.piscicultura.piscicultura_api.repository.HistoricoSensorRepository;

@RestController
@RequestMapping("/tanques")
public class HistoricoController {

    private static final int MAX_PONTOS = 500;

    private final HistoricoSensorRepository sensores;
    private final HistoricoLeituraRepository leituras;

    public HistoricoController(HistoricoSensorRepository sensores,
            HistoricoLeituraRepository leituras) {
        this.sensores = sensores;
        this.leituras = leituras;
    }

    @GetMapping("/{tanqueId}/historico")
    public HistoricoResponse historico(@PathVariable UUID tanqueId,
            @RequestParam(defaultValue = "60") int pontos) {
        int n = Math.max(1, Math.min(pontos, MAX_PONTOS));
        return new HistoricoResponse(
                tanqueId,
                serie(tanqueId, "TEMPERATURA", n),
                serie(tanqueId, "PH", n));
    }

    private List<Ponto> serie(UUID tanqueId, String tipo, int n) {
        return sensores
                .findFirstByTanqueIdAndTipoIgnoreCaseAndAtivoTrue(tanqueId, tipo)
                .map(sensor -> {
                    List<Leitura> lista = new ArrayList<>(
                            leituras.findBySensorIdOrderByRegistradoEmDesc(
                                    sensor.getId(), PageRequest.of(0, n)));
                    Collections.reverse(lista); // mais antiga -> mais nova
                    List<Ponto> pontos = new ArrayList<>();
                    for (Leitura l : lista) {
                        Number valor = l.getValor();
                        pontos.add(new Ponto(String.valueOf(l.getRegistradoEm()), valor));
                    }
                    return pontos;
                })
                .orElseGet(ArrayList::new);
    }
}