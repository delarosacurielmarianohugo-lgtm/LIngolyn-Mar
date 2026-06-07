<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lingolyn - Validando Insignia</title>
  <link rel="stylesheet" href="estilos.css">
  <style>
    .main { position: relative; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 40px 20px; min-height: 60vh; box-sizing: border-box; }
    .felicitacion-container { display: flex; flex-direction: column; align-items: center; text-align: center; gap: 20px; width: 100%; max-width: 650px; }
    .texto-validacion { font-size: 24px; color: #555; margin: 0; font-style: italic; }
    .texto-felicidades { font-size: 26px; color: #27ae60; margin: 0 0 10px 0; font-weight: bold; }
    .texto-bloqueado { font-size: 26px; color: #c0392b; margin: 0 0 10px 0; font-weight: bold; }
    .box-globos { width: 180px; height: auto; margin: 10px 0; }
    .box-globos img { width: 100%; height: auto; display: block; object-fit: contain; }
    .texto-continua { font-size: 24px; color: #000; margin: 10px 0 10px 0; }
    .btn-regresar { background: #f7a8b8; color: #fff; border: 1px solid #000; padding: 12px 65px; font-size: 18px; cursor: pointer; border-radius: 4px; font-weight: bold; transition: background 0.2s; }
    .btn-regresar:hover { background: #e593a3; }
    .bloqueada { filter: grayscale(100%) opacity(30%); }
  </style>
</head>
<body>
  <div>
    <div class="rosa"><img src="logo.png" alt="Abeja"><h1>Lingolyn</h1></div>
    <div class="navbar">
      <a href="registro.html">LOGIN</a><a href="perfil.html">PERFIL</a><a href="administrar.html">ADMINISTRAR</a>
      <a href="Insignias.jsp">INSIGNIAS</a><a href="basedeaprendizaje.html">BASE DE APRENDIZAJE</a>
      <a href="vocabulario.html">VOCABULARIO</a><a href="ahorcado.jsp">AHORCADO</a>
      <a href="tradicional.html">MODALIDAD TRADICIONAL</a><a href="precision.jsp">PRECISION</a>
    </div>
  </div>

  <%
    String usuarioIngresado = request.getParameter("txtUsuario");
    boolean usuarioExiste = false;
    boolean tieneLogros = false;
    
    // Variables para calcular los requerimientos de la BD
    int totalPracticas = 0;
    int acumuladoAciertos = 0;
    boolean rachaPerfecta = false;
    int palabrasGlosario = 0;
    int palabrasPropias = 0;
    boolean configTiempo = false;

    if (usuarioIngresado != null && !usuarioIngresado.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/lingolyn_db?autoReconnect=true&useSSL=false&serverTimezone=UTC";
            Connection con = DriverManager.getConnection(url, "root", "root");

            // 1. Conseguir el id_usuario basándose en el username ingresado
            String queryUser = "SELECT id_usuario FROM usuarios WHERE username = ?";
            PreparedStatement psUser = con.prepareStatement(queryUser);
            psUser.setString(1, usuarioIngresado.trim());
            ResultSet rsUser = psUser.executeQuery();
            
            if (rsUser.next()) {
                int idUsuario = rsUser.getInt("id_usuario");
                usuarioExiste = true;

                // 2. Extraer sus estadísticas de la BD
                String queryStats = "SELECT COUNT(*) as total, SUM(aciertos) as sum_aciertos FROM resumen_practicas WHERE id_usuario = ?";
                PreparedStatement ps1 = con.prepareStatement(queryStats);
                ps1.setInt(1, idUsuario);
                ResultSet rs1 = ps1.executeQuery();
                if(rs1.next()){
                    totalPracticas = rs1.getInt("total");
                    acumuladoAciertos = rs1.getInt("sum_aciertos");
                }
                rs1.close(); ps1.close();

                String queryPerfecta = "SELECT id_practica FROM resumen_practicas WHERE id_usuario = ? AND errores = 0 AND aciertos > 0 LIMIT 1";
                PreparedStatement ps2 = con.prepareStatement(queryPerfecta);
                ps2.setInt(1, idUsuario);
                ResultSet rs2 = ps2.executeQuery();
                if(rs2.next()){ rachaPerfecta = true; }
                rs2.close(); ps2.close();

                String queryGlosario = "SELECT COUNT(*) as total FROM glosario_apoyo WHERE id_usuario = ?";
                PreparedStatement ps3 = con.prepareStatement(queryGlosario);
                ps3.setInt(1, idUsuario);
                ResultSet rs3 = ps3.executeQuery();
                if(rs3.next()){ palabrasGlosario = rs3.getInt("total"); }
                rs3.close(); ps3.close();

                String queryVocab = "SELECT COUNT(*) as total FROM vocabulario WHERE id_usuario = ?";
                PreparedStatement ps4 = con.prepareStatement(queryVocab);
                ps4.setInt(1, idUsuario);
                ResultSet rs4 = ps4.executeQuery();
                if(rs4.next()){ palabrasPropias = rs4.getInt("total"); }
                rs4.close(); ps4.close();

                String queryTiempo = "SELECT id_config FROM configuracion_tiempo WHERE id_usuario = ? LIMIT 1";
                PreparedStatement ps5 = con.prepareStatement(queryTiempo);
                ps5.setInt(1, idUsuario);
                ResultSet rs5 = ps5.executeQuery();
                if(rs5.next()){ configTiempo = true; }
                rs5.close(); ps5.close();

                // Evaluamos si el usuario cumple al menos una de las condiciones
                if (rachaPerfecta || totalPracticas >= 5 || palabrasGlosario > 0 || acumuladoAciertos >= 50 || palabrasPropias > 0 || configTiempo) {
                    tieneLogros = true;
                }
            }
            rsUser.close(); psUser.close(); con.close();
        } catch (Exception e) {
            System.out.println("Error validando insignias: " + e.getMessage());
        }
    }
    
  <%

  <div class="main">
    <div class="felicitacion-container">
      <h3 class="texto-validacion">Análisis de cuenta para: <strong><%= usuarioIngresado %></strong></h3>
      
      <% if (!usuarioExiste) { %>
          <h2 class="texto-bloqueado">¡Usuario no encontrado!</h2>
          <div class="box-globos"><img src="globos.png" class="bloqueada" alt="No conseguido"></div>
          <p class="texto-continua">Asegúrate de escribir correctamente tu credencial de Lingolyn.</p>
          <button class="btn-regresar" onclick="window.location.href='datos.jsp';">Intentar de nuevo</button>
          
      <% } else if (tieneLogros) { %>
          <h2 class="texto-felicidades">¡Felicidades! Tienes insignias desbloqueadas en tu perfil</h2>
          <div class="box-globos"><img src="globos.png" alt="Globos de celebración"></div>
          <p class="texto-continua">Sigue practicando en las dinámicas de estudio.</p>
          <button class="btn-regresar" onclick="window.location.href='Insignias.jsp';">Ver mis insignias</button>
          
      <% } else { %>
          <h2 class="texto-bloqueado">Aún no cumples los retos necesarios</h2>
          <div class="box-globos"><img src="globos.png" class="bloqueada" alt="Bloqueado"></div>
          <p class="texto-continua">Entra al Ahorcado o a Precisión para acumular tus primeros puntos.</p>
          <button class="btn-regresar" onclick="window.location.href='Insignias.jsp';">Regresar</button>
      <% } %>
      
    </div>
  </div>
  <div class="footer-simple"></div>
</body>
</html>