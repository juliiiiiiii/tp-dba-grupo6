package ar.edu.unlam.parques.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DatabaseConfig {
    private static final Logger log = LoggerFactory.getLogger(DatabaseConfig.class);

    public static HikariDataSource createDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(envOrDefault("DB_URL", "jdbc:sqlserver://127.0.0.1:1433;databaseName=parques_nacionales;encrypt=true;trustServerCertificate=true;"));
        config.setUsername(envOrDefault("DB_USER", System.getenv("SQL_SERVER_USER")));
        config.setPassword(envOrDefault("DB_PASSWORD", System.getenv("SQL_SERVER_PASS")));
        config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        config.setMaximumPoolSize(5);
        config.setInitializationFailTimeout(-1);
        return new HikariDataSource(config);
    }

    private static String envOrDefault(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        return value;
    }
}
