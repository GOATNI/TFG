package com.padelmudejar.padelMudejarApi.entity;

import com.padelmudejar.padelMudejarApi.enums.EspecialidadTecnico;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "tecnicoMantenimiento")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TecnicoMantenimiento {
    
    @Id
    private String dniUsuario;
    
    @OneToOne
    @MapsId
    @JoinColumn(name = "dniUsuario")
    private Usuario usuario;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private EspecialidadTecnico especialidad;
    
    @Column(nullable = false)
    private String idTecnicoMantenimiento;
}

