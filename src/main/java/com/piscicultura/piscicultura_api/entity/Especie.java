package com.piscicultura.piscicultura_api.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "especie")
@Getter
@Setter
@NoArgsConstructor
public class Especie {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @NotBlank
    @Column(name = "nome_cientifico", nullable = false, length = 150)
    private String nomeCientifico;

    @Column(name = "nome_comum", length = 100)
    private String nomeComum;

    @Column(length = 100)
    private String habitat;

    @Column(name = "ph_min", precision = 4, scale = 2)
    private BigDecimal phMin;

    @Column(name = "ph_max", precision = 4, scale = 2)
    private BigDecimal phMax;

    @Column(name = "dh_min", precision = 5, scale = 2)
    private BigDecimal dhMin;

    @Column(name = "dh_max", precision = 5, scale = 2)
    private BigDecimal dhMax;

    @Column(name = "temp_min", precision = 4, scale = 2)
    private BigDecimal tempMin;

    @Column(name = "temp_max", precision = 4, scale = 2)
    private BigDecimal tempMax;

    @Column(name = "oxigenio_min", precision = 4, scale = 2)
    private BigDecimal oxigenioMin;

    @Column(name = "oxigenio_max", precision = 4, scale = 2)
    private BigDecimal oxigenioMax;

    @Column(length = 50)
    private String clima;

    @Column(columnDefinition = "TEXT")
    private String distribuicao;

    @Column(name = "comprimento_max_cm", precision = 6, scale = 2)
    private BigDecimal comprimentoMaxCm;

    @Column(name = "peso_max_g", precision = 8, scale = 2)
    private BigDecimal pesoMaxG;

    @Column(name = "idade_max_anos")
    private Integer idadeMaxAnos;

    @Column(columnDefinition = "TEXT")
    private String comportamento;

    @Column(name = "tamanho_minimo_tanque_litros", precision = 10, scale = 2)
    private BigDecimal tamanhoMinimoTanqueLitros;

    @Column(name = "tipo_agua", length = 20)
    private String tipoAgua;

    @Column(name = "grupo_hidroquimico", length = 100)
    private String grupoHidroquimico;

    @Column(name = "imagem_url", length = 255)
    private String imagemUrl;

    @Column(name = "habito_alimentar", length = 100)
    private String habitoAlimentar;

    @Column(length = 100)
    private String fonte = "FishBase";

}
