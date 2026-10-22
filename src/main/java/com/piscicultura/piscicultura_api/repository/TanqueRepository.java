package com.piscicultura.piscicultura_api.repository;

import com.piscicultura.piscicultura_api.entity.Tanque;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface TanqueRepository extends JpaRepository<Tanque, UUID> {
}