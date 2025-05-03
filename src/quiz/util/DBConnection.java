package quiz.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String URL = "jdbc:mysql://localhost:3306/quiz_db";
    private static final String USER = "root";
    private static final String PASSWORD = "";
    private static boolean driverLoaded = false;
    
    public static Connection getConnection() throws SQLException {
        if (!driverLoaded) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                driverLoaded = true;
            } catch (ClassNotFoundException e) {
                throw new SQLException("MySQL JDBC Driver tidak ditemukan. Pastikan mysql-connector-j-9.2.0.jar ada di /WEB-INF/lib", e);
            }
        }
        
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            if (conn == null) {
                throw new SQLException("Tidak dapat membuat koneksi database");
            }
            return conn;
        } catch (SQLException e) {
            throw new SQLException("Error koneksi database: " + e.getMessage() + 
                "\nPastikan:\n" +
                "1. MySQL server sudah running\n" +
                "2. Database quiz_db sudah dibuat\n" +
                "3. User 'root' dengan password kosong memiliki akses", e);
        }
    }
}