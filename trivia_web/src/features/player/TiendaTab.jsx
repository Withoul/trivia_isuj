import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function TiendaTab({ user, onRefreshUser }) {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedItem, setSelectedItem] = useState(null);
  const [showConfirmModal, setShowConfirmModal] = useState(false);

  useEffect(() => {
    loadItems();
  }, [user]);

  const loadItems = () => {
    setLoading(true);
    const storeItems = db.getStoreItems(user.id);
    setItems(storeItems);
    setLoading(false);
  };

  const getIconEmoji = (iconName) => {
    switch (iconName) {
      case 'gift': return '🎁';
      case 'star': return '⭐';
      case 'gamepad': return '🎮';
      case 'book': return '📖';
      case 'trophy': return '🏆';
      case 'bag': return '🎒';
      default: return '🎁';
    }
  };

  const handleRedeemClick = (item) => {
    if (user.puntosDisponibles < item.valor) {
      alert('Puntos insuficientes para canjear este artículo.');
      return;
    }
    setSelectedItem(item);
    setShowConfirmModal(true);
  };

  const handleConfirmRedeem = () => {
    if (!selectedItem) return;

    const success = db.redeemStoreItem(selectedItem.id);
    if (success) {
      alert(`¡Canjeaste "${selectedItem.nombre}" con éxito! 🎉`);
      onRefreshUser(); // Will trigger reload via useEffect dependency on user
    } else {
      alert('Ocurrió un error al procesar el canje.');
    }
    setShowConfirmModal(false);
    setSelectedItem(null);
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
      {/* Store Header */}
      <div className="glass-card gradient-yellow" style={{ marginBottom: '32px', color: 'white' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', marginBottom: '8px', letterSpacing: '-0.5px' }}>
          Tienda de Recompensas 🎁
        </h1>
        <p style={{ opacity: 0.9, fontSize: '0.95rem', marginBottom: '16px', lineHeight: '1.4' }}>
          Canjea tus puntos acumulados por artículos exclusivos. ¡Cada objeto se puede obtener una sola vez!
        </p>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '8px 16px', background: 'rgba(255,255,255,0.2)', borderRadius: '12px' }}>
          <span style={{ fontSize: '1.1rem' }}>🪙</span>
          <span style={{ fontWeight: '800', fontSize: '0.95rem' }}>
            Saldo disponible: {user.puntosDisponibles.toLocaleString()} PTS
          </span>
        </div>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '20px' }}>
        <span style={{ fontSize: '1.2rem', color: 'var(--secondary-container)' }}>🛒</span>
        <h3 style={{ fontWeight: '800', color: 'var(--on-surface)' }}>Catálogo de Premios</h3>
      </div>

      {items.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#64748b' }}>
          No hay artículos disponibles en la tienda.
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: '20px' }}>
          {items.map(item => {
            const hasStock = item.stock > 0;
            const isRedeemed = item.canjeado;
            const canAfford = user.puntosDisponibles >= item.valor;

            return (
              <div 
                key={item.id} 
                className="glass-card player-card"
                style={{ 
                  display: 'flex', 
                  flexDirection: 'column', 
                  padding: '0', 
                  border: isRedeemed ? '1.5px solid rgba(16, 185, 129, 0.3)' : (!hasStock ? '1.5px solid rgba(239, 68, 68, 0.2)' : '1px solid rgba(0,0,0,0.05)')
                }}
              >
                {/* Icon Area */}
                <div 
                  style={{ 
                    padding: '24px', 
                    background: isRedeemed ? 'rgba(16, 185, 129, 0.04)' : (!hasStock ? 'rgba(239, 68, 68, 0.04)' : '#f8fafc'), 
                    display: 'flex', 
                    alignItems: 'center', 
                    justifyContent: 'center',
                    fontSize: '3rem',
                    position: 'relative',
                    borderBottom: '1px solid #f1f5f9'
                  }}
                >
                  {getIconEmoji(item.icono)}
                  {isRedeemed && (
                    <div style={{ position: 'absolute', top: '12px', right: '12px', background: '#10b981', color: 'white', fontSize: '0.65rem', fontWeight: '800', padding: '2px 8px', borderRadius: '8px' }}>
                      CANJEADO
                    </div>
                  )}
                  {!isRedeemed && !hasStock && (
                    <div style={{ position: 'absolute', top: '12px', right: '12px', background: '#ef4444', color: 'white', fontSize: '0.65rem', fontWeight: '800', padding: '2px 8px', borderRadius: '8px' }}>
                      AGOTADO
                    </div>
                  )}
                </div>

                {/* Content Area */}
                <div style={{ padding: '16px', flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
                  <div>
                    <h4 style={{ fontWeight: '800', fontSize: '0.95rem', marginBottom: '4px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {item.nombre}
                    </h4>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                      <span style={{ fontWeight: '800', color: isRedeemed ? '#10b981' : 'var(--secondary)', fontSize: '1.05rem' }}>
                        🪙 {item.valor}
                      </span>
                      <span style={{ fontSize: '0.75rem', color: hasStock ? '#64748b' : '#ef4444', fontWeight: '600' }}>
                        Stock: {item.stock}
                      </span>
                    </div>
                  </div>

                  <button
                    disabled={isRedeemed || !hasStock}
                    onClick={() => handleRedeemClick(item)}
                    className="btn btn-primary btn-block btn-sm"
                    style={{
                      backgroundColor: isRedeemed ? '#d1fae5' : (!hasStock ? '#f3f4f6' : (!canAfford ? '#cbd5e1' : 'var(--secondary-container)')),
                      color: isRedeemed ? '#065f46' : (!hasStock ? '#9ca3af' : (!canAfford ? '#64748b' : 'var(--on-secondary-container)')),
                      cursor: (isRedeemed || !hasStock) ? 'not-allowed' : 'pointer'
                    }}
                  >
                    {isRedeemed ? 'Canjeado ✓' : (!hasStock ? 'Sin Stock' : 'Canjear')}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Confirmation Modal */}
      {showConfirmModal && selectedItem && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '400px' }}>
            <div className="modal-header">
              <span className="modal-title">Confirmar Canje 🪙</span>
              <button onClick={() => setShowConfirmModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <div className="modal-body">
              <p style={{ fontSize: '0.9rem', color: '#4b5563', marginBottom: '16px' }}>
                ¿Estás seguro de que deseas canjear tus puntos por este artículo?
              </p>
              <div 
                style={{ 
                  display: 'flex', 
                  alignItems: 'center', 
                  gap: '12px', 
                  padding: '12px', 
                  backgroundColor: '#f8fafc', 
                  borderRadius: '12px', 
                  border: '1px solid #e2e8f0' 
                }}
              >
                <span style={{ fontSize: '2rem' }}>{getIconEmoji(selectedItem.icono)}</span>
                <div>
                  <div style={{ fontWeight: 'bold', fontSize: '0.95rem' }}>{selectedItem.nombre}</div>
                  <div style={{ color: 'var(--primary-container)', fontWeight: '800', fontSize: '0.85rem' }}>
                    🪙 {selectedItem.valor} PTS
                  </div>
                </div>
              </div>
              <p style={{ fontSize: '0.7rem', color: '#9ca3af', fontStyle: 'italic', marginTop: '12px' }}>
                Nota: Este artículo se puede canjear una sola vez y se descontarán los puntos inmediatamente.
              </p>
            </div>
            <div className="modal-footer">
              <button onClick={() => setShowConfirmModal(false)} className="btn btn-outline btn-sm">
                Cancelar
              </button>
              <button onClick={handleConfirmRedeem} className="btn btn-primary btn-sm">
                Canjear
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
