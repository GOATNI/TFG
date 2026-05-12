package com.padelmudejar.padelMudejarApi.service;

import com.padelmudejar.padelMudejarApi.dto.reserva.ReservaRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.reserva.ReservaResponseDTO;
import com.padelmudejar.padelMudejarApi.entity.*;
import com.padelmudejar.padelMudejarApi.enums.EstadoReserva;
import com.padelmudejar.padelMudejarApi.exception.BusinessRuleException;
import com.padelmudejar.padelMudejarApi.exception.ResourceNotFoundException;
import com.padelmudejar.padelMudejarApi.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ReservaService {

    private final ReservaRepository reservaRepository;
    private final SocioRepository socioRepository;
    private final AdministradorRepository administradorRepository;
    private final InstalacionRepository instalacionRepository;

    public ReservaResponseDTO crearReserva(ReservaRequestDTO reservaRequestDTO) {
        // Validar que existe el socio
        Socio socio = socioRepository.findById(reservaRequestDTO.getDniSocio())
                .orElseThrow(() -> new ResourceNotFoundException("Socio no encontrado"));

        // Validar que existe el administrador
        Administrador administrador = administradorRepository.findById(reservaRequestDTO.getDniAdministrador())
                .orElseThrow(() -> new ResourceNotFoundException("Administrador no encontrado"));

        // Validar que existe la instalación
        Instalacion instalacion = instalacionRepository.findById(reservaRequestDTO.getIdInstalacion())
                .orElseThrow(() -> new ResourceNotFoundException("Instalación no encontrada"));

        // Verificar disponibilidad (no debe haber otra reserva en el mismo horario)
        LocalDateTime finReserva = reservaRequestDTO.getFechaHora()
                .plusHours(reservaRequestDTO.getDuracion().longValue());

        List<Reserva> reservasConflicto = reservaRepository.findByFechaHoraBetween(
                reservaRequestDTO.getFechaHora(),
                finReserva
        ).stream()
                .filter(r -> r.getInstalacion().getIdInstalacion()
                        .equals(reservaRequestDTO.getIdInstalacion()))
                .filter(r -> r.getEstadoReserva() == EstadoReserva.OCUPADA)
                .collect(Collectors.toList());

        if (!reservasConflicto.isEmpty()) {
            throw new BusinessRuleException("La instalación ya tiene una reserva en ese horario");
        }

        Reserva reserva = Reserva.builder()
                .socio(socio)
                .administrador(administrador)
                .instalacion(instalacion)
                .duracion(reservaRequestDTO.getDuracion())
                .fechaHora(reservaRequestDTO.getFechaHora())
                .estadoReserva(EstadoReserva.OCUPADA)
                .build();

        Reserva reservaGuardada = reservaRepository.save(reserva);
        return ReservaResponseDTO.builder()
                .idReserva(reservaGuardada.getIdReserva())
                .dniSocio(reservaGuardada.getSocio().getDniUsuario())
                .dniAdministrador(reservaGuardada.getAdministrador().getDniUsuario())
                .idInstalacion(reservaGuardada.getInstalacion().getIdInstalacion())
                .duracion(reservaGuardada.getDuracion())
                .fechaHora(reservaGuardada.getFechaHora())
                .estadoReserva(reservaGuardada.getEstadoReserva())
                .build();
    }

    public ReservaResponseDTO obtenerReserva(Long idReserva) {
        Reserva reserva = reservaRepository.findById(idReserva)
                .orElseThrow(() -> new ResourceNotFoundException("Reserva no encontrada"));
        return ReservaResponseDTO.builder()
                .idReserva(reserva.getIdReserva())
                .dniSocio(reserva.getSocio().getDniUsuario())
                .dniAdministrador(reserva.getAdministrador().getDniUsuario())
                .idInstalacion(reserva.getInstalacion().getIdInstalacion())
                .duracion(reserva.getDuracion())
                .fechaHora(reserva.getFechaHora())
                .estadoReserva(reserva.getEstadoReserva())
                .build();
    }

    public List<ReservaResponseDTO> listarReservas() {
        return reservaRepository.findAll().stream()
                .map(res -> ReservaResponseDTO.builder()
                        .idReserva(res.getIdReserva())
                        .dniSocio(res.getSocio().getDniUsuario())
                        .dniAdministrador(res.getAdministrador().getDniUsuario())
                        .idInstalacion(res.getInstalacion().getIdInstalacion())
                        .duracion(res.getDuracion())
                        .fechaHora(res.getFechaHora())
                        .estadoReserva(res.getEstadoReserva())
                        .build())
                .collect(Collectors.toList());
    }

    public List<ReservaResponseDTO> listarReservasPorSocio(String dniSocio) {
        return reservaRepository.findBySocio_DniUsuario(dniSocio).stream()
                .map(res -> ReservaResponseDTO.builder()
                        .idReserva(res.getIdReserva())
                        .dniSocio(res.getSocio().getDniUsuario())
                        .dniAdministrador(res.getAdministrador().getDniUsuario())
                        .idInstalacion(res.getInstalacion().getIdInstalacion())
                        .duracion(res.getDuracion())
                        .fechaHora(res.getFechaHora())
                        .estadoReserva(res.getEstadoReserva())
                        .build())
                .collect(Collectors.toList());
    }

    public void cancelarReserva(Long idReserva) {
        Reserva reserva = reservaRepository.findById(idReserva)
                .orElseThrow(() -> new ResourceNotFoundException("Reserva no encontrada"));

        if (reserva.getEstadoReserva() == EstadoReserva.CANCELADA) {
            throw new BusinessRuleException("La reserva ya está cancelada");
        }

        reserva.setEstadoReserva(EstadoReserva.CANCELADA);
        reservaRepository.save(reserva);
    }
}

