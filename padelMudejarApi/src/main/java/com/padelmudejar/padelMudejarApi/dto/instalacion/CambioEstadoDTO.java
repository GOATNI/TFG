package com.padelmudejar.padelMudejarApi.dto.instalacion;

import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CambioEstadoDTO {
    
    @NotNull(message = "El nuevo estado es obligatorio")
    private EstadoPista nuevoEstado;
}

