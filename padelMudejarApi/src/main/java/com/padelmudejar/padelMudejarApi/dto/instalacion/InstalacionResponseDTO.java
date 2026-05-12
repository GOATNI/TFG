package com.padelmudejar.padelMudejarApi.dto.instalacion;

import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InstalacionResponseDTO {
    
    private String idInstalacion;
    private String dniTecnico;
    private EstadoPista estadoPista;
    private String ubicacion;
}

