package com.padelmudejar.padelMudejarApi.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "premium")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Premium extends Pago {
    
    @Column(nullable = false)
    private String caracteristicasPremium;
    
    @Column(nullable = false)
    private String serviciosExtra;
}

