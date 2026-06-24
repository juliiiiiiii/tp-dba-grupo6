package ar.edu.unlam.parques.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

public class DatabaseConfig {
    public static HikariDataSource createDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(envOrDefault("DB_URL", "jdbc:sqlserver://localhost:1433;databaseName=parques_nacionales;encrypt=true;trustServerCertificate=true"));
        config.setUsername(envOrDefault("DB_USER", "sa"));
        config.setPassword(envOrDefault("DB_PASSWORD", ""));
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
