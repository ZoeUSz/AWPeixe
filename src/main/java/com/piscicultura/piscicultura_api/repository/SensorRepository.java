package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Sensor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface SensorRepository extends JpaRepository<Sensor, UUID> {

    Optional<Sensor> findFirstByTanqueIdAndTipoIgnoreCaseAndAtivoTrue(UUID tanqueId, String tipo);
}