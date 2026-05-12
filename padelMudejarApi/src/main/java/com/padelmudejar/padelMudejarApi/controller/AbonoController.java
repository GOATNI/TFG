package com.padelmudejar.padelMudejarApi.controller;

import com.padelmudejar.padelMudejarApi.dto.abono.AbonoRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.abono.AbonoResponseDTO;
import com.padelmudejar.padelMudejarApi.service.AbonoService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/abonos")
@RequiredArgsConstructor
public class AbonoController {

    private final AbonoService abonoService;

    @PostMapping
    public ResponseEntity<AbonoResponseDTO> crearAbono(@Valid @RequestBody AbonoRequestDTO abonoRequestDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(abonoService.crearAbono(abonoRequestDTO));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AbonoResponseDTO> obtenerAbono(@PathVariable Long id) {
        return ResponseEntity.ok(abonoService.obtenerAbono(id));
    }

    @GetMapping
    public ResponseEntity<List<AbonoResponseDTO>> listarAbonos() {
        return ResponseEntity.ok(abonoService.listarAbonos());
    }

    @GetMapping("/socio/{dni}")
    public ResponseEntity<List<AbonoResponseDTO>> obtenerAbonoPorSocio(@PathVariable String dni) {
        return ResponseEntity.ok(abonoService.obtenerAbonoPorSocio(dni));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancelarAbono(@PathVariable Long id) {
        abonoService.cancelarAbono(id);
        return ResponseEntity.noContent().build();
    }
}

