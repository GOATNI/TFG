package com.padelmudejar.padelMudejarApi.service;

import com.padelmudejar.padelMudejarApi.dto.socio.SocioRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.socio.SocioResponseDTO;
import com.padelmudejar.padelMudejarApi.entity.Pago;
import com.padelmudejar.padelMudejarApi.entity.Socio;
import com.padelmudejar.padelMudejarApi.entity.Usuario;
import com.padelmudejar.padelMudejarApi.exception.BusinessRuleException;
import com.padelmudejar.padelMudejarApi.exception.ResourceNotFoundException;
import com.padelmudejar.padelMudejarApi.repository.SocioRepository;
import com.padelmudejar.padelMudejarApi.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class SocioService {


    private final SocioRepository socioRepository;
    private final UsuarioRepository usuarioRepository;

    public SocioResponseDTO crearSocio(SocioRequestDTO socioRequestDTO) {
        // Validar que no existe un socio con ese DNI
        if (socioRepository.existsById(socioRequestDTO.getDniUsuario())) {
            throw new BusinessRuleException("Ya existe un socio con este DNI");
        }

        // Validar email único
        if (socioRepository.findByCorreoElectronico(socioRequestDTO.getCorreoElectronico()) != null) {
            throw new BusinessRuleException("El correo electrónico ya está en uso");
        }

        // Crear usuario base
        Usuario usuario = Usuario.builder()
                .dniUsuario(socioRequestDTO.getDniUsuario())
                .nombre(socioRequestDTO.getNombre())
                .apellidos(socioRequestDTO.getApellidos())
                .edad(socioRequestDTO.getEdad())
                .telefono(socioRequestDTO.getTelefono())
                .build();

        usuarioRepository.save(usuario);

        // Crear socio
        Socio socio = Socio.builder()
                .dniUsuario(socioRequestDTO.getDniUsuario())
                .usuario(usuario)
                .correoElectronico(socioRequestDTO.getCorreoElectronico())
                .idCarnet(socioRequestDTO.getIdCarnet())
                .build();

        Socio socioGuardado = socioRepository.save(socio);
        return SocioResponseDTO.builder()
                .dniUsuario(socioGuardado.getDniUsuario())
                .nombre(socioGuardado.getUsuario().getNombre())
                .apellidos(socioGuardado.getUsuario().getApellidos())
                .edad(socioGuardado.getUsuario().getEdad())
                .telefono(socioGuardado.getUsuario().getTelefono())
                .correoElectronico(socioGuardado.getCorreoElectronico())
                .idCarnet(socioGuardado.getIdCarnet())
                .idPago(socioGuardado.getPago().getIdPago())
                .build();
    }

    public SocioResponseDTO obtenerSocio(String dniUsuario) {
        Socio socio = socioRepository.findById(dniUsuario)
                .orElseThrow(() -> new ResourceNotFoundException("Socio no encontrado con DNI: " + dniUsuario));
        return SocioResponseDTO.builder()
                .dniUsuario(socio.getDniUsuario())
                .nombre(socio.getUsuario().getNombre())
                .apellidos(socio.getUsuario().getApellidos())
                .edad(socio.getUsuario().getEdad())
                .telefono(socio.getUsuario().getTelefono())
                .correoElectronico(socio.getCorreoElectronico())
                .idCarnet(socio.getIdCarnet())
                .idPago(socio.getPago().getIdPago())
                .build();
    }

    public List<SocioResponseDTO> listarSocios() {
        return socioRepository.findAll().stream()
                .map(socio -> SocioResponseDTO.builder()
                        .dniUsuario(socio.getDniUsuario())
                        .nombre(socio.getUsuario().getNombre())
                        .apellidos(socio.getUsuario().getApellidos())
                        .edad(socio.getUsuario().getEdad())
                        .telefono(socio.getUsuario().getTelefono())
                        .correoElectronico(socio.getCorreoElectronico())
                        .idCarnet(socio.getIdCarnet())
                        .idPago(socio.getPago().getIdPago())
                        .build())
                .collect(Collectors.toList());
    }

    public SocioResponseDTO actualizarSocio(String dniUsuario, SocioRequestDTO socioRequestDTO) {
        Socio socio = socioRepository.findById(dniUsuario)
                .orElseThrow(() -> new ResourceNotFoundException("Socio no encontrado con DNI: " + dniUsuario));

        // Actualizar usuario
        Usuario usuario = socio.getUsuario();
        usuario.setNombre(socioRequestDTO.getNombre());
        usuario.setApellidos(socioRequestDTO.getApellidos());
        usuario.setEdad(socioRequestDTO.getEdad());
        usuario.setTelefono(socioRequestDTO.getTelefono());
        usuarioRepository.save(usuario);

        // Actualizar socio
        socio.setCorreoElectronico(socioRequestDTO.getCorreoElectronico());
        socio.setIdCarnet(socioRequestDTO.getIdCarnet());
        Socio socioActualizado = socioRepository.save(socio);

        return SocioResponseDTO.builder()
                .dniUsuario(socioActualizado.getDniUsuario())
                .nombre(socioActualizado.getUsuario().getNombre())
                .apellidos(socioActualizado.getUsuario().getApellidos())
                .edad(socioActualizado.getUsuario().getEdad())
                .telefono(socioActualizado.getUsuario().getTelefono())
                .correoElectronico(socioActualizado.getCorreoElectronico())
                .idCarnet(socioActualizado.getIdCarnet())
                .idPago(socioActualizado.getPago().getIdPago())
                .build();
    }

    public void eliminarSocio(String dniUsuario) {
        Socio socio = socioRepository.findById(dniUsuario)
                .orElseThrow(() -> new ResourceNotFoundException("Socio no encontrado con DNI: " + dniUsuario));
        socioRepository.delete(socio);
    }
}

