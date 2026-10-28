package com.piscicultura.piscicultura_api.service;

import com.piscicultura.piscicultura_api.entity.Alerta;
import com.piscicultura.piscicultura_api.entity.Especie;
import com.piscicultura.piscicultura_api.entity.Leitura;
import com.piscicultura.piscicultura_api.entity.Sensor;
import com.piscicultura.piscicultura_api.entity.Tanque;
import com.piscicultura.piscicultura_api.repository.AlertaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Optional;

/**
 * Gera e encerra alertas a cada leitura recebida.
 * - Fora da faixa da espécie e sem alerta aberto: abre um alerta.
 * - Continua fora da faixa, mesmo sentido: não repete.
 * - Muda de lado (acima -> abaixo): fecha o anterior e abre outro.
 * - Voltou para a faixa: fecha o alerta aberto.
 */
@Service
@RequiredArgsConstructor
public class AlertaService {

    private static final Locale PT_BR = Locale.of("pt", "BR");

    private final AlertaRepository alertas;

    @Transactional
    public void avaliar(Leitura leitura, Sensor sensor) {
        Tanque tanque = sensor.getTanque();
        if (tanque == null || tanque.getEspecie() == null) {
            return; // sem espécie não há faixa para comparar
        }
        Especie especie = tanque.getEspecie();

        String parametro = sensor.getTipo() == null
                ? ""
                : sensor.getTipo().toUpperCase(Locale.ROOT);
        BigDecimal min;
        BigDecimal max;
        String nome;
        int casas;
        if (parametro.equals("TEMPERATURA")) {
            min = especie.getTempMin();
            max = especie.getTempMax();
            nome = "Temperatura";
            casas = 1;
        } else if (parametro.equals("PH")) {
            min = especie.getPhMin();
            max = especie.getPhMax();
            nome = "pH";
            casas = 2;
        } else {
            return; // tipo de sensor que não monitoramos
        }
        if (min == null || max == null) {
            return;
        }

        BigDecimal valor = leitura.getValor();
        String tipoNovo = null;
        String sentido = null;
        if (valor.compareTo(max) > 0) {
            tipoNovo = parametro + "_ACIMA";
            sentido = "acima";
        } else if (valor.compareTo(min) < 0) {
            tipoNovo = parametro + "_ABAIXO";
            sentido = "abaixo";
        }

        Optional<Alerta> aberto = alertas
                .findFirstByTanqueIdAndTipoStartingWithAndResolvidoFalse(
                        tanque.getId(), parametro);

        if (aberto.isPresent()) {
            if (tipoNovo != null && aberto.get().getTipo().equals(tipoNovo)) {
                return; // continua fora da faixa: não repete o alerta
            }
            Alerta antigo = aberto.get();
            antigo.setResolvido(true);
            antigo.setResolvidoEm(LocalDateTime.now());
            alertas.save(antigo);
        }

        if (tipoNovo == null) {
            return; // voltou para a faixa
        }

        // pH não tem unidade de verdade (o "pH" do sensor repetiria o nome).
        String un = parametro.equals("PH")
                || sensor.getUnidade() == null || sensor.getUnidade().isBlank()
                        ? ""
                        : " " + sensor.getUnidade();
        Alerta novo = new Alerta();
        novo.setLeitura(leitura);
        novo.setTanque(tanque);
        novo.setTipo(tipoNovo);
        novo.setMensagem(String.format(PT_BR,
                "%s %s do ideal: %s%s (faixa %s a %s%s)",
                nome, sentido, fmt(valor, casas), un,
                fmt(min, casas), fmt(max, casas), un));
        alertas.save(novo);
    }

    private static String fmt(BigDecimal v, int casas) {
        return String.format(PT_BR, "%." + casas + "f", v);
    }
}