package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.Instalacion;
import com.padelmudejar.padelMudejarApi.enums.EstadoPista;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InstalacionRepository extends JpaRepository<Instalacion, String> {
    List<Instalacion> findByEstadoPista(EstadoPista estado);
}

