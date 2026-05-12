package com.padelmudejar.padelMudejarApi.dto.socio;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SocioResponseDTO {
    
    private String dniUsuario;
    private String nombre;
    private String apellidos;
    private int edad;
    private String telefono;
    private String correoElectronico;
    private String idCarnet;
    private Long idPago;
}

