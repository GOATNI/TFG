package com.padelmudejar.padelMudejarApi.service;

import com.padelmudejar.padelMudejarApi.dto.abono.AbonoRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.abono.AbonoResponseDTO;
import com.padelmudejar.padelMudejarApi.entity.AbonoTemporada;
import com.padelmudejar.padelMudejarApi.entity.Socio;
import com.padelmudejar.padelMudejarApi.entity.TipoAbono;
import com.padelmudejar.padelMudejarApi.enums.EstadoAbono;
import com.padelmudejar.padelMudejarApi.exception.BusinessRuleException;
import com.padelmudejar.padelMudejarApi.exception.ResourceNotFoundException;
import com.padelmudejar.padelMudejarApi.repository.AbonoTemporadaRepository;
import com.padelmudejar.padelMudejarApi.repository.SocioRepository;
import com.padelmudejar.padelMudejarApi.repository.TipoAbonoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AbonoService {

    private final AbonoTemporadaRepository abonoRepository;
    private final SocioRepository socioRepository;
    private final TipoAbonoRepository tipoAbonoRepository;


    public AbonoResponseDTO crearAbono(AbonoRequestDTO abonoRequestDTO) {
        // Validar que existe el socio
        Socio socio = socioRepository.findById(abonoRequestDTO.getDniSocio())
                .orElseThrow(() -> new ResourceNotFoundException("Socio no encontrado"));

        // Validar que existe el tipo de abono
        TipoAbono tipoAbono = tipoAbonoRepository.findById(abonoRequestDTO.getIdTipoAbono())
                .orElseThrow(() -> new ResourceNotFoundException("Tipo de abono no encontrado"));

        // Calcular fecha fin según duración del tipo de abono
        LocalDate fechaFin = abonoRequestDTO.getFechaInicio()
                .plusMonths(tipoAbono.getDuracionMeses());

        AbonoTemporada abono = AbonoTemporada.builder()
                .socio(socio)
                .tipoAbono(tipoAbono)
                .fechaInicio(abonoRequestDTO.getFechaInicio())
                .fechaFin(fechaFin)
                .estado(EstadoAbono.ACTIVO)
                .build();

        AbonoTemporada abonoGuardado = abonoRepository.save(abono);
        return AbonoResponseDTO.builder()
                .idAbono(abonoGuardado.getIdAbono())
                .dniSocio(abonoGuardado.getSocio().getDniUsuario())
                .idTipoAbono(abonoGuardado.getTipoAbono().getIdTipoAbono())
                .fechaInicio(abonoGuardado.getFechaInicio())
                .fechaFin(abonoGuardado.getFechaFin())
                .estado(abonoGuardado.getEstado())
                .build();
    }

    public AbonoResponseDTO obtenerAbono(Long idAbono) {
        AbonoTemporada abono = abonoRepository.findById(idAbono)
                .orElseThrow(() -> new ResourceNotFoundException("Abono no encontrado"));
        return AbonoResponseDTO.builder()
                .idAbono(abono.getIdAbono())
                .dniSocio(abono.getSocio().getDniUsuario())
                .idTipoAbono(abono.getTipoAbono().getIdTipoAbono())
                .fechaInicio(abono.getFechaInicio())
                .fechaFin(abono.getFechaFin())
                .estado(abono.getEstado())
                .build();
    }

    public List<AbonoResponseDTO> listarAbonos() {
        return abonoRepository.findAll().stream()
                .map(abono -> AbonoResponseDTO.builder()
                        .idAbono(abono.getIdAbono())
                        .dniSocio(abono.getSocio().getDniUsuario())
                        .idTipoAbono(abono.getTipoAbono().getIdTipoAbono())
                        .fechaInicio(abono.getFechaInicio())
                        .fechaFin(abono.getFechaFin())
                        .estado(abono.getEstado())
                        .build())
                .collect(Collectors.toList());
    }

    public List<AbonoResponseDTO> obtenerAbonoPorSocio(String dniSocio) {
        return abonoRepository.findBySocio_DniUsuario(dniSocio).stream()
                .map(abono -> AbonoResponseDTO.builder()
                        .idAbono(abono.getIdAbono())
                        .dniSocio(abono.getSocio().getDniUsuario())
                        .idTipoAbono(abono.getTipoAbono().getIdTipoAbono())
                        .fechaInicio(abono.getFechaInicio())
                        .fechaFin(abono.getFechaFin())
                        .estado(abono.getEstado())
                        .build())
                .collect(Collectors.toList());
    }

    public void cancelarAbono(Long idAbono) {
        AbonoTemporada abono = abonoRepository.findById(idAbono)
                .orElseThrow(() -> new ResourceNotFoundException("Abono no encontrado"));

        if (abono.getEstado() == EstadoAbono.CANCELADO) {
            throw new BusinessRuleException("El abono ya está cancelado");
        }

        abono.setEstado(EstadoAbono.CANCELADO);
        abonoRepository.save(abono);
    }
}

