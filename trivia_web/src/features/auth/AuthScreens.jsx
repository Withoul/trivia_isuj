import React, { useState } from 'react';
import { db } from '../../data/db';

export default function AuthScreens({ onAuthSuccess }) {
  const [isLoginView, setIsLoginView] = useState(true);

  // Common fields
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  // Signup extra fields
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [institution, setInstitution] = useState('');
  const [cedula, setCedula] = useState('');
  const [phone, setPhone] = useState('');

  const [loading, setLoading] = useState(false);

  const handleLogin = (e) => {
    e.preventDefault();
    if (!email || !password) {
      alert('Por favor completa todos los campos.');
      return;
    }

    setLoading(true);
    const result = db.login(email, password);
    setLoading(false);

    if (result.success) {
      onAuthSuccess(result.user);
    } else {
      alert(result.message);
    }
  };

  const handleSignup = (e) => {
    e.preventDefault();
    if (!email || !password || !firstName || !lastName || !institution) {
      alert('Por favor completa todos los campos marcados con (*).');
      return;
    }

    setLoading(true);
    const result = db.signup({
      correo: email,
      contrasena: password,
      primerNombre: firstName,
      primerApellido: lastName,
      institucion,
      cedula,
      telefono: phone
    });
    setLoading(false);

    if (result.success) {
      alert('¡Cuenta creada con éxito! Ahora puedes iniciar sesión.');
      // Auto fill and switch to login
      setIsLoginView(true);
      setPassword('');
    } else {
      alert(result.message);
    }
  };

  return (
    <div className="auth-wrapper">
      <div className="auth-card">
        
        {/* Header */}
        <div className="auth-header">
          {/* Logo representation */}
          <div style={{ fontSize: '3rem', marginBottom: '8px' }}>🎓</div>
          <h2>{isLoginView ? 'QuizGame ISUJ' : 'Registrarse en ISUJ'}</h2>
          <p style={{ fontSize: '0.85rem', color: '#64748b', marginTop: '4px' }}>
            {isLoginView 
              ? 'Ingresa tus credenciales para empezar a jugar' 
              : 'Únete a la comunidad de trivia académica'
            }
          </p>
        </div>

        {/* Forms */}
        {isLoginView ? (
          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label className="form-label">Correo Electrónico *</label>
              <input 
                type="email" 
                className="form-control"
                placeholder="correo@ejemplo.com"
                value={email}
                onChange={e => setEmail(e.target.value)}
                required
              />
            </div>
            
            <div className="form-group" style={{ marginBottom: '28px' }}>
              <label className="form-label">Contraseña *</label>
              <input 
                type="password" 
                className="form-control"
                placeholder="••••••••"
                value={password}
                onChange={e => setPassword(e.target.value)}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              {loading ? 'Iniciando sesión...' : 'Iniciar Sesión'}
            </button>

            <div style={{ textAlign: 'center', marginTop: '20px', fontSize: '0.85rem', color: '#64748b' }}>
              ¿No tienes cuenta?{' '}
              <span 
                onClick={() => setIsLoginView(false)} 
                style={{ color: 'var(--primary-container)', fontWeight: 'bold', cursor: 'pointer', textDecoration: 'underline' }}
              >
                Regístrate aquí
              </span>
            </div>
          </form>
        ) : (
          <form onSubmit={handleSignup}>
            <div style={{ maxHeight: '50vh', overflowY: 'auto', paddingRight: '6px', marginBottom: '20px' }}>
              <div className="form-group">
                <label className="form-label">Correo Electrónico *</label>
                <input 
                  type="email" 
                  className="form-control"
                  placeholder="ej. carlos@ujapon.edu.ec"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Contraseña *</label>
                <input 
                  type="password" 
                  className="form-control"
                  placeholder="Mínimo 6 caracteres"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Nombres *</label>
                <input 
                  type="text" 
                  className="form-control"
                  placeholder="Primer y segundo nombre"
                  value={firstName}
                  onChange={e => setFirstName(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Apellidos *</label>
                <input 
                  type="text" 
                  className="form-control"
                  placeholder="Apellidos paterno y materno"
                  value={lastName}
                  onChange={e => setLastName(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Institución / Carrera *</label>
                <input 
                  type="text" 
                  className="form-control"
                  placeholder="Ej. Ingeniería en Sistemas ISUJ"
                  value={institution}
                  onChange={e => setInstitution(e.target.value)}
                  required
                />
              </div>

              <div className="form-group">
                <label className="form-label">Cédula de Identidad</label>
                <input 
                  type="text" 
                  className="form-control"
                  placeholder="Cédula de identidad ecuatoriana"
                  value={cedula}
                  onChange={e => setCedula(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label className="form-label">Teléfono de Contacto</label>
                <input 
                  type="text" 
                  className="form-control"
                  placeholder="Ej. 0999888777"
                  value={phone}
                  onChange={e => setPhone(e.target.value)}
                />
              </div>
            </div>

            <button type="submit" className="btn btn-primary btn-block" disabled={loading}>
              {loading ? 'Creando cuenta...' : 'Crear Cuenta'}
            </button>

            <div style={{ textAlign: 'center', marginTop: '20px', fontSize: '0.85rem', color: '#64748b' }}>
              ¿Ya tienes cuenta?{' '}
              <span 
                onClick={() => setIsLoginView(true)} 
                style={{ color: 'var(--primary-container)', fontWeight: 'bold', cursor: 'pointer', textDecoration: 'underline' }}
              >
                Inicia sesión
              </span>
            </div>
          </form>
        )}

      </div>
    </div>
  );
}
