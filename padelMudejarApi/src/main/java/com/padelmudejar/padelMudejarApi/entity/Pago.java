package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "pagos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Inheritance(strategy = InheritanceType.JOINED)
public class Pago {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idPago;
    
    @Column(nullable = false)
    private String fechaPago;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private com.padelmudejar.padelMudejarApi.enums.MetodoPago metodoPago;
    
    private String ofertas;
}

