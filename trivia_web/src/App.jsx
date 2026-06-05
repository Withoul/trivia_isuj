import React, { useState, useEffect, useRef, useCallback } from 'react';
import * as api from './services/api';
import { playGoal, playFoul, playTickTock, playSparkle, playCountdownEnd, playTimeWarning } from './utils/audio';
import AvatarIcon, { AVATAR_LIST, AVATAR_LABELS } from './components/AvatarIcons';

// ==================== NICKNAMES PRESETS ====================
const NICKNAME_PRESETS = [
  'EnnerGoleador', 'ChuchoEterno', 'Kitu10', 'DidaParador',
  'Kaviedes9', 'LaTuka9', 'BamBamHurtado', 'TinDelgado',
  'PervisVeloz', 'MoiCaicedo23', 'HincapieMuro', 'KendryCrack'
];

export default function App() {
  // ==================== STATE ====================
  const [gameState, setGameState] = useState('COUNTDOWN');
  const [playerName, setPlayerName] = useState('');
  const [playerAvatar, setPlayerAvatar] = useState('ball');
  const [playerId, setPlayerId] = useState(null);

  // Game session
  const [bankId, setBankId] = useState(null);
  const [timePerQuestion, setTimePerQuestion] = useState(15);
  const [questions, setQuestions] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [timeLeft, setTimeLeft] = useState(15);
  const [selectedAnswerIndex, setSelectedAnswerIndex] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [streak, setStreak] = useState(0);
  const [maxStreak, setMaxStreak] = useState(0);
  const [accumulatedScore, setAccumulatedScore] = useState(0);
  const [correctCount, setCorrectCount] = useState(0);
  const [responseTimes, setResponseTimes] = useState([]);

  // Visual feedback
  const [shake, setShake] = useState(false);
  const [floatingScoreText, setFloatingScoreText] = useState('');
  const [showFloatingScore, setShowFloatingScore] = useState(false);

  // Countdown
  const [waitingTime, setWaitingTime] = useState(10);

  // Leaderboard
  const [rankings, setRankings] = useState([]);

  // Loading/Error
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Admin
  const [isAdminMode, setIsAdminMode] = useState(false);
  const [currentAdmin, setCurrentAdmin] = useState(null);
  const [adminActiveTab, setAdminActiveTab] = useState('banks');
  const [adminEmail, setAdminEmail] = useState('');
  const [adminPassword, setAdminPassword] = useState('');
  const [adminLoginError, setAdminLoginError] = useState('');

  // Admin data
  const [adminBanks, setAdminBanks] = useState([]);
  const [adminQuestions, setAdminQuestions] = useState([]);
  const [adminUsers, setAdminUsers] = useState([]);
  const [selectedBankId, setSelectedBankId] = useState(null);

  // Admin modals
  const [showBankModal, setShowBankModal] = useState(false);
  const [editingBank, setEditingBank] = useState(null);
  const [bankForm, setBankForm] = useState({ titulo: '', is_active: true, tiempo_por_pregunta: 15 });
  const [showQuestionModal, setShowQuestionModal] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState(null);
  const [questionForm, setQuestionForm] = useState({
    texto_pregunta: '',
    respuestas: [
      { texto_respuesta: '', es_correcta: true },
      { texto_respuesta: '', es_correcta: false },
      { texto_respuesta: '', es_correcta: false },
      { texto_respuesta: '', es_correcta: false },
    ]
  });

  const gameTimerRef = useRef(null);
  const countdownTimerRef = useRef(null);

  // ==================== ADMIN MODE DETECTION ====================
  useEffect(() => {
    const handleHashChange = () => {
      if (window.location.hash === '#admin') {
        setIsAdminMode(true);
        const saved = localStorage.getItem('trivia_admin');
        if (saved) {
          try { setCurrentAdmin(JSON.parse(saved)); } catch(e) { /* ignore */ }
        }
      } else {
        setIsAdminMode(false);
      }
    };
    window.addEventListener('hashchange', handleHashChange);
    handleHashChange();
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  // ==================== COUNTDOWN TIMER ====================
  useEffect(() => {
    if (gameState === 'COUNTDOWN' && !isAdminMode) {
      setWaitingTime(10);
      clearInterval(countdownTimerRef.current);
      countdownTimerRef.current = setInterval(() => {
        setWaitingTime((prev) => {
          if (prev <= 1) {
            clearInterval(countdownTimerRef.current);
            try { playCountdownEnd(); } catch(e) {}
            setGameState('CHOOSE_NAME');
            return 0;
          }
          try { playTickTock(); } catch(e) {}
          return prev - 1;
        });
      }, 1000);
    }
    return () => clearInterval(countdownTimerRef.current);
  }, [gameState, isAdminMode]);

  // ==================== RANDOMIZE PROFILE ====================
  const randomizeProfile = () => {
    const nick = NICKNAME_PRESETS[Math.floor(Math.random() * NICKNAME_PRESETS.length)];
    const num = Math.floor(10 + Math.random() * 90);
    const av = AVATAR_LIST[Math.floor(Math.random() * AVATAR_LIST.length)];
    setPlayerName(`${nick}${num}`);
    setPlayerAvatar(av);
  };

  // ==================== START GAME ====================
  const handleStartGame = async () => {
    if (!playerName.trim()) return;
    setLoading(true);
    setError('');

    try {
      // 1. Register player in DB
      const player = await api.createPlayer(playerName.trim(), playerAvatar);
      setPlayerId(player.id);

      // 2. Get active banks
      const banks = await api.getActiveBanks();
      if (!banks || banks.length === 0) {
        setError('No hay trivias disponibles en este momento.');
        setLoading(false);
        return;
      }
      const activeBankId = banks[0].id;
      setBankId(activeBankId);

      // 3. Get 10 random questions
      const data = await api.getQuestions(activeBankId, 10);
      if (!data.preguntas || data.preguntas.length === 0) {
        setError('No hay preguntas disponibles.');
        setLoading(false);
        return;
      }

      setTimePerQuestion(data.tiempo_por_pregunta || 15);
      setQuestions(data.preguntas);
      setCurrentIndex(0);
      setStreak(0);
      setMaxStreak(0);
      setAccumulatedScore(0);
      setCorrectCount(0);
      setResponseTimes([]);
      setSelectedAnswerIndex(null);
      setIsAnswered(false);

      try { playSparkle(); } catch(e) {}
      setGameState('GAMEPLAY');
      startQuestionTimer(data.tiempo_por_pregunta || 15);
    } catch (err) {
      setError('Error al conectar con el servidor. Intenta de nuevo.');
      console.error(err);
    }
    setLoading(false);
  };

  // ==================== QUESTION TIMER ====================
  const startQuestionTimer = useCallback((tpq) => {
    const t = tpq || timePerQuestion;
    setTimeLeft(t);
    clearInterval(gameTimerRef.current);
    gameTimerRef.current = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(gameTimerRef.current);
          handleQuestionTimeout();
          return 0;
        }
        if (prev <= 4) {
          try { playTimeWarning(); } catch(e) {}
        }
        return prev - 1;
      });
    }, 1000);
  }, [timePerQuestion]);

  const handleQuestionTimeout = () => {
    submitAnswer(null, false);
  };

  // ==================== SUBMIT ANSWER ====================
  const submitAnswer = async (index, isCorrect) => {
    clearInterval(gameTimerRef.current);
    setSelectedAnswerIndex(index);
    setIsAnswered(true);

    const timeSpent = timePerQuestion - timeLeft;
    setResponseTimes(prev => [...prev, timeSpent]);

    let pointsEarned = 0;
    if (isCorrect) {
      const newStreak = streak + 1;
      setStreak(newStreak);
      if (newStreak > maxStreak) setMaxStreak(newStreak);
      setCorrectCount(prev => prev + 1);

      const basePoints = 100;
      const speedBonus = timeLeft * 15;
      const streakBonus = newStreak * 50;
      pointsEarned = basePoints + speedBonus + streakBonus;

      setAccumulatedScore(prev => prev + pointsEarned);

      try { playGoal(); } catch(e) {}
      setFloatingScoreText(`+${pointsEarned}${newStreak >= 3 ? ` 🔥x${newStreak}` : ''}`);
      setShowFloatingScore(true);
    } else {
      setStreak(0);
      try { playFoul(); } catch(e) {}
      setShake(true);
      setFloatingScoreText('');
      setShowFloatingScore(false);
    }

    // Advance after delay
    setTimeout(() => {
      setShake(false);
      setShowFloatingScore(false);

      if (currentIndex + 1 < questions.length) {
        setCurrentIndex(prev => prev + 1);
        setSelectedAnswerIndex(null);
        setIsAnswered(false);
        startQuestionTimer();
      } else {
        handleGameEnd();
      }
    }, 1500);
  };

  // ==================== GAME END ====================
  const handleGameEnd = async () => {
    clearInterval(gameTimerRef.current);

    // Submit score to DB
    if (playerId && bankId) {
      try {
        await api.submitScore({
          jugador_id: playerId,
          banco_id: bankId,
          puntaje_neto: accumulatedScore,
          racha_maxima: maxStreak,
          correctas: correctCount,
          total_preguntas: questions.length,
        });
      } catch (err) {
        console.error('Error submitting score:', err);
      }
    }

    setGameState('SUMMARY');
  };

  // ==================== LOAD LEADERBOARD ====================
  const loadLeaderboard = async () => {
    try {
      const data = await api.getRankings(20);
      setRankings(data || []);
    } catch (err) {
      console.error('Error loading rankings:', err);
      setRankings([]);
    }
    setGameState('LEADERBOARD');
  };

  // ==================== PLAY AGAIN ====================
  const playAgain = () => {
    setGameState('COUNTDOWN');
    setPlayerId(null);
    setPlayerName('');
    setPlayerAvatar('ball');
  };

  // ==================== ADMIN FUNCTIONS ====================
  const handleAdminLogin = async (e) => {
    e.preventDefault();
    setAdminLoginError('');
    try {
      const admin = await api.adminLogin(adminEmail, adminPassword);
      setCurrentAdmin(admin);
      localStorage.setItem('trivia_admin', JSON.stringify(admin));
    } catch (err) {
      setAdminLoginError('Correo o contraseña incorrectos.');
    }
  };

  const handleAdminLogout = () => {
    setCurrentAdmin(null);
    localStorage.removeItem('trivia_admin');
  };

  const loadAdminBanks = async () => {
    if (!currentAdmin) return;
    try {
      const data = await api.getAdminBanks(currentAdmin.id);
      setAdminBanks(data || []);
    } catch (err) { console.error(err); }
  };

  const loadAdminQuestions = async (bId) => {
    if (!currentAdmin) return;
    try {
      const data = await api.getAdminQuestions(currentAdmin.id, bId);
      setAdminQuestions(data || []);
    } catch (err) { console.error(err); }
  };

  const loadAdminUsers = async () => {
    if (!currentAdmin) return;
    try {
      const data = await api.getAdminUsers(currentAdmin.id);
      setAdminUsers(data || []);
    } catch (err) { console.error(err); }
  };

  useEffect(() => {
    if (currentAdmin && isAdminMode) {
      if (adminActiveTab === 'banks' || adminActiveTab === 'questions') loadAdminBanks();
      if (adminActiveTab === 'users') loadAdminUsers();
    }
  }, [currentAdmin, isAdminMode, adminActiveTab]);

  // Bank CRUD
  const handleSaveBank = async (e) => {
    e.preventDefault();
    try {
      if (editingBank) {
        await api.updateBank(currentAdmin.id, editingBank.id, bankForm);
      } else {
        await api.createBank(currentAdmin.id, bankForm);
      }
      setShowBankModal(false);
      setEditingBank(null);
      setBankForm({ titulo: '', is_active: true, tiempo_por_pregunta: 15 });
      loadAdminBanks();
    } catch (err) { console.error(err); }
  };

  const handleDeleteBank = async (id) => {
    if (!confirm('¿Eliminar este banco y todas sus preguntas?')) return;
    try {
      await api.deleteBank(currentAdmin.id, id);
      loadAdminBanks();
    } catch (err) { console.error(err); }
  };

  // Question CRUD
  const handleSaveQuestion = async (e) => {
    e.preventDefault();
    try {
      if (editingQuestion) {
        await api.updateQuestion(currentAdmin.id, editingQuestion.id, questionForm);
      } else {
        await api.createQuestion(currentAdmin.id, selectedBankId, questionForm);
      }
      setShowQuestionModal(false);
      setEditingQuestion(null);
      setQuestionForm({
        texto_pregunta: '',
        respuestas: [
          { texto_respuesta: '', es_correcta: true },
          { texto_respuesta: '', es_correcta: false },
          { texto_respuesta: '', es_correcta: false },
          { texto_respuesta: '', es_correcta: false },
        ]
      });
      loadAdminQuestions(selectedBankId);
    } catch (err) { console.error(err); }
  };

  const handleDeleteQuestion = async (qId) => {
    if (!confirm('¿Eliminar esta pregunta?')) return;
    try {
      await api.deleteQuestion(currentAdmin.id, qId);
      loadAdminQuestions(selectedBankId);
    } catch (err) { console.error(err); }
  };

  const handleDeleteUser = async (uId) => {
    if (!confirm('¿Eliminar este jugador y sus puntajes?')) return;
    try {
      await api.deleteUser(currentAdmin.id, uId);
      loadAdminUsers();
    } catch (err) { console.error(err); }
  };

  const updateAnswerField = (idx, field, value) => {
    setQuestionForm(prev => {
      const resps = [...prev.respuestas];
      if (field === 'es_correcta') {
        resps.forEach((r, i) => r.es_correcta = i === idx);
      } else {
        resps[idx] = { ...resps[idx], [field]: value };
      }
      return { ...prev, respuestas: resps };
    });
  };

  // ==================== RENDER: ADMIN MODE ====================
  if (isAdminMode) {
    if (!currentAdmin) {
      return (
        <div className="auth-wrapper">
          <div className="auth-card">
            <div className="auth-header">
              <img src="/assets/logotipos/elemento_puma.png" alt="Puma" style={{ width: 60, margin: '0 auto 12px', display: 'block' }} />
              <h2>Panel de Administración</h2>
            </div>
            <form onSubmit={handleAdminLogin}>
              <div className="form-group">
                <label className="form-label">Correo</label>
                <input className="form-control" type="email" value={adminEmail} onChange={e => setAdminEmail(e.target.value)} required />
              </div>
              <div className="form-group">
                <label className="form-label">Contraseña</label>
                <input className="form-control" type="password" value={adminPassword} onChange={e => setAdminPassword(e.target.value)} required />
              </div>
              {adminLoginError && <p style={{ color: 'var(--danger-red)', marginBottom: 16, fontSize: '0.9rem' }}>{adminLoginError}</p>}
              <button type="submit" className="btn btn-primary btn-block">Ingresar</button>
            </form>
          </div>
        </div>
      );
    }

    return (
      <div className="app-container">
        {/* Sidebar */}
        <nav className="sidebar">
          <div className="sidebar-logo">
            <img src="/assets/logotipos/elemento_puma.png" alt="Logo" />
            <span>Trivia Admin</span>
          </div>
          <div className="sidebar-menu">
            {[
              { id: 'banks', icon: '📚', label: 'Bancos' },
              { id: 'questions', icon: '❓', label: 'Preguntas' },
              { id: 'users', icon: '👥', label: 'Jugadores' },
              { id: 'rankings', icon: '🏆', label: 'Rankings' },
            ].map(tab => (
              <button key={tab.id} className={`sidebar-item ${adminActiveTab === tab.id ? 'active' : ''}`}
                onClick={() => setAdminActiveTab(tab.id)}>
                <span>{tab.icon}</span> {tab.label}
              </button>
            ))}
          </div>
          <div className="sidebar-footer">
            <p style={{ fontSize: '0.8rem', color: 'rgba(255,255,255,0.5)', marginBottom: 8 }}>{currentAdmin.nombre}</p>
            <button className="btn btn-outline btn-sm btn-block" onClick={handleAdminLogout}>Cerrar Sesión</button>
          </div>
        </nav>

        {/* Main Content */}
        <main className="main-content">
          {/* BANKS TAB */}
          {adminActiveTab === 'banks' && (
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
                <h1 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '1.5rem' }}>Bancos de Preguntas</h1>
                <button className="btn btn-primary btn-sm" onClick={() => {
                  setEditingBank(null);
                  setBankForm({ titulo: '', is_active: true, tiempo_por_pregunta: 15 });
                  setShowBankModal(true);
                }}>+ Nuevo Banco</button>
              </div>

              {adminBanks.map(bank => (
                <div key={bank.id} className="glass-card" style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <h3 style={{ color: 'white', fontWeight: 700 }}>{bank.titulo}</h3>
                    <p style={{ fontSize: '0.8rem', color: 'var(--on-surface-variant)' }}>
                      {bank.total_preguntas} preguntas · {bank.tiempo_por_pregunta}s/pregunta · {bank.is_active ? '🟢 Activo' : '🔴 Inactivo'}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button className="btn btn-secondary btn-sm" onClick={() => {
                      setEditingBank(bank);
                      setBankForm({ titulo: bank.titulo, is_active: bank.is_active, tiempo_por_pregunta: bank.tiempo_por_pregunta });
                      setShowBankModal(true);
                    }}>✏️</button>
                    <button className="btn btn-danger btn-sm" onClick={() => handleDeleteBank(bank.id)}>🗑️</button>
                  </div>
                </div>
              ))}

              {/* Bank Modal */}
              {showBankModal && (
                <div className="modal-overlay" onClick={() => setShowBankModal(false)}>
                  <div className="modal-card" onClick={e => e.stopPropagation()}>
                    <div className="modal-header">
                      <span className="modal-title">{editingBank ? 'Editar Banco' : 'Nuevo Banco'}</span>
                      <button onClick={() => setShowBankModal(false)} style={{ background: 'none', border: 'none', color: 'white', fontSize: '1.5rem', cursor: 'pointer' }}>✕</button>
                    </div>
                    <form onSubmit={handleSaveBank}>
                      <div className="modal-body">
                        <div className="form-group">
                          <label className="form-label">Título</label>
                          <input className="form-control" value={bankForm.titulo} onChange={e => setBankForm(p => ({ ...p, titulo: e.target.value }))} required />
                        </div>
                        <div className="form-group">
                          <label className="form-label">Tiempo por Pregunta (segundos)</label>
                          <input className="form-control" type="number" min="5" max="60" value={bankForm.tiempo_por_pregunta} onChange={e => setBankForm(p => ({ ...p, tiempo_por_pregunta: parseInt(e.target.value) }))} />
                        </div>
                        <div className="form-group">
                          <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer', color: 'var(--on-surface)' }}>
                            <input type="checkbox" checked={bankForm.is_active} onChange={e => setBankForm(p => ({ ...p, is_active: e.target.checked }))} />
                            Banco Activo
                          </label>
                        </div>
                      </div>
                      <div className="modal-footer">
                        <button type="button" className="btn btn-outline btn-sm" onClick={() => setShowBankModal(false)}>Cancelar</button>
                        <button type="submit" className="btn btn-primary btn-sm">Guardar</button>
                      </div>
                    </form>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* QUESTIONS TAB */}
          {adminActiveTab === 'questions' && (
            <div>
              <h1 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '1.5rem', marginBottom: 16 }}>Preguntas</h1>

              {/* Bank selector */}
              <div style={{ marginBottom: 24 }}>
                <label className="form-label">Seleccionar Banco</label>
                <select className="form-control" value={selectedBankId || ''} onChange={e => {
                  const bid = parseInt(e.target.value);
                  setSelectedBankId(bid);
                  if (bid) loadAdminQuestions(bid);
                }}>
                  <option value="">-- Selecciona --</option>
                  {adminBanks.map(b => <option key={b.id} value={b.id}>{b.titulo} ({b.total_preguntas} preguntas)</option>)}
                </select>
              </div>

              {selectedBankId && (
                <>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
                    <p style={{ color: 'var(--on-surface-variant)' }}>{adminQuestions.length} preguntas</p>
                    <button className="btn btn-primary btn-sm" onClick={() => {
                      setEditingQuestion(null);
                      setQuestionForm({
                        texto_pregunta: '',
                        respuestas: [
                          { texto_respuesta: '', es_correcta: true },
                          { texto_respuesta: '', es_correcta: false },
                          { texto_respuesta: '', es_correcta: false },
                          { texto_respuesta: '', es_correcta: false },
                        ]
                      });
                      setShowQuestionModal(true);
                    }}>+ Nueva Pregunta</button>
                  </div>

                  {adminQuestions.map((q, qi) => (
                    <div key={q.id} className="glass-card" style={{ marginBottom: 12, padding: 16 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div style={{ flex: 1 }}>
                          <p style={{ fontWeight: 700, color: 'white', marginBottom: 8 }}>{qi + 1}. {q.texto_pregunta}</p>
                          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                            {q.respuestas?.map((r, ri) => (
                              <span key={r.id} style={{
                                fontSize: '0.8rem', padding: '4px 10px', borderRadius: 8,
                                background: r.es_correcta ? 'rgba(16,185,129,0.2)' : 'rgba(255,255,255,0.05)',
                                border: r.es_correcta ? '1px solid var(--success-green)' : '1px solid rgba(255,255,255,0.1)',
                                color: r.es_correcta ? 'var(--success-green)' : 'var(--on-surface-variant)',
                              }}>{String.fromCharCode(65 + ri)}) {r.texto_respuesta}</span>
                            ))}
                          </div>
                        </div>
                        <div style={{ display: 'flex', gap: 6, marginLeft: 12 }}>
                          <button className="btn btn-secondary btn-sm" style={{ padding: '6px 12px' }} onClick={() => {
                            setEditingQuestion(q);
                            setQuestionForm({
                              texto_pregunta: q.texto_pregunta,
                              respuestas: q.respuestas.map(r => ({ texto_respuesta: r.texto_respuesta, es_correcta: r.es_correcta })),
                            });
                            setShowQuestionModal(true);
                          }}>✏️</button>
                          <button className="btn btn-danger btn-sm" style={{ padding: '6px 12px' }} onClick={() => handleDeleteQuestion(q.id)}>🗑️</button>
                        </div>
                      </div>
                    </div>
                  ))}
                </>
              )}

              {/* Question Modal */}
              {showQuestionModal && (
                <div className="modal-overlay" onClick={() => setShowQuestionModal(false)}>
                  <div className="modal-card" style={{ maxWidth: 600 }} onClick={e => e.stopPropagation()}>
                    <div className="modal-header">
                      <span className="modal-title">{editingQuestion ? 'Editar Pregunta' : 'Nueva Pregunta'}</span>
                      <button onClick={() => setShowQuestionModal(false)} style={{ background: 'none', border: 'none', color: 'white', fontSize: '1.5rem', cursor: 'pointer' }}>✕</button>
                    </div>
                    <form onSubmit={handleSaveQuestion}>
                      <div className="modal-body">
                        <div className="form-group">
                          <label className="form-label">Pregunta</label>
                          <textarea className="form-control" rows="3" value={questionForm.texto_pregunta}
                            onChange={e => setQuestionForm(p => ({ ...p, texto_pregunta: e.target.value }))} required />
                        </div>
                        <label className="form-label">Respuestas (marca la correcta)</label>
                        {questionForm.respuestas.map((resp, i) => (
                          <div key={i} style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 10 }}>
                            <input type="radio" name="correcta" checked={resp.es_correcta}
                              onChange={() => updateAnswerField(i, 'es_correcta', true)}
                              style={{ accentColor: 'var(--success-green)' }} />
                            <span style={{ color: 'var(--primary-yellow)', fontWeight: 700, width: 20 }}>{String.fromCharCode(65 + i)})</span>
                            <input className="form-control" style={{ flex: 1 }} value={resp.texto_respuesta}
                              onChange={e => updateAnswerField(i, 'texto_respuesta', e.target.value)} required
                              placeholder={`Respuesta ${String.fromCharCode(65 + i)}`} />
                          </div>
                        ))}
                      </div>
                      <div className="modal-footer">
                        <button type="button" className="btn btn-outline btn-sm" onClick={() => setShowQuestionModal(false)}>Cancelar</button>
                        <button type="submit" className="btn btn-primary btn-sm">Guardar</button>
                      </div>
                    </form>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* USERS TAB */}
          {adminActiveTab === 'users' && (
            <div>
              <h1 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '1.5rem', marginBottom: 24 }}>Jugadores</h1>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', color: 'var(--on-surface)' }}>
                  <thead>
                    <tr style={{ borderBottom: '2px solid var(--royal-blue)' }}>
                      <th style={{ textAlign: 'left', padding: 12, color: 'var(--primary-yellow)', fontSize: '0.8rem', textTransform: 'uppercase' }}>Jugador</th>
                      <th style={{ textAlign: 'center', padding: 12, color: 'var(--primary-yellow)', fontSize: '0.8rem' }}>Puntaje</th>
                      <th style={{ textAlign: 'center', padding: 12, color: 'var(--primary-yellow)', fontSize: '0.8rem' }}>Partidas</th>
                      <th style={{ textAlign: 'center', padding: 12, color: 'var(--primary-yellow)', fontSize: '0.8rem' }}>Racha</th>
                      <th style={{ textAlign: 'center', padding: 12 }}></th>
                    </tr>
                  </thead>
                  <tbody>
                    {adminUsers.map(u => (
                      <tr key={u.id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                        <td style={{ padding: 12, display: 'flex', alignItems: 'center', gap: 10 }}>
                          <AvatarIcon type={u.avatar || 'ball'} size={32} />
                          <span style={{ fontWeight: 600 }}>{u.nombre}</span>
                        </td>
                        <td style={{ textAlign: 'center', padding: 12, fontWeight: 700, color: 'var(--primary-yellow)' }}>{u.puntaje_total}</td>
                        <td style={{ textAlign: 'center', padding: 12 }}>{u.partidas}</td>
                        <td style={{ textAlign: 'center', padding: 12 }}>{u.mejor_racha}</td>
                        <td style={{ textAlign: 'center', padding: 12 }}>
                          <button className="btn btn-danger btn-sm" style={{ padding: '4px 10px' }} onClick={() => handleDeleteUser(u.id)}>🗑️</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* RANKINGS TAB */}
          {adminActiveTab === 'rankings' && (
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
                <h1 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '1.5rem' }}>Rankings Global</h1>
                <button className="btn btn-secondary btn-sm" onClick={async () => {
                  try {
                    const data = await api.getRankings(50);
                    setRankings(data || []);
                  } catch(e) {}
                }}>🔄 Actualizar</button>
              </div>
              {rankings.map((r, i) => (
                <div key={r.jugador_id} className="leader-rank-item" style={{ marginBottom: 8 }}>
                  <span className="leader-pos">{i + 1}</span>
                  <div className="leader-avatar"><AvatarIcon type={r.avatar || 'ball'} size={36} /></div>
                  <div className="leader-name-wrap">
                    <div className="leader-name">{r.nombre}</div>
                    <div className="leader-sub">Racha {r.mejor_racha} · {r.precision}% precisión</div>
                  </div>
                  <div className="leader-score-wrap">
                    <div className="leader-score">{r.puntaje_total}</div>
                    <div className="leader-score-label">PTS</div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </main>
      </div>
    );
  }

  // ==================== RENDER: PLAYER FLOW ====================
  const currentQ = questions[currentIndex];

  // COUNTDOWN SCREEN
  if (gameState === 'COUNTDOWN') {
    return (
      <div className="game-container" style={{ justifyContent: 'center', alignItems: 'center', textAlign: 'center', background: 'radial-gradient(circle at center, #6A1B9A 0%, #4A148C 100%)' }}>
        <img src="/src/assets/Logo-Japon.png" alt="Universitario Japón" style={{ width: 180, marginBottom: 24, opacity: 0.9 }} />
        <div className="countdown-progress-circle" style={{ borderColor: 'rgba(255,255,255,0.2)', boxShadow: '0 0 40px rgba(255,255,255,0.2), inset 0 0 30px rgba(255,221,0,0.05)' }}>
          <div className="countdown-inner-number text-glow" style={{ textShadow: '0 0 20px #fff, 0 0 40px #fff' }}>{waitingTime}</div>
        </div>
      </div>
    );
  }

  // CHOOSE NAME SCREEN
  if (gameState === 'CHOOSE_NAME') {
    return (
      <div className="game-container" style={{ justifyContent: 'center', alignItems: 'center' }}>
        <div style={{ width: '100%', maxWidth: 400, textAlign: 'center' }}>
          <div className="avatar-selection-circle">
            <AvatarIcon type={playerAvatar} size={100} selected />
          </div>

          <button className="dice-randomizer-btn" onClick={randomizeProfile} style={{ margin: '0 auto 20px' }} title="Aleatorio">🎲</button>

          {/* Avatar grid */}
          <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: 10, marginBottom: 24 }}>
            {AVATAR_LIST.map(av => (
              <AvatarIcon key={av} type={av} size={48} selected={playerAvatar === av} onClick={() => setPlayerAvatar(av)} />
            ))}
          </div>

          <input className="form-control" style={{ textAlign: 'center', fontSize: '1.1rem', marginBottom: 20 }}
            placeholder="Tu nombre de crack..."
            value={playerName} onChange={e => setPlayerName(e.target.value)}
            maxLength={30} />

          {error && <p style={{ color: 'var(--danger-red)', marginBottom: 12, fontSize: '0.9rem' }}>{error}</p>}

          <button className="btn btn-primary btn-block" onClick={handleStartGame} disabled={loading || !playerName.trim()}
            style={{ fontSize: '1.1rem', padding: '14px 32px' }}>
            {loading ? '⏳ Cargando...' : '¡A JUGAR! ⚽'}
          </button>
        </div>
      </div>
    );
  }

  // GAMEPLAY SCREEN
  if (gameState === 'GAMEPLAY' && currentQ) {
    const progress = ((currentIndex + 1) / questions.length) * 100;
    const letters = ['A', 'B', 'C', 'D'];

    return (
      <div className={`game-container ${shake ? 'animate-shake' : ''}`}>
        {/* Progress header */}
        <div className="progreso-header">
          <span style={{ fontFamily: 'var(--font-family-condensed)', fontWeight: 800, color: 'var(--on-surface-variant)', fontSize: '0.85rem' }}>
            {currentIndex + 1}/{questions.length}
          </span>
          <div className={`timer-box ${timeLeft <= 3 ? 'warning' : ''}`}>
            ⏱ {timeLeft}s
          </div>
          <span style={{ fontFamily: 'var(--font-family)', fontWeight: 900, color: 'var(--primary-yellow)', fontSize: '1rem' }}>
            {accumulatedScore} pts
          </span>
        </div>

        <div className="progress-bar-track">
          <div className="progress-bar-fill" style={{ width: `${progress}%` }} />
        </div>

        {/* Streak indicator */}
        {streak >= 2 && (
          <div style={{ textAlign: 'center', margin: '12px 0 0', color: 'var(--primary-yellow)', fontWeight: 800, fontSize: '0.85rem' }}>
            🔥 Racha x{streak}
          </div>
        )}

        {/* Floating points */}
        <div className="floating-points-container">
          {showFloatingScore && (
            <span className={`floating-points-text animate-pop-score ${streak >= 3 ? 'streak-alert' : ''}`}>
              {floatingScoreText}
            </span>
          )}
        </div>

        {/* Question */}
        <div className="question-card">
          <p className="question-text">{currentQ.texto_pregunta}</p>
        </div>

        {/* Options */}
        <div className="options-list">
          {currentQ.respuestas.map((resp, i) => {
            let cls = 'answer-card';
            if (isAnswered) {
              cls += ' disabled';
              if (resp.es_correcta) cls += ' correct';
              else if (i === selectedAnswerIndex && !resp.es_correcta) cls += ' incorrect';
            } else if (i === selectedAnswerIndex) {
              cls += ' selected';
            }

            return (
              <div key={resp.id || i} className={cls}
                onClick={() => !isAnswered && submitAnswer(i, resp.es_correcta)}>
                <span className="answer-letter">{letters[i]}</span>
                <span style={{ fontWeight: 600, flex: 1 }}>{resp.texto_respuesta}</span>
                {isAnswered && resp.es_correcta && <span>✅</span>}
                {isAnswered && i === selectedAnswerIndex && !resp.es_correcta && <span>❌</span>}
              </div>
            );
          })}
        </div>
      </div>
    );
  }

  // SUMMARY SCREEN
  if (gameState === 'SUMMARY') {
    const accuracy = questions.length > 0 ? Math.round((correctCount / questions.length) * 100) : 0;
    const avgTime = responseTimes.length > 0 ? (responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length).toFixed(1) : 0;

    return (
      <div className="game-container" style={{ justifyContent: 'center', alignItems: 'center', textAlign: 'center' }}>
        <img src="/assets/logotipos/elemento_puma.png" alt="" style={{ width: 64, marginBottom: 12, filter: 'drop-shadow(0 0 15px rgba(255,221,0,0.4))' }} />
        <h1 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '2.5rem', marginBottom: 4 }} className="text-glow">
          {accumulatedScore}
        </h1>
        <p style={{ color: 'var(--on-surface-variant)', fontSize: '0.9rem', marginBottom: 24, fontWeight: 700, textTransform: 'uppercase' }}>Puntos Totales</p>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12, marginBottom: 32, width: '100%', maxWidth: 400 }}>
          <div className="glass-card" style={{ padding: 16, textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', fontWeight: 900, color: 'var(--success-green)' }}>{accuracy}%</div>
            <div style={{ fontSize: '0.7rem', color: 'var(--on-surface-variant)', fontWeight: 700, textTransform: 'uppercase' }}>Precisión</div>
          </div>
          <div className="glass-card" style={{ padding: 16, textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', fontWeight: 900, color: 'var(--primary-yellow)' }}>🔥 {maxStreak}</div>
            <div style={{ fontSize: '0.7rem', color: 'var(--on-surface-variant)', fontWeight: 700, textTransform: 'uppercase' }}>Mejor Racha</div>
          </div>
          <div className="glass-card" style={{ padding: 16, textAlign: 'center' }}>
            <div style={{ fontSize: '1.5rem', fontWeight: 900, color: 'white' }}>{avgTime}s</div>
            <div style={{ fontSize: '0.7rem', color: 'var(--on-surface-variant)', fontWeight: 700, textTransform: 'uppercase' }}>Tiempo Prom.</div>
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12, width: '100%', maxWidth: 400 }}>
          <button className="btn btn-primary btn-block" onClick={loadLeaderboard}>🏆 Ver Rankings</button>
          <button className="btn btn-secondary btn-block" onClick={playAgain}>🔄 Jugar de Nuevo</button>
        </div>
      </div>
    );
  }

  // LEADERBOARD SCREEN
  if (gameState === 'LEADERBOARD') {
    const top3 = rankings.slice(0, 3);
    const rest = rankings.length >= 3 ? rankings.slice(3) : rankings;
    const podiumOrder = top3.length >= 3 ? [top3[1], top3[0], top3[2]] : [];

    return (
      <div className="game-container" style={{ justifyContent: 'flex-start', paddingTop: 24 }}>
        <h2 style={{ color: 'var(--primary-yellow)', fontWeight: 900, fontSize: '1.5rem', textAlign: 'center', marginBottom: 8 }} className="text-glow">
          Cuadro de Honor
        </h2>

        {/* Podium */}
        {top3.length >= 3 && (
          <div className="podium-container">
            {podiumOrder.map((r, i) => {
              const pos = i === 1 ? 0 : i === 0 ? 1 : 2;
              const pillClass = pos === 0 ? 'first' : pos === 1 ? 'second' : 'third';
              return (
                <div key={r.jugador_id} className={`podium-column ${pillClass}`}>
                  <div className="podium-avatar-wrapper">
                    {pos === 0 && <span className="podium-crown">👑</span>}
                    <div className="podium-avatar">
                      <AvatarIcon type={r.avatar || 'ball'} size={pos === 0 ? 56 : 44} selected={pos === 0} />
                    </div>
                    <span className="podium-badge">#{pos + 1}</span>
                  </div>
                  <p style={{ fontWeight: 700, fontSize: '0.8rem', color: 'white', marginBottom: 4, textAlign: 'center' }}>{r.nombre}</p>
                  <div className={`podium-pillar ${pillClass}`}>
                    <span style={{ fontWeight: 900, fontSize: '1.1rem' }}>{r.puntaje_total}</span>
                    <span style={{ fontSize: '0.6rem', opacity: 0.7 }}>PTS</span>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Rest of rankings */}
        <div style={{ marginTop: 16 }}>
          {rest.map((r, i) => (
            <div key={r.jugador_id} className={`leader-rank-item ${r.nombre === playerName ? 'highlighted' : ''}`}>
              <span className="leader-pos">{rankings.length >= 3 ? i + 4 : i + 1}</span>
              <div className="leader-avatar"><AvatarIcon type={r.avatar || 'ball'} size={36} /></div>
              <div className="leader-name-wrap">
                <div className="leader-name">{r.nombre}</div>
                <div className="leader-sub">{r.precision}% precisión</div>
              </div>
              <div className="leader-score-wrap">
                <div className="leader-score">{r.puntaje_total}</div>
                <div className="leader-score-label">PTS</div>
              </div>
            </div>
          ))}
        </div>

        <button className="btn btn-primary btn-block" onClick={playAgain} style={{ marginTop: 24 }}>
          🔄 Volver a Jugar
        </button>
      </div>
    );
  }

  return null;
}
