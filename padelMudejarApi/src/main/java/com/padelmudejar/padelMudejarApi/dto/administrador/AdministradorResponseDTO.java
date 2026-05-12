package com.padelmudejar.padelMudejarApi.dto.administrador;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdministradorResponseDTO {
    
    private String dniUsuario;
    private String nombre;
    private String apellidos;
    private int edad;
    private String telefono;
    private boolean activo;
    private String idAdministrador;
}

