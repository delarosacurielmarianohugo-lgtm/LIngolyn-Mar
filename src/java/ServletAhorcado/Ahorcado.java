package ServletAhorcado;

import java.io.IOException;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/AhorcadoServlet")
public class Ahorcado extends HttpServlet {
    
    private final String[] PALABRAS = {"BEE", "BOARD", "MARIANO"};
    private final Random random = new Random();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // Si el usuario pide reiniciar o no hay partida activa, inicializamos el juego
        if (request.getParameter("reiniciar") != null || session.getAttribute("palabraSecreta") == null) {
            String palabraSecreta = PALABRAS[random.nextInt(PALABRAS.length)];
            
            session.setAttribute("palabraSecreta", palabraSecreta);
            session.setAttribute("errores", 0);
            
            // Creamos un arreglo de caracteres vacío para ir llenándolo conforme adivine
            char[] progreso = new char[palabraSecreta.length()];
            for (int i = 0; i < progreso.length; i++) {
                progreso[i] = '_'; // Inicialmente todo es un guion bajo
            }
            session.setAttribute("progreso", progreso);
            session.setAttribute("mensaje", "¡Buena suerte! Ingresa una letra.");
        }
        
        // Redirigimos al JSP para pintar el estado actual
        request.getRequestDispatcher("ahorcado.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String palabraSecreta = (String) session.getAttribute("palabraSecreta");
        char[] progreso = (char[]) session.getAttribute("progreso");
        Integer errores = (Integer) session.getAttribute("errores");
        
        if (palabraSecreta == null || progreso == null || errores == null) {
            response.sendRedirect("AhorcadoServlet");
            return;
        }

        // 1. Recibir la letra que ingresó el usuario
        String letraParam = request.getParameter("letraIntentada");
        if (letraParam != null && !letraParam.trim().isEmpty()) {
            char letra = letraParam.toUpperCase().trim().charAt(0);
            
            boolean acierto = false;
            // 2. Verificar si la letra existe en la palabra secreta
            for (int i = 0; i < palabraSecreta.length(); i++) {
                if (palabraSecreta.charAt(i) == letra) {
                    progreso[i] = letra; // Se revela la letra en el progreso
                    acierto = true;
                }
            }
            
            // 3. Si no acertó, sumamos un error
            if (!acierto) {
                errores++;
                session.setAttribute("errores", errores);
                session.setAttribute("mensaje", "La letra '" + letra + "' no está");
            } else {
                session.setAttribute("mensaje", "Acertaste la letra '" + letra + "'");
            }
            
            // 4. Comprobar condiciones de Fin de Juego
            String palabraActual = new String(progreso);
            if (palabraActual.equals(palabraSecreta)) {
                session.setAttribute("mensaje", "Ganaste Descubriste la palabra: " + palabraSecreta);
                // Opcional: limpiar sesión para obligar a reiniciar en el próximo clic
            } else if (errores >= 6) { // 6 errores máximos (Cabeza, tronco, 2 brazos, 2 piernas)
                session.setAttribute("mensaje", "Perdiste La palabra era: " + palabraSecreta);
            }
            
            session.setAttribute("progreso", progreso);
        }
        
        response.sendRedirect("AhorcadoServlet"); // Redirección limpia (pattern Post-Redirect-Get)
    }
}