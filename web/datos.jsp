<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Lingolyn - Ingresa tus Datos</title>
  <link rel="stylesheet" href="estilos.css">
  <style>
    .login-container {
      display: flex; flex-direction: column; align-items: center; justify-content: center; width: 100%; max-width: 600px; gap: 20px;
    }
    .titulo-datos { font-size: 28px; font-weight: normal; color: #000; margin: 0 0 10px 0; text-align: center; }
    .campo-grupo { display: flex; flex-direction: column; align-items: flex-start; width: 85%; max-width: 480px; gap: 10px; }
    .label-usuario { font-size: 20px; color: #000; margin: 0; }
    .input-usuario { width: 100%; padding: 10px 12px; font-size: 18px; border: 1px solid #000; background: #fff; outline: none; box-sizing: border-box; }
    .btn-aceptar { background: #f7a8b8; color: #fff; border: 1px solid #000; padding: 12px 65px; font-size: 20px; cursor: pointer; border-radius: 4px; font-weight: bold; margin-top: 35px; transition: background 0.2s; }
    .btn-aceptar:hover { background: #e593a3; }
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

  <div class="main">
    <form action="globos.jsp" method="POST" class="login-container">
      <h2 class="titulo-datos">Ingresa tus datos</h2>
      
      <div class="campo-grupo">
        <label class="label-usuario">Ingresar nombre de usuario</label>
        <input type="text" name="txtUsuario" class="input-usuario" autocomplete="off" required placeholder="Ej. Lingolyn">
      </div>
      
      <button type="submit" class="btn-aceptar">Aceptar</button>
    </form>
  </div>
  <div class="footer-simple"></div>
</body>
</html>