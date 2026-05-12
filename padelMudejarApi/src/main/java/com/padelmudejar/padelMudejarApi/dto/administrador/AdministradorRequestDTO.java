package com.padelmudejar.padelMudejarApi.dto.administrador;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdministradorRequestDTO {
    
    @NotBlank(message = "El DNI es obligatorio")
    @Pattern(regexp = "\\d{8}[A-Za-z]", message = "DNI debe tener 8 dígitos y 1 letra")
    private String dniUsuario;
    
    @NotBlank(message = "El nombre es obligatorio")
    private String nombre;
    
    @NotBlank(message = "Los apellidos son obligatorios")
    private String apellidos;
    
    @NotNull(message = "La edad es obligatoria")
    @Min(value = 18, message = "Debe ser mayor de 18 años")
    private Integer edad;
    
    @NotBlank(message = "El teléfono es obligatorio")
    @Pattern(regexp = "\\d{9}", message = "El teléfono debe tener 9 dígitos")
    private String telefono;
    
    @NotBlank(message = "El ID del administrador es obligatorio")
    private String idAdministrador;
}

