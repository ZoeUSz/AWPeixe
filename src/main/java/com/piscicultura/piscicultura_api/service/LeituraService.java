package com.piscicultura.piscicultura_api.service;

import com.piscicultura.piscicultura_api.dto.LeituraRequest;
import com.piscicultura.piscicultura_api.dto.Respostas.LeituraResponse;
import com.piscicultura.piscicultura_api.entity.Leitura;
import com.piscicultura.piscicultura_api.entity.Sensor;
import com.piscicultura.piscicultura_api.repository.LeituraRepository;
import com.piscicultura.piscicultura_api.repository.SensorRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class LeituraService {

    private final SensorRepository sensores;
    private final LeituraRepository leituras;
    private final AlertaService alertaService;

    @Transactional
    public LeituraResponse registrar(LeituraRequest req) {
        Sensor sensor = sensores.findById(req.sensorId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Sensor não encontrado"));

        if (!sensor.isAtivo()) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT, "Sensor desativado");
        }

        Leitura leitura = new Leitura();
        leitura.setSensor(sensor);
        leitura.setValor(req.valor());
        leitura = leituras.save(leitura);

        // Abre ou encerra alertas conforme a faixa da espécie do tanque.
        alertaService.avaliar(leitura, sensor);

        return new LeituraResponse(
                leitura.getId(), sensor.getId(), sensor.getTipo(),
                leitura.getValor(), leitura.getRegistradoEm());
    }
}