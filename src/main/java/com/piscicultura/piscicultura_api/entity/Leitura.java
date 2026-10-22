package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "leitura")
@Getter
@Setter
@NoArgsConstructor
public class Leitura {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sensor_id", nullable = false)
    private Sensor sensor;

    @Column(nullable = false, precision = 8, scale = 4)
    private BigDecimal valor;

    @Column(nullable = false)
    private LocalDateTime registradoEm;

    @PrePersist
    void aoCriar() {
        if (registradoEm == null) {
            registradoEm = LocalDateTime.now();
        }
    }
}