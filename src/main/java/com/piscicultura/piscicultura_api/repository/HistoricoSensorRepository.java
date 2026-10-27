package com.piscicultura.piscicultura_api.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.repository.Repository;
import com.piscicultura.piscicultura_api.entity.Sensor;

public interface HistoricoSensorRepository extends Repository<Sensor, UUID> {

    Optional<Sensor> findFirstByTanqueIdAndTipoIgnoreCaseAndAtivoTrue(UUID tanqueId, String tipo);
}