package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.Administrador;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdministradorRepository extends JpaRepository<Administrador, String> {
}

