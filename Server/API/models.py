from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Enum, text
from sqlalchemy.orm import relationship
from database import Base
import enum
from datetime import datetime

class PerfilEnum(str, enum.Enum):
    ADMINISTRADOR = "ADMINISTRADOR"
    JUGADOR = "JUGADOR"

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    correo = Column(String(255), unique=True, index=True, nullable=False)
    contrasena = Column(String(255), nullable=False)
    primer_nombre = Column(String(100), nullable=False)
    segundo_nombre = Column(String(100))
    primer_apellido = Column(String(100), nullable=False)
    segundo_apellido = Column(String(100))
    institucion = Column(String(255), nullable=False)
    cedula = Column(String(20), nullable=True)
    telefono = Column(String(20), nullable=True)
    tipo_perfil = Column(Enum(PerfilEnum), default=PerfilEnum.JUGADOR, nullable=False)
    creado_en = Column(DateTime, default=datetime.utcnow)

    logins = relationship("Login", back_populates="usuario")
    puntajes = relationship("Puntaje", back_populates="usuario")

class Login(Base):
    __tablename__ = "logins"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    token = Column(String(255), unique=True, index=True, nullable=False)
    creado_en = Column(DateTime, default=datetime.utcnow)
    expira_en = Column(DateTime)

    usuario = relationship("Usuario", back_populates="logins")

class BancoPreguntas(Base):
    __tablename__ = "bancos_preguntas"

    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=False)
    tiempo_inicio = Column(DateTime)
    tiempo_fin = Column(DateTime)
    creado_en = Column(DateTime, default=datetime.utcnow)

    # New configuration fields
    tiempo_por_pregunta = Column(Integer, default=12)       # seconds per question
    color_banner = Column(String(20), default='#461F70')    # hex color for banner
    puntos_por_pregunta = Column(Integer, default=5)        # base points per correct answer
    es_permanente = Column(Boolean, default=False)          # permanent vs temporal

    preguntas = relationship("Pregunta", back_populates="banco")
    puntajes = relationship("Puntaje", back_populates="banco")

class Pregunta(Base):
    __tablename__ = "preguntas"

    id = Column(Integer, primary_key=True, index=True)
    banco_id = Column(Integer, ForeignKey("bancos_preguntas.id", ondelete="CASCADE"), nullable=False)
    texto_pregunta = Column(String, nullable=False)
    creado_en = Column(DateTime, default=datetime.utcnow)

    banco = relationship("BancoPreguntas", back_populates="preguntas")
    respuestas = relationship("Respuesta", back_populates="pregunta")

class Respuesta(Base):
    __tablename__ = "respuestas"

    id = Column(Integer, primary_key=True, index=True)
    pregunta_id = Column(Integer, ForeignKey("preguntas.id", ondelete="CASCADE"), nullable=False)
    texto_respuesta = Column(String, nullable=False)
    es_correcta = Column(Boolean, default=False)

    pregunta = relationship("Pregunta", back_populates="respuestas")

class Puntaje(Base):
    __tablename__ = "puntajes"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    banco_id = Column(Integer, ForeignKey("bancos_preguntas.id", ondelete="CASCADE"), nullable=False)
    puntaje_neto = Column(Integer, default=0, nullable=False)
    completado_en = Column(DateTime, default=datetime.utcnow)

    usuario = relationship("Usuario", back_populates="puntajes")
    banco = relationship("BancoPreguntas", back_populates="puntajes")
