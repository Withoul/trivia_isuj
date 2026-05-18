from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import List

import models
import schemas
import auth
from database import get_db, engine

# Create tables if they don't exist
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Trivia App API")

# --- AUTHENTICATION ---

@app.post("/auth/register", response_model=schemas.UsuarioResponse)
def register(user: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.Usuario).filter(models.Usuario.correo == user.correo).first()
    if db_user:
        raise HTTPException(status_code=400, detail="El correo ya está registrado")
    
    hashed_password = auth.get_password_hash(user.contrasena)
    new_user = models.Usuario(
        correo=user.correo,
        contrasena=hashed_password,
        primer_nombre=user.primer_nombre,
        segundo_nombre=user.segundo_nombre,
        primer_apellido=user.primer_apellido,
        segundo_apellido=user.segundo_apellido,
        institucion=user.institucion,
        tipo_perfil=user.tipo_perfil
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/auth/login", response_model=schemas.TokenResponse)
def login(form_data: schemas.LoginRequest, db: Session = Depends(get_db)):
    user = db.query(models.Usuario).filter(models.Usuario.correo == form_data.correo).first()
    if not user or not auth.verify_password(form_data.contrasena, user.contrasena):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.correo}, expires_delta=access_token_expires
    )

    # Save token in DB
    expiration_date = datetime.utcnow() + access_token_expires
    db_login = models.Login(usuario_id=user.id, token=access_token, expira_en=expiration_date)
    db.add(db_login)
    db.commit()

    return {"access_token": access_token, "token_type": "bearer", "usuario": user}


# --- BANCOS DE PREGUNTAS (JUGADOR Y ADMIN) ---

@app.get("/banks/active", response_model=List[schemas.BancoPreguntasResponse])
def get_active_banks(db: Session = Depends(get_db), current_user: models.Usuario = Depends(auth.get_current_user)):
    now = datetime.utcnow()
    # Los bancos están activos si is_active es True, y si estamos dentro del rango de tiempo (si este existe)
    query = db.query(models.BancoPreguntas).filter(models.BancoPreguntas.is_active == True)
    
    # Filtro de tiempo en Python para mayor legibilidad, o en SQL
    banks = query.all()
    active_banks = []
    for bank in banks:
        valid_start = True
        valid_end = True
        if bank.tiempo_inicio and now < bank.tiempo_inicio:
            valid_start = False
        if bank.tiempo_fin and now > bank.tiempo_fin:
            valid_end = False
        
        if valid_start and valid_end:
            active_banks.append(bank)
            
    return active_banks

@app.get("/banks/{bank_id}/play", response_model=List[schemas.PreguntaResponse])
def play_bank(bank_id: int, db: Session = Depends(get_db), current_user: models.Usuario = Depends(auth.get_current_user)):
    # Solo verificar si existe, en la vida real podríamos validar si sigue activo
    bank = db.query(models.BancoPreguntas).filter(models.BancoPreguntas.id == bank_id).first()
    if not bank:
        raise HTTPException(status_code=404, detail="Banco no encontrado")
        
    preguntas = db.query(models.Pregunta).filter(models.Pregunta.banco_id == bank_id).all()
    return preguntas

@app.post("/banks/{bank_id}/score", response_model=schemas.ScoreResponse)
def submit_score(bank_id: int, score: schemas.ScoreSubmit, db: Session = Depends(get_db), current_user: models.Usuario = Depends(auth.get_current_user)):
    nuevo_puntaje = models.Puntaje(
        usuario_id=current_user.id,
        banco_id=bank_id,
        puntaje_neto=score.puntaje_neto
    )
    db.add(nuevo_puntaje)
    db.commit()
    db.refresh(nuevo_puntaje)
    return nuevo_puntaje


# --- ADMIN ENDPOINTS ---

@app.post("/admin/banks", response_model=schemas.BancoPreguntasResponse)
def create_bank(bank: schemas.BancoPreguntasCreate, db: Session = Depends(get_db), current_admin: models.Usuario = Depends(auth.get_current_admin)):
    db_bank = models.BancoPreguntas(**bank.model_dump())
    db.add(db_bank)
    db.commit()
    db.refresh(db_bank)
    return db_bank

@app.post("/admin/banks/{bank_id}/questions", response_model=schemas.PreguntaResponse)
def create_question(bank_id: int, pregunta: schemas.PreguntaCreate, db: Session = Depends(get_db), current_admin: models.Usuario = Depends(auth.get_current_admin)):
    bank = db.query(models.BancoPreguntas).filter(models.BancoPreguntas.id == bank_id).first()
    if not bank:
        raise HTTPException(status_code=404, detail="Banco no encontrado")
        
    db_pregunta = models.Pregunta(banco_id=bank_id, texto_pregunta=pregunta.texto_pregunta)
    db.add(db_pregunta)
    db.commit()
    db.refresh(db_pregunta)
    
    for resp in pregunta.respuestas:
        db_resp = models.Respuesta(pregunta_id=db_pregunta.id, texto_respuesta=resp.texto_respuesta, es_correcta=resp.es_correcta)
        db.add(db_resp)
    
    db.commit()
    db.refresh(db_pregunta)
    return db_pregunta

@app.put("/admin/banks/{bank_id}", response_model=schemas.BancoPreguntasResponse)
def update_bank(bank_id: int, bank_update: schemas.BancoPreguntasCreate, db: Session = Depends(get_db), current_admin: models.Usuario = Depends(auth.get_current_admin)):
    bank = db.query(models.BancoPreguntas).filter(models.BancoPreguntas.id == bank_id).first()
    if not bank:
        raise HTTPException(status_code=404, detail="Banco no encontrado")
        
    bank.titulo = bank_update.titulo
    bank.is_active = bank_update.is_active
    bank.tiempo_inicio = bank_update.tiempo_inicio
    bank.tiempo_fin = bank_update.tiempo_fin
    
    db.commit()
    db.refresh(bank)
    return bank
