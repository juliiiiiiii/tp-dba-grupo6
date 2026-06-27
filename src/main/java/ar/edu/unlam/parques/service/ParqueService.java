package ar.edu.unlam.parques.service;

import ar.edu.unlam.parques.model.ParqueForm;
import ar.edu.unlam.parques.model.ParqueItem;
import ar.edu.unlam.parques.model.UbicacionItem;
import ar.edu.unlam.parques.repository.ParqueRepository;
import ar.edu.unlam.parques.repository.UbicacionRepository;

import java.sql.SQLException;
import java.util.List;

public class ParqueService {
    private final ParqueRepository parqueRepository;
    private final UbicacionRepository ubicacionRepository;

    public ParqueService(ParqueRepository parqueRepository, UbicacionRepository ubicacionRepository) {
        this.parqueRepository = parqueRepository;
        this.ubicacionRepository = ubicacionRepository;
    }

    public void alta(ParqueForm parque) throws SQLException {
        parqueRepository.alta(parque);
    }

    public void baja(int id) throws SQLException {
        parqueRepository.baja(id);
    }

    public void modificar(ParqueForm parque) throws SQLException {
        parqueRepository.modificar(parque);
    }

    public void altaUbicacion() {
    }

    public List<ParqueItem> listarActivos() throws SQLException {
        return parqueRepository.listarActivos();
    }

    public List<UbicacionItem> listarUbicaciones() throws SQLException {
        return ubicacionRepository.listar();
    }
}
