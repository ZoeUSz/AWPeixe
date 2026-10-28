package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "alerta")
@Getter
@Setter
@NoArgsConstructor
public class Alerta {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Leitura que disparou o alerta (opcional).
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "leitura_id")
    private Leitura leitura;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tanque_id", nullable = false)
    private Tanque tanque;

    // TEMPERATURA_ACIMA, TEMPERATURA_ABAIXO, PH_ACIMA ou PH_ABAIXO
    @Column(nullable = false, length = 50)
    private String tipo;

    @Column(nullable = false, columnDefinition = "text")
    private String mensagem;

    @Column(nullable = false)
    private boolean resolvido;

    @Column(nullable = false)
    private LocalDateTime geradoEm;

    private LocalDateTime resolvidoEm;

    @PrePersist
    void aoCriar() {
        if (geradoEm == null) {
            geradoEm = LocalDateTime.now();
        }
    }
}