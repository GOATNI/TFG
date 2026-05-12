package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "socios")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Socio {
    
    @Id
    private String dniUsuario;
    
    @OneToOne
    @MapsId
    @JoinColumn(name = "dniUsuario")
    private Usuario usuario;
    
    @ManyToOne
    @JoinColumn(name = "idPago")
    private Pago pago;
    
    @Column(nullable = false, unique = true)
    private String correoElectronico;
    
    @Column(nullable = false)
    private String idCarnet;
}

