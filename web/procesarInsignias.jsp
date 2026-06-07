<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Gestionar Insignias</title>
    </head>
    <body>
        <h1>Control de Insignias - Lingolyn</h1>
        
        <%@page import="java.sql.*, java.io.*" %>
        <%
            String insignia = request.getParameter("insigniaSeleccionada");
            String categoria = request.getParameter("categoria");
            String accion = request.getParameter("accion");
            
            Connection con = null;
            Statement st = null;
            ResultSet rs = null;
            
            try {
                // 1. Cargar el Driver (usa "com.mysql.jdbc.Driver" si tu conector es antiguo)
                Class.forName("com.mysql.cj.jdbc.Driver");
                
                // 2. Conexión a tu base de datos (asegúrate de que el nombre coincida)
        String url = "jdbc:mysql://localhost:3306/lingolyn_db?autoReconnect=true&useSSL=false&serverTimezone=UTC";
                con = DriverManager.getConnection(url, "root", "root");
                st = con.createStatement();
                
                // --- OPERACIÓN: AGREGAR (CREATE) ---
                if ("agregar".equals(accion)) {
                    // Validamos primero si ya está agregada en esa categoría para no duplicar
                    String buscar = "SELECT * FROM insignias_usuario WHERE insignia='" + insignia + "' AND categoria='" + categoria + "'";
                    rs = st.executeQuery(buscar);
                    
                    if (rs.next()) {
                        out.println("<script>alert('Esta insignia ya está en tu lista de " + categoria + "s.');</script>");
                    } else {
                        String insertar = "INSERT INTO insignias_usuario VALUES ('" + insignia + "', '" + categoria + "')";
                        st.executeUpdate(insertar);
                        out.println("<script>alert('Insignia \"" + insignia + "\" agregada como " + categoria + " con éxito.');</script>");
                    }
                } 
                
                // --- OPERACIÓN: ELIMINAR (DELETE) ---
                else if ("eliminar".equals(accion)) {
                    String borrar = "DELETE FROM insignias_usuario WHERE insignia='" + insignia + "' AND categoria='" + categoria + "'";
                    int filasAfectadas = st.executeUpdate(borrar);
                    
                    if (filasAfectadas > 0) {
                        out.println("<script>alert('Se quitó \"" + insignia + "\" de tus " + categoria + "s.');</script>");
                    } else {
                        out.println("<script>alert('Esa insignia no estaba en tu lista de " + categoria + "s.');</script>");
                    }
                } 
                
                // --- OPERACIÓN: CONSULTAR (READ) ---
                else if ("consultar".equals(accion)) {
                    out.println("<h2>Tus Listas Actuales:</h2>");
                    
                    String consultarTodo = "SELECT * FROM insignias_usuario ORDER BY categoria";
                    rs = st.executeQuery(consultarTodo);
                    
                    out.println("<table border='1' style='width:50%; text-align:left; border-collapse: collapse;'>");
                    out.println("<tr style='background-color:#f7a8b8; color:white;'><th>Insignia</th><th>Tipo / Categoría</th></tr>");
                    
                    int contador = 0;
                    while (rs.next()) {
                        contador++;
                        out.println("<tr>");
                        out.println("<td style='padding:8px;'>" + rs.getString("insignia") + "</td>");
                        out.println("<td style='padding:8px;'>" + rs.getString("categoria") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                    
                    if (contador == 0) {
                        out.println("<p>No tienes insignias guardadas en tus listas todavía.</p>");
                    }
                }
                
                // Cerrar flujos de forma segura si se usaron
                if(rs != null) rs.close();
                if(st != null) st.close();
                if(con != null) con.close();
                
            } catch(SQLException e) {
                out.print("Error en la Base de Datos: " + e.toString());
            } catch(ClassNotFoundException e) {
                out.print("Error: No se encontró el Driver JAR de MySQL. Recuerda agregarlo a la carpeta Libraries.");
            }
        %>
        
        <br><br>
        <a href="Insignias.html"><button style="padding:10px; cursor:pointer;">Volver a Insignias</button></a>
    </body>
</html>