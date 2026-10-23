package com.piscicultura.piscicultura_api.service;

import com.piscicultura.piscicultura_api.dto.Respostas.ParametroStatus;
import com.piscicultura.piscicultura_api.dto.Respostas.StatusTanqueResponse;
import com.piscicultura.piscicultura_api.dto.Respostas.TanqueResponse;
import com.piscicultura.piscicultura_api.entity.Especie;
import com.piscicultura.piscicultura_api.entity.Leitura;
import com.piscicultura.piscicultura_api.entity.Sensor;
import com.piscicultura.piscicultura_api.entity.Tanque;
import com.piscicultura.piscicultura_api.repository.EspecieRepository;
import com.piscicultura.piscicultura_api.repository.LeituraRepository;
import com.piscicultura.piscicultura_api.repository.SensorRepository;
import com.piscicultura.piscicultura_api.repository.TanqueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class TanqueService {

    private final TanqueRepository tanques;
    private final EspecieRepository especies;
    private final SensorRepository sensores;
    private final LeituraRepository leituras;

    @Transactional(readOnly = true)
    public List<TanqueResponse> listar() {
        return tanques.findAll().stream().map(this::paraResposta).toList();
    }

    @Transactional
    public TanqueResponse definirEspecie(UUID tanqueId, UUID especieId) {
        Tanque tanque = buscarTanque(tanqueId);
        Especie especie = especies.findById(especieId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Espécie não encontrada"));
        tanque.setEspecie(especie);
        return paraResposta(tanques.save(tanque));
    }

    @Transactional(readOnly = true)
    public StatusTanqueResponse status(UUID tanqueId) {
        Tanque tanque = buscarTanque(tanqueId);
        Especie esp = tanque.getEspecie();

        List<ParametroStatus> parametros = new ArrayList<>();
        parametros.add(avaliar(tanque, "TEMPERATURA",
                esp == null ? null : esp.getTempMin(),
                esp == null ? null : esp.getTempMax()));
        parametros.add(avaliar(tanque, "PH",
                esp == null ? null : esp.getPhMin(),
                esp == null ? null : esp.getPhMax()));

        return new StatusTanqueResponse(
                tanque.getId(), tanque.getNome(),
                esp == null ? null : esp.getId(),
                esp == null ? null : esp.getNomeComum(),
                statusGeral(esp, parametros), parametros);
    }

    private ParametroStatus avaliar(Tanque tanque, String tipo,
            BigDecimal min, BigDecimal max) {
        Optional<Sensor> sensor = sensores
                .findFirstByTanqueIdAndTipoIgnoreCaseAndAtivoTrue(tanque.getId(), tipo);
        if (sensor.isEmpty()) {
            return new ParametroStatus(tipo, null, null, min, max, "SEM_SENSOR", null);
        }

        String unidade = sensor.get().getUnidade();
        Optional<Leitura> ultima = leituras
                .findFirstBySensorIdOrderByRegistradoEmDesc(sensor.get().getId());
        if (ultima.isEmpty()) {
            return new ParametroStatus(tipo, unidade, null, min, max, "SEM_LEITURA", null);
        }

        BigDecimal valor = ultima.get().getValor();
        String situacao;
        if (min == null || max == null) {
            situacao = "SEM_FAIXA";
        } else if (valor.compareTo(min) < 0) {
            situacao = "ABAIXO";
        } else if (valor.compareTo(max) > 0) {
            situacao = "ACIMA";
        } else {
            situacao = "OK";
        }
        return new ParametroStatus(tipo, unidade, valor, min, max,
                situacao, ultima.get().getRegistradoEm());
    }

    private String statusGeral(Especie especie, List<ParametroStatus> parametros) {
        boolean fora = parametros.stream()
                .anyMatch(p -> p.situacao().equals("ABAIXO") || p.situacao().equals("ACIMA"));
        if (fora) {
            return "ALERTA";
        }
        if (especie == null) {
            return "SEM_ESPECIE";
        }
        boolean semDados = parametros.stream()
                .anyMatch(p -> p.situacao().equals("SEM_LEITURA") || p.situacao().equals("SEM_SENSOR"));
        return semDados ? "SEM_DADOS" : "OK";
    }

    private Tanque buscarTanque(UUID id) {
        return tanques.findById(id)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Tanque não encontrado"));
    }

    private TanqueResponse paraResposta(Tanque t) {
        Especie e = t.getEspecie();
        return new TanqueResponse(t.getId(), t.getNome(), t.getCapacidadeLitros(),
                e == null ? null : e.getId(),
                e == null ? null : e.getNomeComum());
    }
}