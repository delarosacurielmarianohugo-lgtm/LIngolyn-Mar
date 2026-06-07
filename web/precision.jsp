<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Desafío de Precisión - Lingolyn</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="estilos.css" type="text/css">
    <style>
        body { font-family: sans-serif; background-color: #FFF9D2; margin: 0; padding: 0; }
        
.Instrucciones, .zona-juego, .zona-resumen {
    max-width: 600px;
    margin: 40px auto;
    padding: 25px;
    border: 3px solid #f7a8b8;
    border-radius: 12px;
    text-align: center;
    box-shadow: 0 4px 15px rgba(247,168,184,0.2);
    background-color: #fff;
}

.BotonOk a, .btn-juego {
    display: inline-block;
    background-color: #f7a8b8;
    color: white;
    padding: 10px 40px;
    text-decoration: none;
    font-weight: bold;
    border-radius: 5px;
    border: 1px solid #000;
    cursor: pointer;
    font-size: 16px;
    transition: background 0.2s;
}

.BotonOk a:hover, .btn-juego:hover {
    background-color: #e593a3;
}

.zona-juego { display: none; }
.zona-resumen { display: none; background-color: #fff9fa; }

.timer-box { font-size: 24px; font-weight: bold; color: #e593a3; margin-bottom: 15px; }
.palabra-display { font-size: 32px; letter-spacing: 5px; margin: 20px 0; font-weight: bold; color: #333; }
.significado { font-size: 18px; color: #666; font-style: italic; margin-bottom: 20px; }

.input-deletreo {
    font-size: 20px;
    padding: 10px;
    width: 80%;
    text-align: center;
    border: 2px solid #f7a8b8;
    border-radius: 5px;
    margin-bottom: 15px;
    text-transform: uppercase;
}

.marcador {
    display: flex;
    justify-content: space-around;
    margin-top: 20px;
    font-size: 16px;
    font-weight: bold;
}
.error-txt { color: #d9534f; }
.acierto-txt { color: #5cb85c; }
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
            <a href="Insignias.jsp">INSIGNIAS</a>
            <a href="basedeaprendizaje.html">BASE DE APRENDIZAJE</a>
            <a href="vocabulario.html">VOCABULARIO</a>
            <a href="ahorcado.jsp">AHORCADO</a>
            <a href="tradicional.html">MODALIDAD TRADICIONAL</a>
            <a href="precision.jsp">PRECISION</a>
        </div>
    </div>

    <div class="Instrucciones" id="pantallaInstrucciones">
        <h1>Instrucciones</h1>
        <br>
        <h3>
            1. Deberás deletrear la mayor cantidad de palabras posible, pero solo puedes equivocarte tres veces.
            <br><br>
            2. Al cometer el tercer error, el reto finaliza automáticamente, mostrando un resumen con el total de aciertos y errores.
        </h3>
        <br>
        <div class="BotonOk">
            <a href="#" onclick="iniciarDesafio(); return false;">Ok</a>
        </div>
    </div>

    <div class="zona-juego" id="pantallaJuego">
        <div class="timer-box" id="timerContenedor">Tiempo: <span id="segundosTxt">00</span>s</div>
        
        <h3>Escribe la palabra correctamente:</h3>
        <div class="significado" id="traduccionTxt">Traducción aquí</div>
        <div class="palabra-display" id="pistaTxt">_ _ _ _ _</div>
        
        <input type="text" id="inputRespuesta" class="input-deletreo" autocomplete="off" placeholder="Escribe aquí..." onkeydown="evaluarEnter(event)">
        <br>
        <button class="btn-juego" onclick="verificarPalabra()">Enviar</button>
        
        <div class="marcador">
            <span class="acierto-txt">Aciertos: <span id="aciertosTxt">0</span></span>
            <span class="error-txt">Errores: <span id="erroresTxt">0</span>/3</span>
        </div>
    </div>

    <div class="zona-resumen" id="pantallaResumen">
        <h1>¡Desafío Terminado!</h1>
        <br>
        <h3>Has alcanzado el límite máximo de 3 errores o completaste el banco de palabras.</h3>
        <br>
        <div class="marcador" style="font-size: 22px;">
            <span class="acierto-txt">Total Aciertos: <span id="finalAciertos">0</span></span>
            <span class="error-txt">Total Errores: <span id="finalErrores">0</span></span>
        </div>
        <br><br>
        <button class="btn-juego" onclick="window.location.href='index.html';">Volver al Menú</button>
    </div>
              <div class="footer-simple"></div>

    <script>
        const vocabularioJuego = [];
        
        <%
            List<Object[]> listaPalabras = (List<Object[]>) request.getAttribute("listaPalabras");
            
            if(listaPalabras != null && !listaPalabras.isEmpty()) {
                for(Object[] fila : listaPalabras) {
                    String ingles = fila[0].toString().replace("'", "\\'");
                    String espanol = fila[1].toString().replace("'", "\\'");
        %>
                    vocabularioJuego.push({
                        palabra: '<%= ingles.toUpperCase() %>',
                        traduccion: '<%= espanol %>'
                    });
        <%
                }
            } else {
        %>
                vocabularioJuego.push(
                    { palabra: "ACHIEVEMENT", traduccion: "Logro" },
                    { palabra: "OPPORTUNITY", traduccion: "Oportunidad" },
                    { palabra: "ENVIRONMENT", traduccion: "Medio ambiente" },
                    { palabra: "ENCOURAGE", traduccion: "Animar" },
                    { palabra: "RESEARCH", traduccion: "Investigación" }
                );
        <%
            }
        %>

        let tiempoConfigurado = 20;
        let mostrarContador = true;
        let indicePalabraActual = 0;
        let aciertos = 0;
        let errores = 0;
        let tiempoRestante = 0;
        let intervaloTimer = null;

        function iniciarDesafio() {
            // Lee los datos guardados en el localStorage desde la vista anterior (Vista 13)
            tiempoConfigurado = parseInt(localStorage.getItem('tiempoPorPalabra')) || 20;
            mostrarContador = localStorage.getItem('mostrarCuentaRegresiva') !== 'false';

            document.getElementById('timerContenedor').style.display = mostrarContador ? 'block' : 'none';

            // Mezclar aleatoriamente el banco dinámico enviado por el servidor
            vocabularioJuego.sort(() => Math.random() - 0.5);

            document.getElementById('pantallaInstrucciones').style.display = 'none';
            document.getElementById('pantallaJuego').style.display = 'block';

            cargarNuevaPalabra();
        }

        function cargarNuevaPalabra() {
            if (indicePalabraActual >= vocabularioJuego.length || errores >= 3) {
                finalizarJuego();
                return;
            }

            const item = vocabularioJuego[indicePalabraActual];
            document.getElementById('traduccionTxt').innerText = "Significado: " + item.traduccion;
            
            let pista = item.palabra[0] + " " + "_ ".repeat(item.palabra.length - 2) + item.palabra[item.palabra.length - 1];
            document.getElementById('pistaTxt').innerText = pista;

            document.getElementById('inputRespuesta').value = "";
            document.getElementById('inputRespuesta').focus();

            tiempoRestante = tiempoConfigurado;
            document.getElementById('segundosTxt').innerText = tiempoRestante;
            
            clearInterval(intervaloTimer);
            intervaloTimer = setInterval(ejecutarReloj, 1000);
        }

        function ejecutarReloj() {
            tiempoRestante--;
            document.getElementById('segundosTxt').innerText = tiempoRestante;

            if (tiempoRestante <= 0) {
                clearInterval(intervaloTimer);
                registrarError();
            }
        }

        function verificarPalabra() {
            clearInterval(intervaloTimer);
            const respuestaUsuario = document.getElementById('inputRespuesta').value.trim().toUpperCase();
            const palabraCorrecta = vocabularioJuego[indicePalabraActual].palabra.toUpperCase();

            if (respuestaUsuario === palabraCorrecta) {
                aciertos++;
                document.getElementById('aciertosTxt').innerText = aciertos;
                indicePalabraActual++;
                cargarNuevaPalabra();
            } else {
                registrarError();
            }
        }

        function registrarError() {
            errores++;
            document.getElementById('erroresTxt').innerText = errores;
            
            if (errores >= 3) {
                finalizarJuego();
            } else {
                indicePalabraActual++;
                cargarNuevaPalabra();
            }
        }

        function evaluarEnter(evento) {
            if (evento.key === 'Enter') {
                verificarPalabra();
            }
        }

        function finalizarJuego() {
            clearInterval(intervaloTimer);
            document.getElementById('pantallaJuego').style.display = 'none';
            document.getElementById('pantallaResumen').style.display = 'block';
            
            document.getElementById('finalAciertos').innerText = aciertos;
            document.getElementById('finalErrores').innerText = errores;
        }
    </script>
</body>
</html>