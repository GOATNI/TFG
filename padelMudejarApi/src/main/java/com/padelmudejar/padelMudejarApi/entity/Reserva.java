package com.padelmudejar.padelMudejarApi.entity;

import com.padelmudejar.padelMudejarApi.enums.EstadoReserva;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservas")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Reserva {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idReserva;
    
    @ManyToOne
    @JoinColumn(name = "dniSocio", nullable = false)
    private Socio socio;
    
    @ManyToOne
    @JoinColumn(name = "dniAdministrador", nullable = false)
    private Administrador administrador;
    
    @ManyToOne
    @JoinColumn(name = "instalacion", nullable = false)
    private Instalacion instalacion;
    
    @Column(nullable = false)
    private Double duracion = 1.0;
    
    @Column(nullable = false)
    private LocalDateTime fechaHora;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoReserva estadoReserva;
}

