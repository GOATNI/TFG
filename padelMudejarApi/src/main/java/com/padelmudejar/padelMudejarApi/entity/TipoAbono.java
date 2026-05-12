package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "tipos_abono")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TipoAbono {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idTipoAbono;
    
    @Column(nullable = false)
    private String nombre;
    
    @Column(nullable = false)
    private String descripcion;
    
    @Column(nullable = false)
    private Double precio;
    
    @Column(nullable = false)
    private Integer duracionMeses;
}

