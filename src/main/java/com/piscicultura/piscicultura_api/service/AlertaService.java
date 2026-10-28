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
 * - Continua fora, mesmo sentido e mesma espécie: não repete.
 * - Mudou de lado (acima -> abaixo) ou de espécie: fecha o anterior e abre
 * outro.
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
        String nomeEspecie = especie.getNomeComum();

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
            Alerta atual = aberto.get();
            boolean mesmoAlerta = tipoNovo != null
                    && atual.getTipo().equals(tipoNovo)
                    && nomeEspecie != null
                    && nomeEspecie.equals(atual.getEspecieNome());
            if (mesmoAlerta) {
                return; // continua fora da faixa: não repete o alerta
            }
            atual.setResolvido(true);
            atual.setResolvidoEm(LocalDateTime.now());
            alertas.save(atual);
        }

        if (tipoNovo == null) {
            return; // voltou para a faixa
        }

        String un = parametro.equals("PH")
                || sensor.getUnidade() == null || sensor.getUnidade().isBlank()
                        ? ""
                        : " " + sensor.getUnidade();
        Alerta novo = new Alerta();
        novo.setLeitura(leitura);
        novo.setTanque(tanque);
        novo.setTipo(tipoNovo);
        novo.setEspecieNome(nomeEspecie);
        novo.setAcao(acaoPara(tipoNovo));
        novo.setMensagem(String.format(PT_BR,
                "%s %s do ideal para %s: %s%s (faixa %s a %s%s)",
                nome, sentido, nomeEspecie, fmt(valor, casas), un,
                fmt(min, casas), fmt(max, casas), un));
        alertas.save(novo);
    }

    // Ação indicada para cada tipo de alerta.
    static String acaoPara(String tipo) {
        return switch (tipo) {
            case "TEMPERATURA_ACIMA" -> "Ligar o cooler para resfriar a água";
            case "TEMPERATURA_ABAIXO" -> "Ligar o aquecedor para esquentar a água";
            case "PH_ACIMA" -> "Reduzir o pH da água (correção manual)";
            case "PH_ABAIXO" -> "Elevar o pH da água (correção manual)";
            default -> null;
        };
    }

    private static String fmt(BigDecimal v, int casas) {
        return String.format(PT_BR, "%." + casas + "f", v);
    }
}