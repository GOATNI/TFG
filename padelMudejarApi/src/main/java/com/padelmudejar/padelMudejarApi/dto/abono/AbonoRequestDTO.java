package com.padelmudejar.padelMudejarApi.dto.abono;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AbonoRequestDTO {
    
    @NotNull(message = "El DNI del socio es obligatorio")
    private String dniSocio;
    
    @NotNull(message = "El tipo de abono es obligatorio")
    private Long idTipoAbono;
    
    @NotNull(message = "La fecha de inicio es obligatoria")
    private LocalDate fechaInicio;
}

