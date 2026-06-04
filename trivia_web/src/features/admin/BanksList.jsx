import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function BanksList({ onManageQuestions }) {
  const [banks, setBanks] = useState([]);
  const [loading, setLoading] = useState(true);

  // Form Modal States
  const [showFormModal, setShowFormModal] = useState(false);
  const [bankToEdit, setBankToEdit] = useState(null);

  // Form Fields
  const [title, setTitle] = useState('');
  const [isActive, setIsActive] = useState(true);
  const [esPermanente, setEsPermanente] = useState(false);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [tiempoPorPregunta, setTiempoPorPregunta] = useState(12);
  const [puntosPorPregunta, setPuntosPorPregunta] = useState(5);
  const [colorBanner, setColorBanner] = useState('#461F70');

  // Selected Bank Options Sheet State
  const [selectedBankForSheet, setSelectedBankForSheet] = useState(null);

  const bannerColors = [
    { hex: '#461F70', name: 'Púrpura Institucional' },
    { hex: '#0D9488', name: 'Teal Vibrante' },
    { hex: '#DC2626', name: 'Rojo Intenso' },
    { hex: '#2563EB', name: 'Azul Eléctrico' },
    { hex: '#D97706', name: 'Ámbar Dorado' },
    { hex: '#059669', name: 'Verde Esmeralda' },
    { hex: '#7C3AED', name: 'Violeta Brillante' },
    { hex: '#DB2777', name: 'Rosa Fucsia' }
  ];

  useEffect(() => {
    loadBanks();
  }, []);

  const loadBanks = () => {
    setLoading(true);
    const allBanks = db.getAdminBanks();
    setBanks(allBanks);
    setLoading(false);
  };

  const handleCreateClick = () => {
    setBankToEdit(null);
    setTitle('');
    setIsActive(true);
    setEsPermanente(false);
    
    // Format dates to YYYY-MM-DDTHH:MM for datetime-local input
    const now = new Date();
    const future = new Date(Date.now() + 1000 * 60 * 60 * 24); // 24h later
    setStartDate(now.toISOString().slice(0, 16));
    setEndDate(future.toISOString().slice(0, 16));
    
    setTiempoPorPregunta(12);
    setPuntosPorPregunta(5);
    setColorBanner('#461F70');
    setShowFormModal(true);
  };

  const handleEditClick = (bank) => {
    setSelectedBankForSheet(null);
    setBankToEdit(bank);
    setTitle(bank.titulo);
    setIsActive(bank.isActive);
    setEsPermanente(bank.esPermanente);
    
    if (bank.tiempoInicio) {
      setStartDate(new Date(bank.tiempoInicio).toISOString().slice(0, 16));
    } else {
      setStartDate('');
    }
    
    if (bank.tiempoFin) {
      setEndDate(new Date(bank.tiempoFin).toISOString().slice(0, 16));
    } else {
      setEndDate('');
    }
    
    setTiempoPorPregunta(bank.tiempoPorPregunta);
    setPuntosPorPregunta(bank.puntosPorPregunta);
    setColorBanner(bank.colorBanner);
    setShowFormModal(true);
  };

  const handleSave = (e) => {
    e.preventDefault();
    if (!title) {
      alert('El título es requerido.');
      return;
    }

    const bankData = {
      titulo: title,
      isActive,
      esPermanente,
      tiempoInicio: esPermanente ? null : new Date(startDate).toISOString(),
      tiempoFin: esPermanente ? null : new Date(endDate).toISOString(),
      tiempoPorPregunta,
      puntosPorPregunta,
      colorBanner
    };

    if (bankToEdit) {
      db.updateBank(bankToEdit.id, bankData);
      alert('Cuestionario actualizado correctamente');
    } else {
      db.createBank(bankData);
      alert('Cuestionario creado correctamente');
    }

    setShowFormModal(false);
    loadBanks();
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleString('es-ES', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric', 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
        <div className="quiz-timer-circle normal">⏳</div>
      </div>
    );
  }

  return (
    <div style={{ width: '100%' }}>
      {/* Admin Panel Welcome */}
      <div className="glass-card gradient-dark-purple" style={{ marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', marginBottom: '8px', letterSpacing: '-0.5px' }}>
          Panel de Gestión 🛡️
        </h1>
        <p style={{ opacity: 0.8, fontSize: '0.95rem', marginBottom: '16px' }}>
          Administra y configura los cuestionarios
        </p>
        <div style={{ display: 'flex', gap: '12px' }}>
          <div style={{ padding: '6px 12px', background: 'rgba(255,255,255,0.15)', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '800' }}>
            📁 {banks.length} Cuestionarios
          </div>
          <div style={{ padding: '6px 12px', background: 'rgba(255,255,255,0.15)', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '800' }}>
            🟢 {banks.filter(b => b.isActive).length} Activos
          </div>
        </div>
      </div>

      {/* List Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span style={{ fontSize: '1.2rem', color: 'var(--primary-container)' }}>📋</span>
          <h3 style={{ fontWeight: '800', color: 'var(--on-surface)' }}>Cuestionarios</h3>
        </div>
        <button onClick={handleCreateClick} className="btn btn-primary btn-sm">
          ➕ Crear banco de preguntas
        </button>
      </div>

      {/* Grid of Banks */}
      {banks.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
          No hay cuestionarios registrados. Crea uno nuevo usando el botón de arriba.
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '20px' }}>
          {banks.map(bank => {
            const lighterBanner = bank.colorBanner + '22'; // 13% opacity for backdrop

            return (
              <div 
                key={bank.id}
                onClick={() => setSelectedBankForSheet(bank)}
                className="glass-card player-card"
                style={{ 
                  padding: '24px', 
                  cursor: 'pointer',
                  borderLeft: `6px solid ${bank.colorBanner}`,
                  background: `linear-gradient(135deg, white 0%, ${lighterBanner} 100%)`
                }}
              >
                {/* Badges row */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                  <div style={{ 
                    padding: '4px 10px', 
                    background: bank.isActive ? 'rgba(74,222,128,0.15)' : 'rgba(239,68,68,0.15)', 
                    color: bank.isActive ? '#16a34a' : '#dc2626', 
                    borderRadius: '12px', 
                    fontSize: '0.7rem', 
                    fontWeight: '800',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px'
                  }}>
                    <span style={{ display: 'inline-block', width: '6px', height: '6px', backgroundColor: bank.isActive ? '#16a34a' : '#dc2626', borderRadius: '50%' }}></span>
                    {bank.isActive ? 'ACTIVO' : 'INACTIVO'}
                  </div>
                  
                  <div style={{ 
                    padding: '4px 10px', 
                    background: 'rgba(0,0,0,0.04)', 
                    color: '#64748b', 
                    borderRadius: '12px', 
                    fontSize: '0.7rem', 
                    fontWeight: '800' 
                  }}>
                    {bank.esPermanente ? '♾️ PERMANENTE' : '⏱️ TEMPORAL'}
                  </div>
                </div>

                <h3 style={{ fontWeight: '800', fontSize: '1.2rem', marginBottom: '12px', color: 'var(--on-surface)' }}>
                  {bank.titulo}
                </h3>

                {/* Configuration pills */}
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginBottom: '16px' }}>
                  <div style={{ padding: '3px 8px', border: '1px solid #cbd5e1', borderRadius: '8px', fontSize: '0.75rem', fontWeight: '600', color: '#475569' }}>
                    ⏱️ {bank.tiempoPorPregunta}s/preg
                  </div>
                  <div style={{ padding: '3px 8px', border: '1px solid #cbd5e1', borderRadius: '8px', fontSize: '0.75rem', fontWeight: '600', color: '#475569' }}>
                    ⭐ {bank.puntosPorPregunta} pts
                  </div>
                  {!bank.esPermanente && bank.tiempoFin && (
                    <div style={{ padding: '3px 8px', border: '1px solid #cbd5e1', borderRadius: '8px', fontSize: '0.75rem', fontWeight: '600', color: '#475569', width: '100%', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      📅 Fin: {formatDate(bank.tiempoFin)}
                    </div>
                  )}
                </div>

                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '0.8rem', color: '#64748b', borderTop: '1px solid #f1f5f9', paddingTop: '12px' }}>
                  <span>Gestionar →</span>
                  <span style={{ fontWeight: 'bold', color: 'var(--primary-container)' }}>Opciones ⚙️</span>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Selected Bank Options Action Sheet (Modal) */}
      {selectedBankForSheet && (
        <div className="modal-overlay" onClick={() => setSelectedBankForSheet(null)}>
          <div className="modal-card" style={{ maxWidth: '440px', marginTop: 'auto', marginBottom: '40px' }} onClick={e => e.stopPropagation()}>
            <div className="modal-header">
              <span className="modal-title">{selectedBankForSheet.titulo}</span>
              <button onClick={() => setSelectedBankForSheet(null)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <div className="modal-body" style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <p style={{ fontSize: '0.85rem', color: '#64748b', marginBottom: '8px' }}>
                Selecciona una acción para este cuestionario:
              </p>
              
              <button 
                onClick={() => handleEditClick(selectedBankForSheet)}
                className="btn btn-outline btn-block"
                style={{ justifyContent: 'flex-start', padding: '16px', borderRadius: '14px', border: '1px solid rgba(70,31,112,0.2)', backgroundColor: 'rgba(70,31,112,0.02)' }}
              >
                📝 <div style={{ textAlign: 'left', marginLeft: '12px' }}>
                  <div style={{ fontWeight: 'bold', color: 'var(--on-surface)' }}>Editar Cuestionario</div>
                  <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '500' }}>Modificar título, estado y configuración</div>
                </div>
              </button>

              <button 
                onClick={() => {
                  onManageQuestions(selectedBankForSheet.id, selectedBankForSheet.titulo);
                  setSelectedBankForSheet(null);
                }}
                className="btn btn-outline btn-block"
                style={{ justifyContent: 'flex-start', padding: '16px', borderRadius: '14px', border: '1px solid rgba(13,148,136,0.2)', backgroundColor: 'rgba(13,148,136,0.02)' }}
              >
                ❓ <div style={{ textAlign: 'left', marginLeft: '12px' }}>
                  <div style={{ fontWeight: 'bold', color: 'var(--on-surface)' }}>Gestionar Preguntas</div>
                  <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '500' }}>Agregar, editar y eliminar preguntas ({db.getQuestions(selectedBankForSheet.id).length})</div>
                </div>
              </button>

              <button 
                onClick={() => handleEditClick(selectedBankForSheet)}
                className="btn btn-outline btn-block"
                style={{ justifyContent: 'flex-start', padding: '16px', borderRadius: '14px', border: '1px solid rgba(249,115,22,0.2)', backgroundColor: 'rgba(249,115,22,0.02)' }}
              >
                ⚙️ <div style={{ textAlign: 'left', marginLeft: '12px' }}>
                  <div style={{ fontWeight: 'bold', color: 'var(--on-surface)' }}>Configuración Avanzada</div>
                  <div style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '500' }}>Tiempo, puntos, color y tipo de trivia</div>
                </div>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Create/Edit Form Modal */}
      {showFormModal && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '560px' }}>
            <div className="modal-header">
              <span className="modal-title">{bankToEdit ? 'Editar Cuestionario' : 'Crear Cuestionario'}</span>
              <button onClick={() => setShowFormModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <form onSubmit={handleSave}>
              <div className="modal-body" style={{ maxHeight: '70vh', overflowY: 'auto' }}>
                
                {/* Title */}
                <div className="form-group">
                  <label className="form-label">Título del Cuestionario *</label>
                  <input 
                    type="text" 
                    className="form-control" 
                    value={title} 
                    onChange={e => setTitle(e.target.value)} 
                    placeholder="Ej. Matemáticas Básicas - Examen 1"
                    required
                  />
                </div>

                {/* Switch Active */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px', border: '1px solid #e2e8f0', borderRadius: '14px', marginBottom: '16px' }}>
                  <div>
                    <div style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>Estado del Cuestionario</div>
                    <div style={{ fontSize: '0.75rem', color: isActive ? '#16a34a' : '#dc2626', fontWeight: '700' }}>
                      {isActive ? 'Habilitado' : 'Deshabilitado'}
                    </div>
                  </div>
                  <input 
                    type="checkbox" 
                    checked={isActive} 
                    onChange={e => setIsActive(e.target.checked)} 
                    style={{ width: '20px', height: '20px', cursor: 'pointer' }}
                  />
                </div>

                {/* Slider Tiempo */}
                <div style={{ padding: '14px', border: '1px solid #e2e8f0', borderRadius: '14px', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <label className="form-label" style={{ margin: '0' }}>Tiempo por Pregunta</label>
                    <span style={{ fontWeight: '800', color: 'var(--primary-container)' }}>{tiempoPorPregunta} segundos</span>
                  </div>
                  <input 
                    type="range" 
                    min="5" 
                    max="60" 
                    step="5"
                    value={tiempoPorPregunta} 
                    onChange={e => setTiempoPorPregunta(parseInt(e.target.value))}
                    style={{ width: '100%', cursor: 'pointer' }}
                  />
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.7rem', color: '#94a3b8', marginTop: '4px' }}>
                    <span>5s</span>
                    <span>60s</span>
                  </div>
                </div>

                {/* Slider Puntos */}
                <div style={{ padding: '14px', border: '1px solid #e2e8f0', borderRadius: '14px', marginBottom: '16px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                    <label className="form-label" style={{ margin: '0' }}>Puntos por Pregunta</label>
                    <span style={{ fontWeight: '800', color: 'var(--secondary)' }}>{puntosPorPregunta} puntos base</span>
                  </div>
                  <input 
                    type="range" 
                    min="1" 
                    max="100" 
                    value={puntosPorPregunta} 
                    onChange={e => setPuntosPorPregunta(parseInt(e.target.value))}
                    style={{ width: '100%', cursor: 'pointer' }}
                  />
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.7rem', color: '#94a3b8', marginTop: '4px' }}>
                    <span>1 pt</span>
                    <span>100 pts</span>
                  </div>
                </div>

                {/* Color Palette Banner */}
                <div style={{ padding: '14px', border: '1px solid #e2e8f0', borderRadius: '14px', marginBottom: '16px' }}>
                  <label className="form-label">Color del Banner</label>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: '8px' }}>
                    {bannerColors.map(color => (
                      <div 
                        key={color.hex}
                        onClick={() => setColorBanner(color.hex)}
                        style={{
                          width: '40px',
                          height: '40px',
                          borderRadius: '12px',
                          backgroundColor: color.hex,
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          border: colorBanner === color.hex ? '3px solid white' : 'none',
                          boxShadow: colorBanner === color.hex ? `0 0 10px ${color.hex}` : 'none'
                        }}
                      >
                        {colorBanner === color.hex && <span style={{ color: 'white', fontWeight: 'bold' }}>✓</span>}
                      </div>
                    ))}
                  </div>
                </div>

                {/* Switch Permanente */}
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px', border: '1px solid #e2e8f0', borderRadius: '14px', marginBottom: '16px' }}>
                  <div>
                    <div style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>Tipo de Cuestionario</div>
                    <div style={{ fontSize: '0.75rem', color: esPermanente ? 'var(--primary)' : '#64748b', fontWeight: '700' }}>
                      {esPermanente ? 'Permanente (sin fecha límite)' : 'Temporal (con fechas)'}
                    </div>
                  </div>
                  <input 
                    type="checkbox" 
                    checked={esPermanente} 
                    onChange={e => setEsPermanente(e.target.checked)} 
                    style={{ width: '20px', height: '20px', cursor: 'pointer' }}
                  />
                </div>

                {/* Dates */}
                {!esPermanente && (
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                    <div className="form-group">
                      <label className="form-label">Fecha Inicio</label>
                      <input 
                        type="datetime-local" 
                        className="form-control" 
                        value={startDate} 
                        onChange={e => setStartDate(e.target.value)} 
                      />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Fecha Fin</label>
                      <input 
                        type="datetime-local" 
                        className="form-control" 
                        value={endDate} 
                        onChange={e => setEndDate(e.target.value)} 
                      />
                    </div>
                  </div>
                )}
              </div>

              <div className="modal-footer">
                <button type="button" onClick={() => setShowFormModal(false)} className="btn btn-outline btn-sm">
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
