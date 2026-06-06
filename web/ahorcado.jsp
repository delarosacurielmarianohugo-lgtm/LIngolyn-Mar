<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lingolyn - Ahorcado</title>
  
  <link rel="stylesheet" href="estilos.css">

  <style>
    .juego-ahorcado-container {
      display: flex; flex-direction: row; align-items: center; justify-content: center; gap: 60px;                
      width: 100%; max-width: 800px; margin-bottom: 30px;     
    }

    /* --- DISEÑO DE LA HORCA Y EL CUERPO --- */
    .area-horca { position: relative; width: 200px; height: 250px; }
    .horca-base { position: absolute; bottom: 0; left: 10px; width: 80px; height: 6px; background: #000; }
    .horca-poste { position: absolute; bottom: 6px; left: 47px; width: 6px; height: 220px; background: #000; }
    .horca-techo { position: absolute; top: 24px; left: 47px; width: 120px; height: 6px; background: #000; }
    .horca-cuerda { position: absolute; top: 30px; left: 161px; width: 6px; height: 30px; background: #000; }
    
    .cabeza { position: absolute; top: 60px; left: 144px; width: 40px; height: 40px; border: 5px solid #000; border-radius: 50%; display: none; box-sizing: border-box;}
    .cuerpo { position: absolute; top: 100px; left: 161px; width: 6px; height: 60px; background: #000; display: none; }
    .brazo-izq { position: absolute; top: 110px; left: 136px; width: 30px; height: 6px; background: #000; transform: rotate(-30deg); display: none; }
    .brazo-der { position: absolute; top: 110px; left: 162px; width: 30px; height: 6px; background: #000; transform: rotate(30deg); display: none; }
    .pierna-izq { position: absolute; top: 155px; left: 146px; width: 20px; height: 45px; border-left: 6px solid #000; transform: rotate(20deg); display: none; }
    .pierna-der { position: absolute; top: 155px; left: 161px; width: 20px; height: 45px; border-right: 6px solid #000; transform: rotate(-20deg); display: none; }

    .area-interactiva { display: flex; flex-direction: column; gap: 25px; }
    .indicacion-ahorcado { font-size: 22px; color: #000; margin: 0; }

    /* Renglones para las letras de la palabra secreta */
    .palabra-casillas { display: flex; flex-direction: row; align-items: center; gap: 15px; }
    .letra-progreso { font-size: 32px; font-weight: bold; color: #000; width: 45px; text-align: center; border-bottom: 4px solid #f7a8b8; min-height: 40px; }

    /* Entrada de la letra intentada */
    .input-letra-unica { width: 55px; height: 55px; font-size: 28px; font-weight: bold; text-align: center; text-transform: uppercase; border: 2px solid #51361A; background: #fff; outline: none; }

    .main { display: flex; flex-direction: column; align-items: center; margin-top: 40px; }
    
    .btn-listo { 
      background: #f7a8b8; color: #fff; border: 1px solid #000; padding: 12px 50px; 
      font-size: 20px; cursor: pointer; border-radius: 4px; font-weight: bold; transition: background 0.2s;
    }
    .btn-listo:hover { background: #e593a3; }
    .alerta { font-size: 18px; font-weight: bold; margin-bottom: 20px; color: #51361A; }
    .btn-reiniciar { background: #51361A; color: white; border: none; padding: 8px 15px; text-decoration: none; border-radius: 4px; font-size: 14px; margin-top: 15px; }
  </style>
</head>
<body>

    <div>
   <div class="rosa">
      <img src="logo.png" alt="Abeja">
      <h1>Lingolyn</h1> 
  </div>

  <div class="navbar">
    <a href="registro.html">LOGIN</a>
    <a href="perfil.html">PERFIL</a>
    <a href="administrar.html">ADMINISTRAR</a>
    <a href="Insignias.html">INSIGNIAS</a>
    <a href="basedeaprendizaje.html">BASE DE APRENDIZAJE</a>
    <a href="vocabulario.html">VOCABULARIO</a>
    <a href="ahorcado.jsp">AHORCADO</a>
    <a href="tradicional.html">MODALIDAD TRADICIONAL</a>
    <a href="precision.jsp">PRECISION</a>
  </div>
        </div>
  <div class="main">
    
    <% 
        String mensaje = (String) session.getAttribute("mensaje");
        char[] progreso = (char[]) session.getAttribute("progreso");
        Integer errores = (Integer) session.getAttribute("errores");
        if (errores == null) errores = 0;
    %>

    <% if (mensaje != null) { %>
        <div class="alerta"><%= mensaje %></div>
    <% } %>

    <form action="AhorcadoServlet" method="POST" style="display: flex; flex-direction: column; align-items: center;">
        
        <div class="juego-ahorcado-container">
          
          <div class="area-horca">
            <div class="horca-base"></div>
            <div class="horca-poste"></div>
            <div class="horca-techo"></div>
            <div class="horca-cuerda"></div>
            
            <div class="cabeza"     style="<%= (errores >= 1) ? "display:block;" : "" %>"></div>
            <div class="cuerpo"     style="<%= (errores >= 2) ? "display:block;" : "" %>"></div>
            <div class="brazo-izq"  style="<%= (errores >= 3) ? "display:block;" : "" %>"></div>
            <div class="brazo-der"  style="<%= (errores >= 4) ? "display:block;" : "" %>"></div>
            <div class="pierna-izq" style="<%= (errores >= 5) ? "display:block;" : "" %>"></div>
            <div class="pierna-der" style="<%= (errores >= 6) ? "display:block;" : "" %>"></div>
          </div>

          <div class="area-interactiva">
            <p class="indicacion-ahorcado">Palabra secreta:</p>
            
            <div class="palabra-casillas">
              <% 
                if (progreso != null) {
                    for (int i = 0; i < progreso.length; i++) {
                        String letraMostrar = (progreso[i] == '_') ? "&nbsp;" : String.valueOf(progreso[i]);
              %>
                        <div class="letra-progreso"><%= letraMostrar %></div>
              <% 
                    }
                } 
              %>
            </div>

            <% if (errores < 6 && (mensaje == null || !mensaje.contains("Ganaste"))) { %>
                <div style="margin-top: 15px; display: flex; align-items: center; gap: 10px;">
                    <label style="font-size: 18px;">Intentar letra:</label>
                    <input type="text" name="letraIntentada" class="input-letra-unica" maxlength="1" required autocomplete="off" autofocus>
                </div>
            <% } %>
          </div>

        </div>

        <% if (errores < 6 && (mensaje == null || !mensaje.contains("Ganaste"))) { %>
            <button type="submit" class="btn-listo">Listo!</button>
        <% } %>
    </form>
    
    <a href="AhorcadoServlet?reiniciar=true" class="btn-reiniciar">Siguiente Palabra / Reiniciar</a>

  </div>

</body>
</html>