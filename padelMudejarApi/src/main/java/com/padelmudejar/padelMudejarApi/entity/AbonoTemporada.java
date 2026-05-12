package com.padelmudejar.padelMudejarApi.entity;

import com.padelmudejar.padelMudejarApi.enums.EstadoAbono;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Table(name = "abonos_temporada")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AbonoTemporada {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idAbono;
    
    @ManyToOne
    @JoinColumn(name = "dniSocio", nullable = false)
    private Socio socio;
    
    @ManyToOne
    @JoinColumn(name = "idTipoAbono", nullable = false)
    private TipoAbono tipoAbono;
    
    @Column(nullable = false)
    private LocalDate fechaInicio;
    
    @Column(nullable = false)
    private LocalDate fechaFin;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoAbono estado;
}

