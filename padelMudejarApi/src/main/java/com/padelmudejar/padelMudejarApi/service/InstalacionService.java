package com.padelmudejar.padelMudejarApi.service;

import com.padelmudejar.padelMudejarApi.dto.instalacion.AsignacionTecnicoDTO;
import com.padelmudejar.padelMudejarApi.dto.instalacion.CambioEstadoDTO;
import com.padelmudejar.padelMudejarApi.dto.instalacion.InstalacionResponseDTO;
import com.padelmudejar.padelMudejarApi.entity.Instalacion;
import com.padelmudejar.padelMudejarApi.entity.TecnicoMantenimiento;
import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import com.padelmudejar.padelMudejarApi.exception.BusinessRuleException;
import com.padelmudejar.padelMudejarApi.exception.ResourceNotFoundException;
import com.padelmudejar.padelMudejarApi.repository.InstalacionRepository;
import com.padelmudejar.padelMudejarApi.repository.TecnicoMantenimientoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class InstalacionService {

    private final InstalacionRepository instalacionRepository;
    private final TecnicoMantenimientoRepository tecnicoRepository;

    public InstalacionResponseDTO obtenerInstalacion(String idInstalacion) {
        Instalacion instalacion = instalacionRepository.findById(idInstalacion)
                .orElseThrow(() -> new ResourceNotFoundException("Instalación no encontrada"));
        return InstalacionResponseDTO.builder()
                .idInstalacion(instalacion.getIdInstalacion())
                .dniTecnico(instalacion.getTecnico() != null ? instalacion.getTecnico().getDniUsuario() : null)
                .estadoPista(instalacion.getEstadoPista())
                .ubicacion(instalacion.getUbicacion())
                .build();
    }

    public List<InstalacionResponseDTO> listarInstalaciones() {
        return instalacionRepository.findAll().stream()
                .map(inst -> InstalacionResponseDTO.builder()
                        .idInstalacion(inst.getIdInstalacion())
                        .dniTecnico(inst.getTecnico() != null ? inst.getTecnico().getDniUsuario() : null)
                        .estadoPista(inst.getEstadoPista())
                        .ubicacion(inst.getUbicacion())
                        .build())
                .collect(Collectors.toList());
    }

    public List<InstalacionResponseDTO> listarPorEstado(EstadoPista estado) {
        return instalacionRepository.findByEstadoPista(estado).stream()
                .map(inst -> InstalacionResponseDTO.builder()
                        .idInstalacion(inst.getIdInstalacion())
                        .dniTecnico(inst.getTecnico() != null ? inst.getTecnico().getDniUsuario() : null)
                        .estadoPista(inst.getEstadoPista())
                        .ubicacion(inst.getUbicacion())
                        .build())
                .collect(Collectors.toList());
    }

    public InstalacionResponseDTO cambiarEstado(String idInstalacion, CambioEstadoDTO cambioDTO) {
        Instalacion instalacion = instalacionRepository.findById(idInstalacion)
                .orElseThrow(() -> new ResourceNotFoundException("Instalación no encontrada"));

        if (cambioDTO.getNuevoEstado() == null) {
            throw new BusinessRuleException("El nuevo estado no puede ser nulo");
        }

        instalacion.setEstadoPista(cambioDTO.getNuevoEstado());
        Instalacion instalacionActualizada = instalacionRepository.save(instalacion);
        return InstalacionResponseDTO.builder()
                .idInstalacion(instalacionActualizada.getIdInstalacion())
                .dniTecnico(instalacionActualizada.getTecnico() != null ? instalacionActualizada.getTecnico().getDniUsuario() : null)
                .estadoPista(instalacionActualizada.getEstadoPista())
                .ubicacion(instalacionActualizada.getUbicacion())
                .build();
    }

    public InstalacionResponseDTO asignarTecnico(String idInstalacion, AsignacionTecnicoDTO asignacionDTO) {
        Instalacion instalacion = instalacionRepository.findById(idInstalacion)
                .orElseThrow(() -> new ResourceNotFoundException("Instalación no encontrada"));

        TecnicoMantenimiento tecnico = tecnicoRepository.findById(asignacionDTO.getDniTecnico())
                .orElseThrow(() -> new ResourceNotFoundException("Técnico no encontrado"));

        instalacion.setTecnico(tecnico);
        Instalacion instalacionActualizada = instalacionRepository.save(instalacion);
        return InstalacionResponseDTO.builder()
                .idInstalacion(instalacionActualizada.getIdInstalacion())
                .dniTecnico(instalacionActualizada.getTecnico() != null ? instalacionActualizada.getTecnico().getDniUsuario() : null)
                .estadoPista(instalacionActualizada.getEstadoPista())
                .ubicacion(instalacionActualizada.getUbicacion())
                .build();
    }
}

