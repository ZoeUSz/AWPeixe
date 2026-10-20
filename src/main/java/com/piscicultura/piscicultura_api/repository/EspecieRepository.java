package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Especie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface EspecieRepository extends JpaRepository<Especie, UUID> {

    List<Especie> findByGrupoHidroquimicoIgnoreCase(String grupoHidroquimico);

    @Query("select distinct e.grupoHidroquimico from Especie e "
            + "where e.grupoHidroquimico is not null order by e.grupoHidroquimico")
    List<String> findGruposDistintos();
}