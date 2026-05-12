package com.padelmudejar.padelMudejarApi.dto.abono;

import com.padelmudejar.padelMudejarApi.enums.EstadoAbono;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AbonoResponseDTO {
    
    private Long idAbono;
    private String dniSocio;
    private Long idTipoAbono;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private EstadoAbono estado;
}

