import React, { useState } from 'react';
import { db } from '../../data/db';

export default function ProfileTab({ user, onRefreshUser, onLogout }) {
  const [email, setEmail] = useState(user.correo);
  const [firstName, setFirstName] = useState(user.primerNombre);
  const [lastName, setLastName] = useState(user.primerApellido);
  const [institution, setInstitution] = useState(user.institucion);
  const [cedula, setCedula] = useState(user.cedula || '');
  const [phone, setPhone] = useState(user.telefono || '');
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!email || !firstName || !lastName || !institution) {
      alert('Por favor, completa los campos requeridos (Correo, Nombres, Apellidos e Institución).');
      return;
    }

    setLoading(true);
    const updated = db.updateProfile(user.id, {
      correo: email,
      primerNombre: firstName,
      primerApellido: lastName,
      institucion,
      cedula,
      telefono: phone
    });

    if (updated) {
      alert('Perfil actualizado con éxito');
      onRefreshUser();
    } else {
      alert('Error al actualizar el perfil.');
    }
    setLoading(false);
  };

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', width: '100%' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', color: 'var(--on-surface)' }}>
          Mi Perfil
        </h1>
        <button onClick={onLogout} className="btn btn-danger btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <span>🚪</span> Cerrar Sesión
        </button>
      </div>

      {/* Stats Dashboard */}
      <div className="glass-card" style={{ marginBottom: '32px' }}>
        <h3 style={{ fontWeight: '800', marginBottom: '16px' }}>🏆 Estadísticas de Juego</h3>
        <div className="stats-grid">
          <div className="stat-box">
            <div className="stat-value">{user.quizzesCompletados}</div>
            <div className="stat-label">Cuestionarios</div>
          </div>
          <div className="stat-box">
            <div className="stat-value" style={{ color: 'var(--streak-orange)' }}>🔥 {user.rachaMaxima}x</div>
            <div className="stat-label">Racha Máxima</div>
          </div>
          <div className="stat-box">
            <div className="stat-value" style={{ color: '#ffc70a' }}>⭐ {user.puntajeTotal.toLocaleString()}</div>
            <div className="stat-label">Puntaje Histórico</div>
          </div>
        </div>
      </div>

      {/* Edit Form */}
      <div className="glass-card">
        <h3 style={{ fontWeight: '800', marginBottom: '20px', borderBottom: '1.5px solid #f1f5f9', paddingBottom: '10px' }}>
          👤 Datos de la Cuenta
        </h3>
        <form onSubmit={handleSubmit}>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
            <div className="form-group">
              <label className="form-label">Correo Electrónico *</label>
              <input 
                type="email" 
                className="form-control" 
                value={email} 
                onChange={(e) => setEmail(e.target.value)} 
                required 
              />
            </div>
            <div className="form-group">
              <label className="form-label">Nombres *</label>
              <input 
                type="text" 
                className="form-control" 
                value={firstName} 
                onChange={(e) => setFirstName(e.target.value)} 
                required 
              />
            </div>
            <div className="form-group">
              <label className="form-label">Apellidos *</label>
              <input 
                type="text" 
                className="form-control" 
                value={lastName} 
                onChange={(e) => setLastName(e.target.value)} 
                required 
              />
            </div>
            <div className="form-group">
              <label className="form-label">Institución / Carrera *</label>
              <input 
                type="text" 
                className="form-control" 
                value={institution} 
                onChange={(e) => setInstitution(e.target.value)} 
                required 
              />
            </div>
            <div className="form-group">
              <label className="form-label">Cédula de Identidad</label>
              <input 
                type="text" 
                className="form-control" 
                value={cedula} 
                onChange={(e) => setCedula(e.target.value)} 
              />
            </div>
            <div className="form-group">
              <label className="form-label">Teléfono</label>
              <input 
                type="text" 
                className="form-control" 
                value={phone} 
                onChange={(e) => setPhone(e.target.value)} 
              />
            </div>
          </div>
          <button 
            type="submit" 
            className="btn btn-primary" 
            style={{ marginTop: '20px', minWidth: '160px' }}
            disabled={loading}
          >
            {loading ? 'Guardando...' : 'Guardar Cambios'}
          </button>
        </form>
      </div>
    </div>
  );
}
