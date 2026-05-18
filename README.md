# trivia_isuj

server:
necesitamos crear una app de trivia en la cual solo buscamos la persistencia en la base de datos postgresql de los datos personales del usuario tales como, correo, contraseña, primer y segundo nombre, primer y segundo apellido, tabla de login (correo, contraseña, token unico) ,institucion, tipo de perfil, administrador y jugador.
el administrador aparte de poder jugar, puede crear, editar y eliminar preguntas y respuestas.

neccesito que existan "bancos de preguntas" que serian un grupo de preguntas, las cuales yo voy a poder habilitar y deshabilitar para que el jugador pueda jugar. en ciertos tiempos establecidos, necesito tener la opcion de tener varios bancos de preguntas y habilitarlos y deshabilitarlos en su totalidad, si no hay bancos de preguntas activos que el juego te mencione que no hay preguntas activas.
una vez iniciadas las preguntas no puedes salir del banco de preguntas o se termina la prueba y se guarda tu puntaje obtenido hasta ese momento.

app:
va a tener un sqlite, donde se van a almacernar datos del progreso del jugador, todo esto validado por el token de login, si el token no es valido, la app va a generar una nueva instancia del sql sin datos, los datos no van a ser migrables, solo persistencia local, esta app.

necesito que la aplicacion sea en flutter, genera las bds y guarda el script de las bds en un .md, genera un md para poder arrancar el servidor y otro para poder arrancar el app. documenta en su totalidad en un main_readme.md onde todas los requisitos funcionales y no funcionales, como funcionan y como se conectan, y donde se guardan los datos, aclara que tiene 2 bds, documenta las apis, las tablas y todo.

basate en los mokups que tengo y genera el codigo en base a ellos.
