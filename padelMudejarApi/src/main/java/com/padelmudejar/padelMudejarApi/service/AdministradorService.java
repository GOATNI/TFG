package com.padelmudejar.padelMudejarApi.service;

import com.padelmudejar.padelMudejarApi.dto.administrador.AdministradorRequestDTO;
import com.padelmudejar.padelMudejarApi.dto.administrador.AdministradorResponseDTO;
import com.padelmudejar.padelMudejarApi.entity.Administrador;
import com.padelmudejar.padelMudejarApi.entity.Usuario;
import com.padelmudejar.padelMudejarApi.exception.BusinessRuleException;
import com.padelmudejar.padelMudejarApi.exception.ResourceNotFoundException;
import com.padelmudejar.padelMudejarApi.repository.AdministradorRepository;
import com.padelmudejar.padelMudejarApi.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class AdministradorService {

    private final AdministradorRepository administradorRepository;
    private final UsuarioRepository usuarioRepository;

    public AdministradorResponseDTO crearAdministrador(AdministradorRequestDTO adminRequestDTO) {
        // Validar que no existe un administrador con ese DNI
        if (administradorRepository.existsById(adminRequestDTO.getDniUsuario())) {
            throw new BusinessRuleException("Ya existe un administrador con este DNI");
        }

        // Crear usuario base
        Usuario usuario = Usuario.builder()
                .dniUsuario(adminRequestDTO.getDniUsuario())
                .nombre(adminRequestDTO.getNombre())
                .apellidos(adminRequestDTO.getApellidos())
                .edad(adminRequestDTO.getEdad())
                .telefono(adminRequestDTO.getTelefono())
                .build();

        usuarioRepository.save(usuario);

        // Crear administrador
        Administrador administrador = Administrador.builder()
                .dniUsuario(adminRequestDTO.getDniUsuario())
                .usuario(usuario)
                .activo(true)
                .idAdministrador(adminRequestDTO.getIdAdministrador())
                .build();

        Administrador adminGuardado = administradorRepository.save(administrador);
        return AdministradorResponseDTO.builder()
                .dniUsuario(adminGuardado.getDniUsuario())
                .nombre(adminGuardado.getUsuario().getNombre())
                .apellidos(adminGuardado.getUsuario().getApellidos())
                .edad(adminGuardado.getUsuario().getEdad())
                .telefono(adminGuardado.getUsuario().getTelefono())
                .activo(adminGuardado.isActivo())
                .idAdministrador(adminGuardado.getIdAdministrador())
                .build();
    }

    public AdministradorResponseDTO obtenerAdministrador(String dniUsuario) {
        Administrador administrador = administradorRepository.findById(dniUsuario)
                .orElseThrow(() -> new ResourceNotFoundException("Administrador no encontrado con DNI: " + dniUsuario));
        return AdministradorResponseDTO.builder()
                .dniUsuario(administrador.getDniUsuario())
                .nombre(administrador.getUsuario().getNombre())
                .apellidos(administrador.getUsuario().getApellidos())
                .edad(administrador.getUsuario().getEdad())
                .telefono(administrador.getUsuario().getTelefono())
                .activo(administrador.isActivo())
                .idAdministrador(administrador.getIdAdministrador())
                .build();
    }

    public List<AdministradorResponseDTO> listarAdministradores() {
        return administradorRepository.findAll().stream()
                .map(admin -> AdministradorResponseDTO.builder()
                        .dniUsuario(admin.getDniUsuario())
                        .nombre(admin.getUsuario().getNombre())
                        .apellidos(admin.getUsuario().getApellidos())
                        .edad(admin.getUsuario().getEdad())
                        .telefono(admin.getUsuario().getTelefono())
                        .activo(admin.isActivo())
                        .idAdministrador(admin.getIdAdministrador())
                        .build())
                .collect(Collectors.toList());
    }

    public void desactivarAdministrador(String dniUsuario) {
        Administrador administrador = administradorRepository.findById(dniUsuario)
                .orElseThrow(() -> new ResourceNotFoundException("Administrador no encontrado"));

        administrador.setActivo(false);
        administradorRepository.save(administrador);
    }
}

