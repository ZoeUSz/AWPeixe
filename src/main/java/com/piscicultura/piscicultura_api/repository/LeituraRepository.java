package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Leitura;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface LeituraRepository extends JpaRepository<Leitura, UUID> {

    Optional<Leitura> findFirstBySensorIdOrderByRegistradoEmDesc(UUID sensorId);
}