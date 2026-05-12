package com.padelmudejar.padelMudejarApi.dto.reserva;

import com.padelmudejar.padelMudejarApi.enums.EstadoReserva;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReservaResponseDTO {
    
    private Long idReserva;
    private String dniSocio;
    private String dniAdministrador;
    private String idInstalacion;
    private Double duracion;
    private LocalDateTime fechaHora;
    private EstadoReserva estadoReserva;
}

