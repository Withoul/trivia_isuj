import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function TiendaManager() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);

  // Form Modal States
  const [showFormModal, setShowFormModal] = useState(false);
  const [itemToEdit, setItemToEdit] = useState(null);

  // Form fields
  const [name, setName] = useState('');
  const [valor, setValor] = useState(100);
  const [stock, setStock] = useState(10);
  const [selectedIcon, setSelectedIcon] = useState('gift');

  const availableIcons = [
    { name: 'Regalo', value: 'gift', emoji: '🎁' },
    { name: 'Estrella', value: 'star', emoji: '⭐' },
    { name: 'Juego', value: 'gamepad', emoji: '🎮' },
    { name: 'Libro', value: 'book', emoji: '📖' },
    { name: 'Trofeo', value: 'trophy', emoji: '🏆' },
    { name: 'Mochila', value: 'bag', emoji: '🎒' }
  ];

  useEffect(() => {
    loadItems();
  }, []);

  const loadItems = () => {
    setLoading(true);
    const storeItems = db.getAdminStoreItems();
    setItems(storeItems);
    setLoading(false);
  };

  const getIconEmoji = (iconValue) => {
    const found = availableIcons.find(i => i.value === iconValue);
    return found ? found.emoji : '🎁';
  };

  const handleCreateClick = () => {
    setItemToEdit(null);
    setName('');
    setValor(100);
    setStock(10);
    setSelectedIcon('gift');
    setShowFormModal(true);
  };

  const handleEditClick = (item) => {
    setItemToEdit(item);
    setName(item.nombre);
    setValor(item.valor);
    setStock(item.stock);
    setSelectedIcon(item.icono);
    setShowFormModal(true);
  };

  const handleDeleteClick = (item) => {
    const confirm = window.confirm(`¿Estás seguro de que deseas eliminar permanentemente el artículo "${item.nombre}"?`);
    if (confirm) {
      db.deleteStoreItem(item.id);
      alert('Artículo eliminado correctamente');
      loadItems();
    }
  };

  const handleSave = (e) => {
    e.preventDefault();
    if (!name || valor <= 0 || stock < 0) {
      alert('Por favor completa todos los campos con valores válidos.');
      return;
    }

    if (itemToEdit) {
      db.updateStoreItem(itemToEdit.id, name, valor, stock, selectedIcon);
      alert('Artículo actualizado correctamente');
    } else {
      db.createStoreItem(name, valor, stock, selectedIcon);
      alert('Artículo creado correctamente');
    }

    setShowFormModal(false);
    loadItems();
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
      {/* Header Panel */}
      <div className="glass-card gradient-dark-purple" style={{ marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', marginBottom: '8px', letterSpacing: '-0.5px' }}>
          Gestión de Tienda 🛒
        </h1>
        <p style={{ opacity: 0.8, fontSize: '0.95rem', marginBottom: '16px' }}>
          Crea, edita y elimina los artículos y recompensas disponibles para los estudiantes.
        </p>
        <div style={{ display: 'inline-flex', padding: '6px 12px', background: 'rgba(255,255,255,0.15)', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '800' }}>
          🎁 {items.length} Recompensas Creadas
        </div>
      </div>

      {/* List Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <span style={{ fontSize: '1.2rem', color: 'var(--primary-container)' }}>📦</span>
          <h3 style={{ fontWeight: '800', color: 'var(--on-surface)' }}>Lista de Artículos</h3>
        </div>
        <button onClick={handleCreateClick} className="btn btn-primary btn-sm">
          ➕ Agregar Objeto
        </button>
      </div>

      {/* Items list */}
      {items.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
          No hay artículos registrados.
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
          {items.map(item => {
            const hasStock = item.stock > 0;

            return (
              <div 
                key={item.id} 
                className="glass-card" 
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  padding: '16px 20px', 
                  borderRadius: '16px',
                  border: '1px solid #f1f5f9'
                }}
              >
                {/* Icon box */}
                <div 
                  style={{
                    width: '52px',
                    height: '52px',
                    borderRadius: '12px',
                    backgroundColor: 'rgba(70,31,112,0.06)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '2rem',
                    marginRight: '16px'
                  }}
                >
                  {getIconEmoji(item.icono)}
                </div>

                {/* Details */}
                <div style={{ flex: 1 }}>
                  <span style={{ fontWeight: 'bold', color: 'var(--on-surface)', fontSize: '0.95rem' }}>
                    {item.nombre}
                  </span>
                  <div style={{ display: 'flex', gap: '16px', marginTop: '4px' }}>
                    <span style={{ color: 'var(--secondary)', fontWeight: '700', fontSize: '0.85rem' }}>
                      Costo: {item.valor} PTS
                    </span>
                    <span style={{ 
                      fontSize: '0.75rem', 
                      fontWeight: '800', 
                      padding: '1px 8px', 
                      borderRadius: '8px',
                      backgroundColor: hasStock ? 'rgba(74,222,128,0.1)' : 'rgba(239,68,68,0.1)',
                      color: hasStock ? '#16a34a' : '#dc2626'
                    }}>
                      {hasStock ? `Stock: ${item.stock}` : 'Agotado'}
                    </span>
                  </div>
                </div>

                {/* Action buttons */}
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button 
                    onClick={() => handleEditClick(item)}
                    style={{ background: 'none', border: 'none', fontSize: '1.15rem', cursor: 'pointer', padding: '8px' }}
                    title="Editar"
                  >
                    ✏️
                  </button>
                  <button 
                    onClick={() => handleDeleteClick(item)}
                    style={{ background: 'none', border: 'none', fontSize: '1.15rem', cursor: 'pointer', padding: '8px' }}
                    title="Eliminar"
                  >
                    🗑️
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Create/Edit Form Modal */}
      {showFormModal && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '440px' }}>
            <div className="modal-header">
              <span className="modal-title">{itemToEdit ? 'Editar Artículo' : 'Crear Artículo'}</span>
              <button onClick={() => setShowFormModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <form onSubmit={handleSave}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Nombre del Objeto *</label>
                  <input 
                    type="text" 
                    className="form-control" 
                    value={name} 
                    onChange={e => setName(e.target.value)} 
                    placeholder="Ej. Termo Metálico"
                    required 
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Valor (Puntos/Monedas) *</label>
                  <input 
                    type="number" 
                    className="form-control" 
                    value={valor} 
                    onChange={e => setValor(parseInt(e.target.value) || 0)} 
                    placeholder="Costo en puntos"
                    min="1"
                    required 
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Stock Disponible *</label>
                  <input 
                    type="number" 
                    className="form-control" 
                    value={stock} 
                    onChange={e => setStock(parseInt(e.target.value) || 0)} 
                    placeholder="Cantidad en almacén"
                    min="0"
                    required 
                  />
                </div>

                {/* Icon Selector */}
                <div className="form-group">
                  <label className="form-label">Icono del Objeto *</label>
                  <div style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginTop: '8px' }}>
                    {availableIcons.map(ico => (
                      <div 
                        key={ico.value}
                        onClick={() => setSelectedIcon(ico.value)}
                        style={{
                          width: '44px',
                          height: '44px',
                          borderRadius: '12px',
                          backgroundColor: selectedIcon === ico.value ? 'rgba(70,31,112,0.1)' : '#f8fafc',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontSize: '1.8rem',
                          cursor: 'pointer',
                          border: selectedIcon === ico.value ? '2px solid var(--primary-container)' : '1.5px solid #e2e8f0',
                          transition: 'var(--transition-fast)'
                        }}
                        title={ico.name}
                      >
                        {ico.emoji}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
              <div className="modal-footer">
                <button type="button" onClick={() => setShowFormModal(false)} className="btn btn-outline btn-sm">
                  Cancelar
                </button>
                <button type="submit" className="btn btn-primary btn-sm">
                  {itemToEdit ? 'Guardar' : 'Crear'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
