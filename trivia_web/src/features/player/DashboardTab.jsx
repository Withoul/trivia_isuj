import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function DashboardTab({ user, onStartQuiz, onRefreshUser }) {
  const [banks, setBanks] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadBanks();
  }, []);

  const loadBanks = () => {
    setLoading(true);
    const activeBanks = db.getActiveBanks();
    setBanks(activeBanks);
    setLoading(false);
  };

  const getExpiryText = (bank) => {
    if (bank.esPermanente || !bank.tiempoFin) {
      return 'Sin límite de tiempo';
    }
    const difference = new Date(bank.tiempoFin) - new Date();
    if (difference <= 0) {
      return '¡Expirando ya!';
    }
    const diffMins = Math.floor(difference / (1000 * 60));
    const diffHours = Math.floor(diffMins / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffDays > 0) {
      return `Termina en ${diffDays} d y ${diffHours % 24} h`;
    } else if (diffHours > 0) {
      return `Termina en ${diffHours} h y ${diffMins % 60} m`;
    } else if (diffMins > 0) {
      return `¡Finaliza en ${diffMins} minutos!`;
    } else {
      return '¡Expirando ya!';
    }
  };

  // Extract featured and others
  let featuredQuiz = null;
  let otherQuizzes = [];

  if (banks.length > 0) {
    // Filter dated upcoming quizzes
    const datedBanks = banks.filter(b => b.tiempoFin && new Date(b.tiempoFin) > new Date());
    if (datedBanks.length > 0) {
      // Sort by closest ending
      datedBanks.sort((a, b) => new Date(a.tiempoFin) - new Date(b.tiempoFin));
      featuredQuiz = datedBanks[0];
    } else {
      // Fallback: sort by ID
      const sorted = [...banks].sort((a, b) => a.id - b.id);
      featuredQuiz = sorted[0];
    }
    otherQuizzes = banks.filter(b => b.id !== featuredQuiz.id);
  }

  const handleRefresh = () => {
    loadBanks();
    onRefreshUser();
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
      {/* Welcome Banner Card */}
      <div className="glass-card gradient-dark-purple" style={{ marginBottom: '32px' }}>
        <h1 style={{ fontWeight: '800', fontSize: '2rem', marginBottom: '8px', letterSpacing: '-0.5px' }}>
          ¡Hola, {user.primerNombre || 'Estudiante'}! 👋
        </h1>
        <p style={{ opacity: 0.8, fontSize: '0.95rem', marginBottom: '16px' }}>
          Institución: {user.institucion || 'ISUJ'}
        </p>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', padding: '8px 16px', background: 'rgba(255,255,255,0.12)', borderRadius: '12px' }}>
          <span style={{ color: '#FFC70A', fontSize: '1.2rem', fontWeight: 'bold' }}>⭐</span>
          <span style={{ fontWeight: '700', fontSize: '0.95rem' }}>
            Puntos Acumulados: {user.puntosDisponibles.toLocaleString()} PTS
          </span>
        </div>
      </div>

      <div className="bento-grid">
        {/* Left Column: Featured & Lists */}
        <div>
          {/* Featured Quiz Card */}
          {featuredQuiz && (
            <div style={{ marginBottom: '32px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '12px' }}>
                <span style={{ fontSize: '1.2rem', color: '#F97316' }}>⏱️</span>
                <h3 style={{ fontWeight: '800', color: 'var(--on-surface)' }}>Trivia por Finalizar</h3>
              </div>
              <div className="player-card gradient-orange" style={{ padding: '24px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                  <div style={{ padding: '6px 12px', background: 'rgba(255,255,255,0.2)', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '800' }}>
                    ⚡ {getExpiryText(featuredQuiz)}
                  </div>
                  <span style={{ fontSize: '1.2rem' }}>⭐</span>
                </div>
                <h2 style={{ fontWeight: '900', fontSize: '1.6rem', marginBottom: '8px' }}>
                  {featuredQuiz.titulo}
                </h2>
                <p style={{ fontSize: '0.9rem', opacity: 0.9, marginBottom: '24px', lineHeight: '1.4' }}>
                  Cuestionario destacado en vivo. ¡Responde rápido y mantén tu racha para multiplicar tus puntos!
                </p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <span style={{ fontSize: '0.85rem', opacity: 0.8, fontWeight: '700' }}>
                    ❓ {db.getQuestions(featuredQuiz.id).length} Preguntas
                  </span>
                  <button 
                    onClick={() => onStartQuiz(featuredQuiz)}
                    className="btn btn-secondary" 
                    style={{ padding: '10px 20px', borderRadius: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}
                  >
                    Jugar Ahora <span style={{ fontSize: '1rem' }}>▶️</span>
                  </button>
                </div>
              </div>
            </div>
          )}

          {/* Explorar Cuestionarios */}
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '16px' }}>
              <span style={{ fontSize: '1.2rem', color: 'var(--primary-container)' }}>🧭</span>
              <h3 style={{ fontWeight: '800', color: 'var(--on-surface)' }}>Explorar Cuestionarios</h3>
            </div>

            {otherQuizzes.length === 0 && !featuredQuiz ? (
              <div style={{ textAlign: 'center', padding: '40px 20px', color: '#64748b' }}>
                <div style={{ fontSize: '2.5rem', marginBottom: '12px' }}>📭</div>
                <h4 style={{ fontWeight: '700' }}>No hay cuestionarios activos</h4>
                <p style={{ fontSize: '0.85rem' }}>Vuelve más tarde para nuevos desafíos.</p>
                <button onClick={handleRefresh} className="btn btn-outline btn-sm" style={{ marginTop: '16px' }}>
                  Actualizar
                </button>
              </div>
            ) : otherQuizzes.length === 0 ? (
              <p style={{ color: '#94a3b8', fontSize: '0.9rem', textAlign: 'center', padding: '12px' }}>
                No hay más cuestionarios activos por ahora.
              </p>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                {otherQuizzes.map(quiz => (
                  <div key={quiz.id} className="player-card gradient-purple" style={{ padding: '24px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                      <div style={{ padding: '4px 10px', background: 'rgba(74,222,128,0.15)', color: '#4edea3', borderRadius: '12px', fontSize: '0.75rem', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <span style={{ display: 'inline-block', width: '6px', height: '6px', backgroundColor: '#4edea3', borderRadius: '50%' }}></span>
                        ACTIVO
                      </div>
                      <span style={{ fontSize: '1.2rem', color: '#ffc70a' }}>🏆</span>
                    </div>
                    <h3 style={{ fontWeight: '800', fontSize: '1.25rem', marginBottom: '8px' }}>
                      {quiz.titulo}
                    </h3>
                    <p style={{ fontSize: '0.85rem', opacity: 0.8, marginBottom: '20px' }}>
                      Demuestra lo aprendido en este cuestionario. No salgas del juego o se registrará tu puntaje acumulado actual.
                    </p>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <span style={{ fontSize: '0.8rem', opacity: 0.8, fontWeight: '700' }}>
                        ❓ {db.getQuestions(quiz.id).length} Preguntas
                      </span>
                      <button 
                        onClick={() => onStartQuiz(quiz)}
                        className="btn btn-secondary" 
                        style={{ padding: '8px 16px', borderRadius: '8px', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '6px' }}
                      >
                        Jugar <span style={{ fontSize: '0.8rem' }}>▶️</span>
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Mini Stats or Quick Refresh */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div className="glass-card" style={{ padding: '20px' }}>
            <h4 style={{ fontWeight: '800', marginBottom: '12px', borderBottom: '1.5px solid #f1f5f9', paddingBottom: '8px' }}>
              ⚡ Resumen de Progreso
            </h4>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#64748b', fontSize: '0.85rem' }}>Quizzes Completados</span>
                <span style={{ fontWeight: '700' }}>{user.quizzesCompletados}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ color: '#64748b', fontSize: '0.85rem' }}>Racha Máxima</span>
                <span style={{ fontWeight: '700', color: 'var(--streak-orange)' }}>🔥 {user.rachaMaxima}x</span>
              </div>
            </div>
            <button onClick={handleRefresh} className="btn btn-primary btn-block btn-sm" style={{ marginTop: '20px' }}>
              Actualizar Datos
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
