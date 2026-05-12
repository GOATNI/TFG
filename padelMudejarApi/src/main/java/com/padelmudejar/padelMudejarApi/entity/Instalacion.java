package com.padelmudejar.padelMudejarApi.entity;

import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "instalaciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Instalacion {
    
    @Id
    @Column(length = 4)
    private String idInstalacion;
    
    @ManyToOne
    @JoinColumn(name = "dniTecnico")
    private TecnicoMantenimiento tecnico;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EstadoPista estadoPista;
    
    @Column(nullable = false)
    private String ubicacion;
}

