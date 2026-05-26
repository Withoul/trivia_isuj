import sys
import os

# Asegurar que el path incluya el directorio actual para importar los modulos locales
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import engine, SessionLocal
import models
import auth

def reset_and_create_tables():
    print("Iniciando conexión con PostgreSQL...")
    try:
        # 1. Eliminar tablas existentes para garantizar un inicio limpio
        print("Eliminando tablas antiguas (si existen)...")
        models.Base.metadata.drop_all(bind=engine)
        
        # 2. Crear las nuevas tablas con las columnas actualizadas
        print("Creando nuevas tablas y relaciones...")
        models.Base.metadata.create_all(bind=engine)
        print("¡Tablas creadas con éxito en PostgreSQL!")

        # 3. Sembrar datos iniciales requeridos
        print("Sembrando datos iniciales...")
        db = SessionLocal()
        
        # Sembrar Administrador
        hashed_admin_pw = auth.get_password_hash("admin")
        admin = models.Usuario(
            correo="admin@admin.com",
            contrasena=hashed_admin_pw,
            primer_nombre="Admin",
            primer_apellido="Sistema",
            institucion="Universidad del Japón",
            cedula="1799999999",
            telefono="0999999999",
            tipo_perfil=models.PerfilEnum.ADMINISTRADOR
        )
        db.add(admin)
        print("-> Sembrado administrador: admin@admin.com / admin")

        # Sembrar Jugador de Prueba (David L.)
        hashed_user_pw = auth.get_password_hash("user1234")
        user = models.Usuario(
            correo="usuario@usuario.com",
            contrasena=hashed_user_pw,
            primer_nombre="David",
            primer_apellido="L.",
            institucion="Ingeniería en Sistemas",
            cedula="1722222222",
            telefono="0988888888",
            tipo_perfil=models.PerfilEnum.JUGADOR
        )
        db.add(user)
        print("-> Sembrado jugador: usuario@usuario.com / user1234")

        # Sembrar un banco de preguntas activo de prueba
        banco = models.BancoPreguntas(
            titulo="Fundamentos de Desarrollo Móvil e ISUTJ",
            is_active=True,
            tiempo_inicio=None,
            tiempo_fin=None
        )
        db.add(banco)
        db.commit()
        db.refresh(banco)
        print(f"-> Sembrado Banco de Preguntas ID {banco.id}: {banco.titulo}")

        # Sembrar algunas preguntas y respuestas
        pregunta1 = models.Pregunta(
            banco_id=banco.id,
            texto_pregunta="¿Cuál es el lenguaje de programación principal para desarrollo Android nativo?"
        )
        db.add(pregunta1)
        db.commit()
        db.refresh(pregunta1)

        resp1_a = models.Respuesta(pregunta_id=pregunta1.id, texto_respuesta="Swift", es_correcta=False)
        resp1_b = models.Respuesta(pregunta_id=pregunta1.id, texto_respuesta="Kotlin", es_correcta=True)
        resp1_c = models.Respuesta(pregunta_id=pregunta1.id, texto_respuesta="JavaScript", es_correcta=False)
        resp1_d = models.Respuesta(pregunta_id=pregunta1.id, texto_respuesta="C#", es_correcta=False)
        db.add_all([resp1_a, resp1_b, resp1_c, resp1_d])

        pregunta2 = models.Pregunta(
            banco_id=banco.id,
            texto_pregunta="En Flutter, ¿qué widget se utiliza comúnmente para estructurar una pantalla con AppBar, Body y BottomNavigationBar?"
        )
        db.add(pregunta2)
        db.commit()
        db.refresh(pregunta2)

        resp2_a = models.Respuesta(pregunta_id=pregunta2.id, texto_respuesta="Container", es_correcta=False)
        resp2_b = models.Respuesta(pregunta_id=pregunta2.id, texto_respuesta="Scaffold", es_correcta=True)
        resp2_c = models.Respuesta(pregunta_id=pregunta2.id, texto_respuesta="Column", es_correcta=False)
        resp2_d = models.Respuesta(pregunta_id=pregunta2.id, texto_respuesta="SizedBox", es_correcta=False)
        db.add_all([resp2_a, resp2_b, resp2_c, resp2_d])

        db.commit()
        db.close()
        print("¡Base de datos sembrada e inicializada exitosamente!")
    except Exception as e:
        print(f"ERROR al inicializar la base de datos: {e}")
        print("Por favor, asegúrate de que el servidor PostgreSQL esté corriendo y que exista la base de datos 'triviaisuj'.")

if __name__ == "__main__":
    reset_and_create_tables()
