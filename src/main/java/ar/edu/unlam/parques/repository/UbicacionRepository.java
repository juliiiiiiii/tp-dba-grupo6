package ar.edu.unlam.parques.repository;

import ar.edu.unlam.parques.model.UbicacionItem;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UbicacionRepository {
    private static final String ALTA_UBICACION = "EXEC ubicacion_alta(?)";
    private final DataSource dataSource;

    public UbicacionRepository(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    public void alta(String nombre) throws SQLException {
        try(Connection con = dataSource.getConnection(); CallableStatement stat = con.prepareCall(ALTA_UBICACION)) {
            stat.setString(1, nombre);
            stat.execute();
        }
    }

    public List<UbicacionItem> listar() throws SQLException {
        String sql = """
                SELECT id, provincia
                FROM gestion.Ubicacion
                ORDER BY provincia
                """;
        try (Connection connection = dataSource.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            List<UbicacionItem> ubicaciones = new ArrayList<>();
            while (resultSet.next()) {
                ubicaciones.add(new UbicacionItem(
                        resultSet.getInt("id"),
                        resultSet.getString("provincia")
                ));
            }
            return ubicaciones;
        }
    }
}
