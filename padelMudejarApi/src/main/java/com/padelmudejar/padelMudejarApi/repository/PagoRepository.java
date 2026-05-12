package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.Pago;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PagoRepository extends JpaRepository<Pago, Long> {
}

