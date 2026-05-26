from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime
from models import PerfilEnum

# --- USUARIOS ---
class UsuarioBase(BaseModel):
    correo: EmailStr
    primer_nombre: str
    segundo_nombre: Optional[str] = None
    primer_apellido: str
    segundo_apellido: Optional[str] = None
    institucion: str
    tipo_perfil: PerfilEnum
    cedula: Optional[str] = None
    telefono: Optional[str] = None

class UsuarioCreate(UsuarioBase):
    contrasena: str

class UsuarioResponse(UsuarioBase):
    id: int
    creado_en: datetime
    class Config:
        from_attributes = True

# --- LOGIN ---
class LoginRequest(BaseModel):
    correo: str
    contrasena: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    usuario: UsuarioResponse

# --- PREGUNTAS Y RESPUESTAS ---
class RespuestaBase(BaseModel):
    texto_respuesta: str
    es_correcta: bool

class RespuestaResponse(RespuestaBase):
    id: int
    class Config:
        from_attributes = True

class RespuestaCreate(RespuestaBase):
    pass

class PreguntaBase(BaseModel):
    texto_pregunta: str

class PreguntaCreate(PreguntaBase):
    respuestas: List[RespuestaCreate]

class PreguntaResponse(PreguntaBase):
    id: int
    respuestas: List[RespuestaResponse]
    class Config:
        from_attributes = True

# --- BANCO DE PREGUNTAS ---
class BancoPreguntasBase(BaseModel):
    titulo: str
    is_active: bool = False
    tiempo_inicio: Optional[datetime] = None
    tiempo_fin: Optional[datetime] = None

class BancoPreguntasCreate(BancoPreguntasBase):
    pass

class BancoPreguntasResponse(BancoPreguntasBase):
    id: int
    creado_en: datetime
    class Config:
        from_attributes = True

# --- PUNTAJE ---
class ScoreSubmit(BaseModel):
    puntaje_neto: int

class ScoreResponse(BaseModel):
    id: int
    usuario_id: int
    banco_id: int
    puntaje_neto: int
    completado_en: datetime
    class Config:
        from_attributes = True

# --- RANKING ---
class RankingResponse(BaseModel):
    usuario_id: int
    primer_nombre: str
    primer_apellido: str
    correo: str
    institucion: str
    puntaje_acumulado: int
    accuracy: int  # Porcentaje de aciertos (mockeado o calculado, ej. 85%)
    class Config:
        from_attributes = True
