package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Alimentacao;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AlimentacaoRepository extends JpaRepository<Alimentacao, UUID> {

    // Mais recentes primeiro.
    List<Alimentacao> findByTanqueIdOrderByRegistradoEmDesc(
            UUID tanqueId, Pageable pageable);
}
