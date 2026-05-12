package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.Socio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SocioRepository extends JpaRepository<Socio, String> {
    Socio findByCorreoElectronico(String correoElectronico);
}

