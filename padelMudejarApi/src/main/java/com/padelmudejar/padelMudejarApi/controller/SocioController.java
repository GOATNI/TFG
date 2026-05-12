package com.padelmudejar.padelMudejarApi.controller;

import com.padelmudejar.padelMudejarApi.dto.socio.SocioRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.socio.SocioResponseDTO;
import com.padelmudejar.padelMudejarApi.service.SocioService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/socios")
@RequiredArgsConstructor
public class SocioController {

    private final SocioService socioService;

    @PostMapping
    public ResponseEntity<SocioResponseDTO> crearSocio(@Valid @RequestBody SocioRequestDTO socioRequestDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(socioService.crearSocio(socioRequestDTO));
    }

    @GetMapping("/{dni}")
    public ResponseEntity<SocioResponseDTO> obtenerSocio(@PathVariable String dni) {
        return ResponseEntity.ok(socioService.obtenerSocio(dni));
    }

    @GetMapping
    public ResponseEntity<List<SocioResponseDTO>> listarSocios() {
        return ResponseEntity.ok(socioService.listarSocios());
    }

    @PutMapping("/{dni}")
    public ResponseEntity<SocioResponseDTO> actualizarSocio(
            @PathVariable String dni,
            @Valid @RequestBody SocioRequestDTO socioRequestDTO) {
        return ResponseEntity.ok(socioService.actualizarSocio(dni, socioRequestDTO));
    }

    @DeleteMapping("/{dni}")
    public ResponseEntity<Void> eliminarSocio(@PathVariable String dni) {
        socioService.eliminarSocio(dni);
        return ResponseEntity.noContent().build();
    }
}

