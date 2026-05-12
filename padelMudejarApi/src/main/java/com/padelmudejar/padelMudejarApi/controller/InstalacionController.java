package com.padelmudejar.padelMudejarApi.controller;

import com.padelmudejar.padelMudejarApi.dto.instalacion.AsignacionTecnicoDTO;
import com.padelmudejar.padelMudejarApi.dto.instalacion.CambioEstadoDTO;
import com.padelmudejar.padelMudejarApi.dto.instalacion.InstalacionResponseDTO;
import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import com.padelmudejar.padelMudejarApi.service.InstalacionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/instalaciones")
@RequiredArgsConstructor
public class InstalacionController {

    private final InstalacionService instalacionService;

    @GetMapping("/{id}")
    public ResponseEntity<InstalacionResponseDTO> obtenerInstalacion(@PathVariable String id) {
        return ResponseEntity.ok(instalacionService.obtenerInstalacion(id));
    }

    @GetMapping
    public ResponseEntity<List<InstalacionResponseDTO>> listarInstalaciones() {
        return ResponseEntity.ok(instalacionService.listarInstalaciones());
    }

    @GetMapping("/estado/{estado}")
    public ResponseEntity<List<InstalacionResponseDTO>> listarPorEstado(
            @PathVariable EstadoPista estado) {
        return ResponseEntity.ok(instalacionService.listarPorEstado(estado));
    }

    @PatchMapping("/{id}/estado")
    public ResponseEntity<InstalacionResponseDTO> cambiarEstado(
            @PathVariable String id,
            @Valid @RequestBody CambioEstadoDTO cambioDTO) {
        return ResponseEntity.ok(instalacionService.cambiarEstado(id, cambioDTO));
    }

    @PatchMapping("/{id}/tecnico")
    public ResponseEntity<InstalacionResponseDTO> asignarTecnico(
            @PathVariable String id,
            @Valid @RequestBody AsignacionTecnicoDTO asignacionDTO) {
        return ResponseEntity.ok(instalacionService.asignarTecnico(id, asignacionDTO));
    }
}

