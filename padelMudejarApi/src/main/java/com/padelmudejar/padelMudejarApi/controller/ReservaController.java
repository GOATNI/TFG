package com.padelmudejar.padelMudejarApi.controller;

import com.padelmudejar.padelMudejarApi.dto.reserva.ReservaRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.reserva.ReservaResponseDTO;
import com.padelmudejar.padelMudejarApi.service.ReservaService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/reservas")
@RequiredArgsConstructor
public class ReservaController {

    private final ReservaService reservaService;

    @PostMapping
    public ResponseEntity<ReservaResponseDTO> crearReserva(
            @Valid @RequestBody ReservaRequestDTO reservaRequestDTO) {
        return ResponseEntity.status(HttpStatus.CREATED).body(reservaService.crearReserva(reservaRequestDTO));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservaResponseDTO> obtenerReserva(@PathVariable Long id) {
        return ResponseEntity.ok(reservaService.obtenerReserva(id));
    }

    @GetMapping
    public ResponseEntity<List<ReservaResponseDTO>> listarReservas() {
        return ResponseEntity.ok(reservaService.listarReservas());
    }

    @GetMapping("/socio/{dni}")
    public ResponseEntity<List<ReservaResponseDTO>> listarReservasPorSocio(@PathVariable String dni) {
        return ResponseEntity.ok(reservaService.listarReservasPorSocio(dni));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> cancelarReserva(@PathVariable Long id) {
        reservaService.cancelarReserva(id);
        return ResponseEntity.noContent().build();
    }
}

