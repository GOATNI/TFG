package com.padelmudejar.padelMudejarApi.dto.reserva;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReservaRequestDTO {
    
    @NotBlank(message = "El DNI del socio es obligatorio")
    private String dniSocio;
    
    @NotBlank(message = "El DNI del administrador es obligatorio")
    private String dniAdministrador;
    
    @NotBlank(message = "El ID de la instalación es obligatorio")
    private String idInstalacion;
    
    private Double duracion = 1.0;
    
    @NotNull(message = "La fecha y hora es obligatoria")
    @Future(message = "La fecha debe ser en el futuro")
    private LocalDateTime fechaHora;
}

