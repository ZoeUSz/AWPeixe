package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Entity
@Table(name = "sensor")
@Getter
@Setter
@NoArgsConstructor
public class Sensor {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "tanque_id", nullable = false)
    private Tanque tanque;

    // 'TEMPERATURA', 'PH', 'OXIGENIO'
    @Column(nullable = false, length = 50)
    private String tipo;

    @Column(length = 100)
    private String modelo;

    @Column(length = 20)
    private String unidade;

    @Column(nullable = false)
    private boolean ativo = true;
}