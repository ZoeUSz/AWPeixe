package com.piscicultura.piscicultura_api.repository;

import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;
import com.piscicultura.piscicultura_api.entity.Leitura;

public interface HistoricoLeituraRepository extends Repository<Leitura, UUID> {

    // Já vem da mais nova para a mais antiga; o controller inverte.
    List<Leitura> findBySensorIdOrderByRegistradoEmDesc(UUID sensorId, Pageable pageable);
}