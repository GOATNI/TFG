package com.padelmudejar.padelMudejarApi.controller;

import com.padelmudejar.padelMudejarApi.dto.administrador.AdministradorRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.administrador.AdministradorResponseDTO;
import com.padelmudejar.padelMudejarApi.service.AdministradorService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/administradores")
@RequiredArgsConstructor
public class AdministradorController {

    private final AdministradorService administradorService;

    @PostMapping
    public ResponseEntity<AdministradorResponseDTO> crearAdministrador(
            @Valid @RequestBody AdministradorRequestDTO adminRequestDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(administradorService.crearAdministrador(adminRequestDTO));
    }

    @GetMapping("/{dni}")
    public ResponseEntity<AdministradorResponseDTO> obtenerAdministrador(@PathVariable String dni) {
        return ResponseEntity.ok(administradorService.obtenerAdministrador(dni));
    }

    @GetMapping
    public ResponseEntity<List<AdministradorResponseDTO>> listarAdministradores() {
        return ResponseEntity.ok(administradorService.listarAdministradores());
    }

    @DeleteMapping("/{dni}")
    public ResponseEntity<Void> desactivarAdministrador(@PathVariable String dni) {
        administradorService.desactivarAdministrador(dni);
        return ResponseEntity.noContent().build();
    }
}

