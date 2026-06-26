package ar.edu.unlam.parques.repository;

import ar.edu.unlam.parques.model.ParqueForm;
import ar.edu.unlam.parques.model.ParqueItem;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ParqueRepository {
    private final DataSource dataSource;

    public ParqueRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void alta(ParqueForm parque) throws SQLException {
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{call gestion.parque_alta(?, ?, ?, ?)}")) {
            statement.setString(1, parque.nombre());
            statement.setString(2, parque.tipo());
            statement.setString(3, parque.ubicacion());
            statement.setInt(4, parque.superficie());
            statement.execute();
        }
    }

    //TODO: el store procedure recibe el id? deberia ir por nombre
    public void baja(int id) throws SQLException {
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{call gestion.parque_baja(?)}")) {
            statement.setInt(1, id);
            statement.execute();
        }
    }

    // TODO: modificar esto por id deberia ir? entonces deberia poder listarlo y gaurdar eso en el front en algun form
    public void modificar(ParqueForm parque) throws SQLException {
        try (Connection connection = dataSource.getConnection();
             CallableStatement statement = connection.prepareCall("{call gestion.parque_modificacion(?, ?, ?, ?, ?)}")) {
            statement.setInt(1, parque.id());
            statement.setString(2, parque.nombre());
            statement.setString(3, parque.tipo());
            statement.setString(4, parque.ubicacion());
            statement.setInt(5, parque.superficie());
            statement.execute();
        }
    }

    public List<ParqueItem> listarActivos() throws SQLException {
        String sql = """
                SELECT p.id, p.nombre, p.tipo, u.provincia AS ubicacion, p.superficie
                FROM gestion.Parque p
                LEFT JOIN gestion.Ubicacion u ON u.id = p.id_ubicacion
                WHERE p.estado = 'Activo'
                ORDER BY p.nombre
                """;
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            List<ParqueItem> parques = new ArrayList<>();
            while (resultSet.next()) {
                parques.add(new ParqueItem(
                        resultSet.getInt("id"),
                        resultSet.getString("nombre"),
                        resultSet.getString("tipo"),
                        resultSet.getString("ubicacion"),
                        resultSet.getInt("superficie")
                ));
            }
            return parques;
        }
    }
}
