package ar.edu.unlam.parques.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DatabaseConfig {
    private static final Logger log = LoggerFactory.getLogger(DatabaseConfig.class);

    public static HikariDataSource createDataSource() {
        HikariConfig config = new HikariConfig();
        System.out.println("[SqlServer] Conecting....");
        config.setJdbcUrl(envOrDefault("DB_URL", "jdbc:sqlserver://127.0.0.1:1433;databaseName=parques_nacionales;encrypt=true;trustServerCertificate=true;"));
        config.setUsername(envOrDefault("DB_USER", "java")); //TODO: -> env var de esto
        config.setPassword(envOrDefault("DB_PASSWORD", "1234")); // TODO: env var de eso
        config.setDriverClassName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        config.setMaximumPoolSize(5);
        config.setInitializationFailTimeout(-1);
        System.out.println("[SqlServer] conected");
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
