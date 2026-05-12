package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "basico")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Basico extends Pago {
    
    @Column(nullable = false)
    private String caracteristicasBasico;
}

