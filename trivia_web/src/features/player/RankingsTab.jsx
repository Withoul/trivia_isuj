import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function RankingsTab({ currentUser }) {
  const [rankings, setRankings] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRankings();
  }, []);

  const loadRankings = () => {
    setLoading(true);
    const ranks = db.getGlobalRankings();
    setRankings(ranks);
    setLoading(false);
  };

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', padding: '40px' }}>
        <div className="quiz-timer-circle normal">⏳</div>
      </div>
    );
  }

  const top3 = rankings.slice(0, 3);
  const remaining = rankings.slice(3);

  const first = top3[0];
  const second = top3[1];
  const third = top3[2];

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', width: '100%' }}>
      <div style={{ textAlign: 'center', marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', color: 'var(--on-surface)', marginBottom: '4px' }}>
          Tabla de Posiciones
        </h1>
        <p style={{ color: 'var(--on-surface-variant)', fontSize: '0.95rem' }}>
          Top Performers Globales
        </p>
      </div>

      {/* 3D PODIUM */}
      <div className="podium-container">
        {/* 2nd Place */}
        <div className="podium-column">
          {second ? (
            <>
              <div className="podium-avatar-wrapper">
                <div className="podium-avatar">
                  {second.primerNombre[0].toUpperCase()}
                </div>
                <div className="podium-badge" style={{ backgroundColor: '#94a3b8' }}>2</div>
              </div>
              <span style={{ fontWeight: 'bold', fontSize: '0.85rem', whiteSpace: 'nowrap' }}>
                {second.primerNombre} {second.primerApellido[0]}.
              </span>
              <span style={{ fontSize: '0.75rem', fontWeight: '800', color: '#64748b', marginBottom: '8px' }}>
                {second.puntajeAcumulado.toLocaleString()} pts
              </span>
              <div className="podium-pillar second">
                <span style={{ fontSize: '1.2rem' }}>🥈</span>
                <span style={{ fontSize: '0.7rem', fontWeight: '900' }}>2ND</span>
              </div>
            </>
          ) : (
            <div style={{ width: '80px' }} />
          )}
        </div>

        {/* 1st Place */}
        <div className="podium-column" style={{ width: '120px' }}>
          {first ? (
            <>
              <div className="podium-avatar-wrapper">
                <span className="podium-crown animate-float" style={{ fontSize: '1.8rem' }}>👑</span>
                <div className="podium-avatar">
                  {first.primerNombre[0].toUpperCase()}
                </div>
                <div className="podium-badge">1</div>
              </div>
              <span style={{ fontWeight: 'bold', fontSize: '0.95rem', whiteSpace: 'nowrap' }}>
                {first.primerNombre} {first.primerApellido[0]}.
              </span>
              <span style={{ fontSize: '0.8rem', fontWeight: '800', color: 'var(--secondary)', marginBottom: '8px' }}>
                {first.puntajeAcumulado.toLocaleString()} pts
              </span>
              <div className="podium-pillar first" style={{ height: '140px' }}>
                <span style={{ fontSize: '1.5rem' }}>🥇</span>
                <span style={{ fontSize: '0.85rem', fontWeight: '900' }}>1ST</span>
              </div>
            </>
          ) : (
            <div style={{ width: '90px' }} />
          )}
        </div>

        {/* 3rd Place */}
        <div className="podium-column">
          {third ? (
            <>
              <div className="podium-avatar-wrapper">
                <div className="podium-avatar">
                  {third.primerNombre[0].toUpperCase()}
                </div>
                <div className="podium-badge" style={{ backgroundColor: '#d97706' }}>3</div>
              </div>
              <span style={{ fontWeight: 'bold', fontSize: '0.85rem', whiteSpace: 'nowrap' }}>
                {third.primerNombre} {third.primerApellido[0]}.
              </span>
              <span style={{ fontSize: '0.75rem', fontWeight: '800', color: '#64748b', marginBottom: '8px' }}>
                {third.puntajeAcumulado.toLocaleString()} pts
              </span>
              <div className="podium-pillar third">
                <span style={{ fontSize: '1.2rem' }}>🥉</span>
                <span style={{ fontSize: '0.7rem', fontWeight: '900' }}>3RD</span>
              </div>
            </>
          ) : (
            <div style={{ width: '80px' }} />
          )}
        </div>
      </div>

      {/* Ranks list */}
      <div style={{ marginTop: '24px' }}>
        {remaining.map((user, idx) => {
          const position = idx + 4;
          const isCurrentUser = user.correo.toLowerCase() === currentUser.correo.toLowerCase();

          return (
            <div 
              key={position}
              className="glass-card"
              style={{
                display: 'flex',
                alignItems: 'center',
                padding: '14px 20px',
                borderRadius: '16px',
                marginBottom: '12px',
                border: isCurrentUser ? '2px solid var(--secondary-container)' : '1px solid rgba(0,0,0,0.05)',
                boxShadow: isCurrentUser ? '0 6px 15px rgba(255, 199, 10, 0.12)' : 'none',
                background: isCurrentUser ? 'rgba(255, 199, 10, 0.02)' : 'white'
              }}
            >
              {/* Position */}
              <div style={{ width: '32px', fontWeight: '900', color: isCurrentUser ? 'var(--secondary)' : '#94a3b8', fontSize: '1.1rem' }}>
                {position}
              </div>

              {/* Avatar */}
              <div 
                style={{
                  width: '40px',
                  height: '40px',
                  borderRadius: '50%',
                  backgroundColor: isCurrentUser ? 'var(--secondary-container)' : '#f1f5f9',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontWeight: 'bold',
                  color: 'var(--primary)',
                  marginRight: '16px'
                }}
              >
                {isCurrentUser ? '👤' : user.primerNombre[0].toUpperCase()}
              </div>

              {/* Name & accuracy */}
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontWeight: 'bold', color: isCurrentUser ? 'var(--primary-container)' : '#1e293b' }}>
                    {user.fullName}
                  </span>
                  {isCurrentUser && (
                    <span style={{ fontSize: '0.75rem', fontWeight: '800', background: 'var(--secondary-container)', color: 'var(--on-secondary-container)', padding: '2px 8px', borderRadius: '8px' }}>
                      Tú
                    </span>
                  )}
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginTop: '4px' }}>
                  {isCurrentUser && (
                    <div style={{ width: '50px', height: '6px', backgroundColor: '#e2e8f0', borderRadius: '3px', position: 'relative', overflow: 'hidden' }}>
                      <div style={{ width: `${user.accuracy}%`, height: '100%', backgroundColor: 'var(--secondary-container)' }}></div>
                    </div>
                  )}
                  <span style={{ fontSize: '0.75rem', color: '#64748b', fontWeight: '600' }}>
                    {user.accuracy}% Precisión
                  </span>
                </div>
              </div>

              {/* Points */}
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontWeight: '900', fontSize: '1.1rem', color: 'var(--primary-container)' }}>
                  {user.puntajeAcumulado.toLocaleString()}
                </div>
                <div style={{ fontSize: '0.65rem', color: '#64748b', fontWeight: '800', letterSpacing: '0.5px' }}>
                  PTS
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
