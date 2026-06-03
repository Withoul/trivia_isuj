import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function UsersManager() {
  const [users, setUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  // Edit user modal states
  const [showEditModal, setShowEditModal] = useState(false);
  const [userToEdit, setUserToEdit] = useState(null);
  
  // Edit user fields
  const [email, setEmail] = useState('');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [institution, setInstitution] = useState('');
  const [cedula, setCedula] = useState('');
  const [phone, setPhone] = useState('');
  const [role, setRole] = useState('JUGADOR');

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = () => {
    setLoading(true);
    const list = db.getAdminUsers();
    setUsers(list);
    setLoading(false);
  };

  const handleEditClick = (user) => {
    setUserToEdit(user);
    setEmail(user.correo);
    setFirstName(user.primerNombre);
    setLastName(user.primerApellido);
    setInstitution(user.institucion);
    setCedula(user.cedula || '');
    setPhone(user.telefono || '');
    setRole(user.tipoPerfil);
    
    setShowEditModal(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    if (!email || !firstName || !lastName || !institution) {
      alert('Por favor completa todos los campos requeridos.');
      return;
    }

    const updatedUser = {
      ...userToEdit,
      correo: email,
      primerNombre: firstName,
      primerApellido: lastName,
      institucion: institution,
      cedula: cedula,
      telefono: phone,
      tipoPerfil: role
    };

    db.updateAdminUser(userToEdit.id, updatedUser);
    alert('Usuario actualizado correctamente');
    setShowEditModal(false);
    loadUsers();
  };

  // Search logic
  const filteredUsers = users.filter(user => {
    const q = searchQuery.toLowerCase().trim();
    if (!q) return true;

    const fullName = `${user.primerNombre} ${user.primerApellido}`.toLowerCase();
    const emailStr = user.correo.toLowerCase();
    const instStr = user.institucion.toLowerCase();
    const cedulaStr = (user.cedula || '').toLowerCase();
    const phoneStr = (user.telefono || '').toLowerCase();

    return fullName.includes(q) || 
           emailStr.includes(q) || 
           instStr.includes(q) || 
           cedulaStr.includes(q) || 
           phoneStr.includes(q);
  });

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
        <div className="quiz-timer-circle normal">⏳</div>
      </div>
    );
  }

  return (
    <div style={{ width: '100%' }}>
      {/* Header Panel */}
      <div className="glass-card gradient-dark-purple" style={{ marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', marginBottom: '8px', letterSpacing: '-0.5px' }}>
          Gestión de Usuarios 👥
        </h1>
        <p style={{ opacity: 0.8, fontSize: '0.95rem', marginBottom: '16px' }}>
          Busca y edita toda la información de los usuarios registrados, incluyendo roles e información de contacto.
        </p>
        <div style={{ display: 'inline-flex', padding: '6px 12px', background: 'rgba(255,255,255,0.15)', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '800' }}>
          👥 {users.length} Usuarios Registrados
        </div>
      </div>

      {/* Search box */}
      <div style={{ marginBottom: '24px' }}>
        <input 
          type="text" 
          className="form-control"
          placeholder="🔍 Buscar por nombre, correo, cédula..."
          value={searchQuery}
          onChange={e => setSearchQuery(e.target.value)}
          style={{ background: 'white', borderRadius: '16px' }}
        />
      </div>

      {/* Users lists */}
      {filteredUsers.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
          No se encontraron usuarios coincidentes.
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {filteredUsers.map(user => {
            const isAdmin = user.tipoPerfil === 'ADMINISTRADOR';
            const initials = user.primerNombre[0].toUpperCase();

            return (
              <div 
                key={user.id} 
                className="glass-card" 
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  padding: '16px 20px', 
                  borderRadius: '16px',
                  border: '1px solid #f1f5f9'
                }}
              >
                {/* Initial circle */}
                <div 
                  style={{
                    width: '44px',
                    height: '44px',
                    borderRadius: '50%',
                    backgroundColor: isAdmin ? 'rgba(70,31,112,0.1)' : '#f1f5f9',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontWeight: 'bold',
                    color: isAdmin ? 'var(--primary)' : '#475569',
                    fontSize: '1.05rem',
                    marginRight: '16px'
                  }}
                >
                  {initials}
                </div>

                {/* User details */}
                <div style={{ flex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <span style={{ fontWeight: 'bold', color: 'var(--on-surface)', fontSize: '0.95rem' }}>
                      {user.primerNombre} {user.primerApellido}
                    </span>
                    <span style={{ 
                      fontSize: '0.65rem', 
                      fontWeight: '800', 
                      padding: '2px 8px', 
                      borderRadius: '8px',
                      backgroundColor: isAdmin ? 'rgba(70,31,112,0.12)' : 'rgba(255, 199, 10, 0.12)',
                      color: isAdmin ? 'var(--primary)' : 'var(--on-secondary-container)'
                    }}>
                      {user.tipoPerfil}
                    </span>
                  </div>
                  <div style={{ fontSize: '0.8rem', color: '#64748b', marginTop: '2px' }}>
                    {user.correo}
                  </div>
                  <div style={{ fontSize: '0.75rem', color: '#94a3b8', marginTop: '2px' }}>
                    Institución: {user.institucion}
                  </div>
                </div>

                {/* Edit Action Button */}
                <button 
                  onClick={() => handleEditClick(user)}
                  style={{ background: 'none', border: 'none', fontSize: '1.25rem', cursor: 'pointer', padding: '8px' }}
                  title="Editar usuario"
                >
                  ✏️
                </button>
              </div>
            );
          })}
        </div>
      )}

      {/* Edit User Modal */}
      {showEditModal && userToEdit && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '500px' }}>
            <div className="modal-header">
              <span className="modal-title">Editar Usuario 👤</span>
              <button onClick={() => setShowEditModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <form onSubmit={handleSave}>
              <div className="modal-body" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                <div className="form-group">
                  <label className="form-label">Correo Electrónico *</label>
                  <input 
                    type="email" 
                    className="form-control" 
                    value={email} 
                    onChange={e => setEmail(e.target.value)} 
                    required 
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Nombres *</label>
                  <input 
                    type="text" 
                    className="form-control" 
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
                    value={cedula} 
                    onChange={e => setCedula(e.target.value)} 
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Teléfono</label>
                  <input 
                    type="text" 
                    className="form-control" 
                    value={phone} 
                    onChange={e => setPhone(e.target.value)} 
                  />
                </div>

                {/* Role selection */}
                <div className="form-group">
                  <label className="form-label">Perfil / Rol *</label>
                  <div style={{ display: 'flex', gap: '20px', marginTop: '8px' }}>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                      <input 
                        type="radio" 
                        name="user-role-radio" 
                        value="JUGADOR"
                        checked={role === 'JUGADOR'}
                        onChange={() => setRole('JUGADOR')}
                      />
                      Jugador
                    </label>
                    <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer' }}>
                      <input 
                        type="radio" 
                        name="user-role-radio" 
                        value="ADMINISTRADOR"
                        checked={role === 'ADMINISTRADOR'}
                        onChange={() => setRole('ADMINISTRADOR')}
                      />
                      Admin
                    </label>
                  </div>
                </div>
              </div>
              
              <div className="modal-footer">
                <button type="button" onClick={() => setShowEditModal(false)} className="btn btn-outline btn-sm">
                  Cancelar
                </button>
                <button type="submit" className="btn btn-primary btn-sm">
                  Guardar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
