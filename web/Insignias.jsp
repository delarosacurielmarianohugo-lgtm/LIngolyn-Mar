<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lingolyn - Insignias</title>
  
  <link rel="stylesheet" href="estilos.css">

  <style>
    .insignias-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
      max-width: 900px;
      margin: 0 auto;
      gap: 25px;
    }

    .titulo-insignias {
      font-size: 28px;
      font-weight: normal;
      color: #000;
      margin: 10px 0 10px 0;
      text-align: center;
    }

    .grid-insignias {
      display: grid;
      grid-template-columns: repeat(3, 1fr); 
      gap: 30px 40px;                                     
      justify-items: center;                  
      align-items: center;
      width: 100%;
      margin-bottom: 15px;
    }

    .box-insignia {
      width: 100%;
      max-width: 220px;                      
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      text-align: center;
      font-family: Arial, sans-serif;
    }

    /* Control de las imágenes */
    .box-insignia img {
      width: 100%;
      height: auto;
      display: block;
      object-fit: contain;
      cursor: pointer;
      transition: transform 0.2s ease;
    }

    /* Filtro para poner en blanco y negro las insignias que no se han cumplido */
    .bloqueada {
      filter: grayscale(100%) opacity(40%);
    }

    .box-insignia img:hover {
      transform: scale(1.05);
    }

    .status-tag {
      font-size: 12px;
      margin-top: 8px;
      font-weight: bold;
      padding: 4px 12px;
      border-radius: 12px;
      color: #000;
      border: 1px solid rgba(0,0,0,0.1);
    }

    .btn-aceptar {
      background: #f7a8b8; 
      color: #fff;
      border: 1px solid #000;
      padding: 12px 65px;
      font-size: 22px;
      cursor: pointer;
      border-radius: 4px;
      font-weight: bold;
      transition: background 0.2s;
    }

    .btn-aceptar:hover {
      background: #e593a3;
    }

    @media (max-width: 768px) {
      .grid-insignias { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 480px) {
      .grid-insignias { grid-template-columns: 1fr; }
    }

    /* --- ESTILOS PARA LA ADMINISTRACIÓN (CRUD) --- */
    .crud-panel {
      width: 100%;
      background-color: #f9f9f9;
      border: 2px dashed #f7a8b8;
      border-radius: 8px;
      padding: 20px;
      margin-top: 15px;
      box-sizing: border-box;
      text-align: center;
    }

    .crud-title {
      font-size: 22px;
      color: #333;
      margin-bottom: 15px;
      font-weight: bold;
    }

    .form-group { margin-bottom: 15px; }

    .form-group label {
      font-size: 16px;
      margin: 0 10px;
      cursor: pointer;
    }

    .select-style {
      padding: 8px;
      font-size: 16px;
      width: 250px;
      border-radius: 4px;
      border: 1px solid #ccc;
    }

    .btn-crud {
      background: #bae1ff;
      color: #000;
      border: 1px solid #000;
      padding: 10px 30px;
      font-size: 16px;
      cursor: pointer;
      border-radius: 4px;
      font-weight: bold;
      margin: 5px;
      transition: background 0.2s;
    }

    .btn-crud:hover { background: #a2cfec; }
  </style>
</head>
<body>

  <%
    // Recuperamos el ID del usuario de la sesión. Si está vacío, por defecto usamos el 1 para pruebas.
    Integer idUsuario = (Integer) session.getAttribute("id_usuario");
    if (idUsuario == null) {
        idUsuario = 1; 
    }

    // Inicializamos las variables que contarán los logros desde la BD
    int totalPracticas = 0;
    int acumuladoAciertos = 0;
    boolean rachaPerfecta = false;
    int palabrasGlosario = 0;
    int palabrasPropias = 0;
    boolean configTiempo = false;

    // Bloque de conexión JDBC a lingolyn_db
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/lingolyn_db?autoReconnect=true&useSSL=false&serverTimezone=UTC";
        
        // Recuerda ajustar el usuario y contraseña ("root", "root") según los de tu entorno local
        Connection con = DriverManager.getConnection(url, "root", "root");
        
        // 1. Estadísticas básicas (Para Leyenda del Panal y Recolector de Miel)
        String queryStats = "SELECT COUNT(*) as total, SUM(aciertos) as sum_aciertos FROM resumen_practicas WHERE id_usuario = ?";
        PreparedStatement ps1 = con.prepareStatement(queryStats);
        ps1.setInt(1, idUsuario);
        ResultSet rs1 = ps1.executeQuery();
        if(rs1.next()){
            totalPracticas = rs1.getInt("total");
            acumuladoAciertos = rs1.getInt("sum_aciertos");
        }
        rs1.close(); ps1.close();

        // 2. Buscar prácticas sin errores (Para Memoria de Elefante)
        String queryPerfecta = "SELECT id_practica FROM resumen_practicas WHERE id_usuario = ? AND errores = 0 AND aciertos > 0 LIMIT 1";
        PreparedStatement ps2 = con.prepareStatement(queryPerfecta);
        ps2.setInt(1, idUsuario);
        ResultSet rs2 = ps2.executeQuery();
        if(rs2.next()){
            rachaPerfecta = true;
        }
        rs2.close(); ps2.close();

        // 3. Revisar palabras guardadas en apoyo (Para Guardián del Diccionario)
        String queryGlosario = "SELECT COUNT(*) as total FROM glosario_apoyo WHERE id_usuario = ?";
        PreparedStatement ps3 = con.prepareStatement(queryGlosario);
        ps3.setInt(1, idUsuario);
        ResultSet rs3 = ps3.executeQuery();
        if(rs3.next()){
            palabrasGlosario = rs3.getInt("total");
        }
        rs3.close(); ps3.close();

        // 4. Contar vocabulario aportado por el usuario (Para Jardín de Logros)
        String queryVocab = "SELECT COUNT(*) as total FROM vocabulario WHERE id_usuario = ?";
        PreparedStatement ps4 = con.prepareStatement(queryVocab);
        ps4.setInt(1, idUsuario);
        ResultSet rs4 = ps4.executeQuery();
        if(rs4.next()){
            palabrasPropias = rs4.getInt("total");
        }
        rs4.close(); ps4.close();

        // 5. Comprobar si configuró su temporizador (Para Relámpago de Velocidad)
        String queryTiempo = "SELECT id_config FROM configuracion_tiempo WHERE id_usuario = ? LIMIT 1";
        PreparedStatement ps5 = con.prepareStatement(queryTiempo);
        ps5.setInt(1, idUsuario);
        ResultSet rs5 = ps5.executeQuery();
        if(rs5.next()){
            configTiempo = true;
        }
        rs5.close(); ps5.close();
        
        con.close();
    } catch(Exception e) {
        System.out.println("Error procesando las 6 insignias: " + e.getMessage());
    }

    // Evaluamos la lógica booleana para decidir qué insignia se queda a color
    boolean cumpleElefante = rachaPerfecta; 
    boolean cumplePanal = (totalPracticas >= 5);
    boolean cumpleDiccionario = (palabrasGlosario > 0);
    boolean cumpleMiel = (acumuladoAciertos >= 50);
    boolean cumpleJardin = (palabrasPropias > 0);
    boolean cumpleVelocidad = configTiempo;
  %>

  <div>
    <div class="rosa">
      <img src="logo.png" alt="Abeja">
      <h1>Lingolyn</h1> 
    </div>

    <div class="navbar">
      <a href="registro.html">LOGIN</a>
      <a href="perfil.html">PERFIL</a>
      <a href="administrar.html">ADMINISTRAR</a>
      <a href="Insignias.jsp">INSIGNIAS</a>
      <a href="basedeaprendizaje.html">BASE DE APRENDIZAJE</a>
      <a href="vocabulario.html">VOCABULARIO</a>
      <a href="ahorcado.jsp">AHORCADO</a>
      <a href="tradicional.html">MODALIDAD TRADICIONAL</a>
      <a href="precision.jsp">PRECISION</a>
    </div>
  </div>

  <div class="main">
    
    <div class="insignias-container">
      
      <h2 class="titulo-insignias">Selecciona la insignia alcanzada</h2>
      
      <div class="grid-insignias">
        
        <div class="box-insignia">
          <img src="insignia1.png" alt="Memoria de Elefante" class="<%= cumpleElefante ? "" : "bloqueada" %>" title="Requisito: Al menos 1 práctica terminada con cero errores">
          <span class="status-tag" style="background-color: <%= cumpleElefante ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumpleElefante ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

        <div class="box-insignia">
          <img src="Insignia2.png" alt="Leyenda del Panal" class="<%= cumplePanal ? "" : "bloqueada" %>" title="Requisito: Haber acumulado 5 prácticas en total">
          <span class="status-tag" style="background-color: <%= cumplePanal ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumplePanal ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

        <div class="box-insignia">
          <img src="Insignia3.png" alt="Guardián del Diccionario" class="<%= cumpleDiccionario ? "" : "bloqueada" %>" title="Requisito: Guardar palabras en tu Glosario de Apoyo">
          <span class="status-tag" style="background-color: <%= cumpleDiccionario ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumpleDiccionario ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

        <div class="box-insignia">
          <img src="Insignia4.png" alt="Recolector de Miel" class="<%= cumpleMiel ? "" : "bloqueada" %>" title="Requisito: Superar los 50 aciertos totales en la app">
          <span class="status-tag" style="background-color: <%= cumpleMiel ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumpleMiel ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

        <div class="box-insignia">
          <img src="Insignia5.png" alt="Jardín de Logros" class="<%= cumpleJardin ? "" : "bloqueada" %>" title="Requisito: Haber agregado un término personalizado a Vocabulario">
          <span class="status-tag" style="background-color: <%= cumpleJardin ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumpleJardin ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

        <div class="box-insignia">
          <img src="Insignia.png" alt="Relámpago de Velocidad" class="<%= cumpleVelocidad ? "" : "bloqueada" %>" title="Requisito: Personalizar tu tiempo límite en la sección de configuración">
          <span class="status-tag" style="background-color: <%= cumpleVelocidad ? "#baffc9" : "#ffb3ba" %>;">
            <%= cumpleVelocidad ? "Alcanzada" : "Bloqueada" %>
          </span>
        </div>

      </div>
      
<button class="btn-aceptar" onclick="window.location.href='datos.jsp';">Aceptar</button>
      <div class="crud-panel">
        <div class="crud-title">Administrar Mis Listas de Insignias</div>
        
        <form action="procesarInsignias.jsp" method="POST">
          
          <div class="form-group">
            <label for="insigniaSeleccionada"><strong>Insignia:</strong></label>
            <select name="insigniaSeleccionada" id="insigniaSeleccionada" class="select-style" required>
              <option value="" disabled selected>-- Elige una insignia --</option>
              <option value="1">Memoria de Elefante</option>
              <option value="2">Leyenda del Panal</option>
              <option value="3">Guardián del Diccionario</option>
              <option value="4">Recolector de Miel</option>
              <option value="5">Jardín de Logros</option>
              <option value="6">Relámpago de Velocidad</option>
            </select>
          </div>

          <div class="form-group">
            <strong>Clasificar como:</strong>
            <label>
              <input type="radio" name="categoria" value="favorita" checked> Favorita
            </label>
            <label>
              <input type="radio" name="categoria" value="meta"> Meta por alcanzar
            </label>
          </div>

          <div class="form-group">
            <button type="submit" name="accion" value="agregar" class="btn-crud" style="background-color: #baffc9;">Agregar a Lista</button>
            <button type="submit" name="accion" value="eliminar" class="btn-crud" style="background-color: #ffb3ba;">Quitar de Lista</button>
            <button type="submit" name="accion" value="consultar"