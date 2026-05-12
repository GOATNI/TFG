package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.AbonoTemporada;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface AbonoTemporadaRepository extends JpaRepository<AbonoTemporada, Long> {
    List<AbonoTemporada> findBySocio_DniUsuario(String dniSocio);
}

