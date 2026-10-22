package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "tanque")
@Getter
@Setter
@NoArgsConstructor
public class Tanque {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Ainda não existe a entidade Usuario, então guardamos só o id.
    @Column(name = "usuario_id", nullable = false)
    private UUID usuarioId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "especie_id")
    private Especie especie;

    @Column(nullable = false, length = 100)
    private String nome;

    private BigDecimal capacidadeLitros;

    @Column(length = 150)
    private String localizacao;

    @Column(nullable = false)
    private LocalDateTime criadoEm;

    @PrePersist
    void aoCriar() {
        if (criadoEm == null) {
            criadoEm = LocalDateTime.now();
        }
    }
}