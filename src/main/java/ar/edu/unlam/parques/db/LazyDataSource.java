package ar.edu.unlam.parques.db;

import ar.edu.unlam.parques.config.DatabaseConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.SQLFeatureNotSupportedException;
import java.util.logging.Logger;

public class LazyDataSource implements DataSource, AutoCloseable {
    private static HikariDataSource delegate;

    public LazyDataSource() {
        if (delegate == null) {
            delegate = DatabaseConfig.createDataSource();
        }
    }

    @Override
    public Connection getConnection() throws SQLException {
        return this.delegate.getConnection();
    }

    @Override
    public Connection getConnection(String username, String password) throws SQLException {
        return this.delegate.getConnection(username, password);
    }

    @Override
    public PrintWriter getLogWriter() throws SQLException {
        return this.delegate.getLogWriter();
    }

    @Override
    public void setLogWriter(PrintWriter out) throws SQLException {
        this.delegate.setLogWriter(out);
    }

    @Override
    public void setLoginTimeout(int seconds) throws SQLException {
        this.delegate.setLoginTimeout(seconds);
    }

    @Override
    public int getLoginTimeout() throws SQLException {
        return this.delegate.getLoginTimeout();
    }

    @Override
    public Logger getParentLogger() throws SQLFeatureNotSupportedException {
        return Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    }

    @Override
    public <T> T unwrap(Class<T> iface) throws SQLException {
        return this.delegate.unwrap(iface);
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) throws SQLException {
        return this.delegate.isWrapperFor(iface);
    }

    @Override
    public void close() {
        if (delegate != null) {
            delegate.close();
        }
    }
}
