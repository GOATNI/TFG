package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "administrador")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Administrador {
    
    @Id
    private String dniUsuario;
    
    @OneToOne
    @MapsId
    @JoinColumn(name = "dniUsuario")
    private Usuario usuario;
    
    @Column(nullable = false)
    private boolean activo;
    
    @Column(nullable = false)
    private String idAdministrador;
}

