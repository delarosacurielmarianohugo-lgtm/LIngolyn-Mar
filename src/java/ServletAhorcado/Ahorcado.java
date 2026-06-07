package ServletAhorcado;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AhorcadoServlet")
public class Ahorcado extends HttpServlet {
    
    private final String DB_URL ="jdbc:mysql://" + "localhost:3306/emps?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    private final String DB_USER = "root";
    private final String DB_PASS = "root";
    private String obtenerPalabraDeBaseDeDatos() {
        String palabra = "LINGOLYN";
        
        String query = "SELECT palabra FROM palabras ORDER BY RAND() LIMIT 1"; 
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            
            // Establecer la conexión y ejecutar la consulta
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement(query);
                 ResultSet rs = ps.executeQuery()) {
                
                if (rs.next()) {
                    // Extrae la palabra, la limpia de espacios y la pasa a mayúsculas
                    palabra = rs.getString("palabra").toUpperCase().trim();
                }
            }
        } catch (ClassNotFoundException e) {
            System.out.println("ERROR: No se encontró el conector de MySQL (.jar): " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("ERROR SQL: Verifica tu base de datos, tabla o puerto: " + e.getMessage());
        }
        
        return palabra;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Si el usuario presiona reiniciar o entra por primera vez
        if (request.getParameter("reiniciar") != null || session.getAttribute("palabraSecreta") == null) {
            
            // Vamos a traer la palabra directamente de MySQL
            String palabraSecreta = obtenerPalabraDeBaseDeDatos();
            
            session.setAttribute("palabraSecreta", palabraSecreta);
            session.setAttribute("errores", 0);
            
            // Creamos las casillas dinámicas basadas estrictamente en la longitud de la palabra
            char[] progreso = new char[palabraSecreta.length()];
            for (int i = 0; i < progreso.length; i++) {
                progreso[i] = '_';
            }
            session.setAttribute("progreso", progreso);
            session.setAttribute("mensaje", "¡Buena suerte! Ingresa una letra.");
        }
        
        // Enviamos el control al JSP para que dibuje la pantalla
        request.getRequestDispatcher("ahorcado.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String palabraSecreta = (String) session.getAttribute("palabraSecreta");
        char[] progreso = (char[]) session.getAttribute("progreso");
        Integer errores = (Integer) session.getAttribute("errores");
        
        // Parche de seguridad por si expira la sesión a mitad del juego
        if (palabraSecreta == null || progreso == null || errores == null) {
            response.sendRedirect("AhorcadoServlet");
            return;
        }

        // Procesar la letra que el usuario escribió
        String letraParam = request.getParameter("letraIntentada");
        if (letraParam != null && !letraParam.trim().isEmpty()) {
            char letra = letraParam.toUpperCase().trim().charAt(0);
            
            boolean acierto = false;
            // Recorrer la palabra secreta para ver si coincide con la letra ingresada
            for (int i = 0; i < palabraSecreta.length(); i++) {
                if (palabraSecreta.charAt(i) == letra) {
                    progreso[i] = letra; // Revelamos la letra en su posición exacta
                    acierto = true;
                }
            }
            
            // Si la letra no estaba en la palabra, sumamos un fallo a la horca
            if (!acierto) {
                errores++;
                session.setAttribute("errores", errores);
                session.setAttribute("mensaje", "La letra '" + letra + "' no está");
            } else {
                session.setAttribute("mensaje", "Acertaste la letra '" + letra + "'");
            }
            
            // Verificar si el estado del juego cambió a ganar o perder
            String palabraActual = new String(progreso);
            if (palabraActual.equals(palabraSecreta)) {
                session.setAttribute("mensaje", "Ganaste Descubriste la palabra: " + palabraSecreta);
            } else if (errores >= 6) {
                session.setAttribute("mensaje", "Perdiste La palabra era: " + palabraSecreta);
            }
            
            session.setAttribute("progreso", progreso);
        }
        
        // Redirección limpia al doGet para actualizar la interfaz
        response.sendRedirect("AhorcadoServlet");
    }
}