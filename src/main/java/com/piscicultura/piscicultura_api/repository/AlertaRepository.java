package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Alerta;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface AlertaRepository extends JpaRepository<Alerta, UUID> {

    // Alerta ainda aberto de um parâmetro (prefixo: "TEMPERATURA" ou "PH").
    Optional<Alerta> findFirstByTanqueIdAndTipoStartingWithAndResolvidoFalse(
            UUID tanqueId, String prefixoTipo);

    // Abertos primeiro, depois os mais recentes.
    List<Alerta> findByTanqueIdOrderByResolvidoAscGeradoEmDesc(
            UUID tanqueId, Pageable pageable);
}