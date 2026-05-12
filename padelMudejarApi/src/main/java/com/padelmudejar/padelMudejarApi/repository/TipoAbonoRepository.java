package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.TipoAbono;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TipoAbonoRepository extends JpaRepository<TipoAbono, Long> {
    TipoAbono findByNombre(String nombre);
}

