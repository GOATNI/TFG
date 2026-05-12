package com.padelmudejar.padelMudejarApi.dto.instalacion;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AsignacionTecnicoDTO {
    
    @NotBlank(message = "El DNI del técnico es obligatorio")
    private String dniTecnico;
}

