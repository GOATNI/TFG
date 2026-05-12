package com.padelmudejar.padelMudejarApi.repository;

import com.padelmudejar.padelMudejarApi.entity.Reserva;
import com.padelmudejar.padelMudejarApi.enums.EstadoReserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReservaRepository extends JpaRepository<Reserva, Long> {
    List<Reserva> findBySocio_DniUsuario(String dniSocio);
    List<Reserva> findByInstalacion_IdInstalacion(String idInstalacion);
    List<Reserva> findByFechaHoraBetween(LocalDateTime inicio, LocalDateTime fin);
    List<Reserva> findByEstadoReserva(EstadoReserva estado);
}

