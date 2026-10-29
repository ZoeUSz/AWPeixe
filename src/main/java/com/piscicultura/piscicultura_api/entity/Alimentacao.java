package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "alimentacao")
@Getter
@Setter
@NoArgsConstructor
public class Alimentacao {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tanque_id", nullable = false)
    private Tanque tanque;

    // AUTOMATICA (agendamento do ESP32) ou MANUAL
    @Column(nullable = false, length = 20)
    private String origem = "AUTOMATICA";

    // Nome comum da espécie do tanque na hora da alimentação.
    @Column(name = "especie_nome", length = 100)
    private String especieNome;

    // Quantidade de porções soltas (opcional).
    private Integer porcoes;

    @Column(name = "registrado_em", nullable = false)
    private LocalDateTime registradoEm;

    @PrePersist
    void aoCriar() {
        if (registradoEm == null) {
            registradoEm = LocalDateTime.now();
        }
    }
}