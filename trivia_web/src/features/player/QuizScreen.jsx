import React, { useState, useEffect, useRef } from 'react';
import { db } from '../../data/db';

export default function QuizScreen({ bankId, bankTitle, onClose, onRefreshUser }) {
  const [questions, setQuestions] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [accumulatedScore, setAccumulatedScore] = useState(0);
  const [loading, setLoading] = useState(true);

  // Timer & feedback states
  const [timeLeft, setTimeLeft] = useState(12);
  const [selectedAnswerIndex, setSelectedAnswerIndex] = useState(null);
  const [isAnswered, setIsAnswered] = useState(false);
  const [streak, setStreak] = useState(0);

  // Animations
  const [shake, setShake] = useState(false);
  const [floatingScoreText, setFloatingScoreText] = useState('');
  const [showFloatingScore, setShowFloatingScore] = useState(false);
  const [showExitModal, setShowExitModal] = useState(false);

  const timerRef = useRef(null);

  useEffect(() => {
    const loadedQuestions = db.getQuestions(bankId);
    setQuestions(loadedQuestions);
    setLoading(false);
    startTimer();

    return () => clearInterval(timerRef.current);
  }, [bankId]);

  const startTimer = () => {
    setTimeLeft(12);
    clearInterval(timerRef.current);
    timerRef.current = setInterval(() => {
      setTimeLeft(prev => {
        if (prev <= 1) {
          clearInterval(timerRef.current);
          handleTimeout();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleTimeout = () => {
    setStreak(0);
    answerQuestion(null, false);
  };

  const answerQuestion = async (answerIndex, isCorrect) => {
    clearInterval(timerRef.current);
    setSelectedAnswerIndex(answerIndex);
    setIsAnswered(true);

    let pointsEarned = 0;

    if (isCorrect) {
      const newStreak = streak + 1;
      setStreak(newStreak);

      // Score Calculation logic
      // Base: 5, Speed Bonus: timeLeft / 2, Streak Bonus: newStreak
      const basePoints = 5;
      const speedBonus = Math.floor(timeLeft / 2);
      const streakBonus = newStreak;

      pointsEarned = basePoints + speedBonus + streakBonus;
      setAccumulatedScore(prev => prev + pointsEarned);

      setFloatingScoreText(`+${pointsEarned} PTS ${newStreak > 1 ? `(Racha ${newStreak}x!)` : ''}`);
      setShowFloatingScore(true);
    } else {
      setStreak(0);
      setShake(true);
      setTimeout(() => setShake(false), 500);
    }

    // Wait 1.5 seconds for visual feedback
    await new Promise(resolve => setTimeout(resolve, 1500));

    setShowFloatingScore(false);

    if (currentIndex < questions.length - 1) {
      setCurrentIndex(prev => prev + 1);
      setSelectedAnswerIndex(null);
      setIsAnswered(false);
      startTimer();
    } else {
      // Completed final question
      await completeQuiz(accumulatedScore + pointsEarned);
    }
  };

  const completeQuiz = async (finalScore) => {
    db.submitScore(bankId, finalScore);
    alert(`¡Cuestionario finalizado! Excelente trabajo. Puntaje: ${finalScore} PTS`);
    onRefreshUser();
    onClose();
  };

  const handleExitWithPartialScore = () => {
    clearInterval(timerRef.current);
    db.submitScore(bankId, accumulatedScore);
    alert(`Cuestionario interrumpido. Puntaje guardado: ${accumulatedScore} PTS`);
    onRefreshUser();
    onClose();
  };

  if (loading) {
    return (
      <div className="quiz-wrapper" style={{ justifyContent: 'center', alignItems: 'center' }}>
        <div className="quiz-timer-circle normal">⏳</div>
      </div>
    );
  }

  if (questions.length === 0) {
    return (
      <div className="quiz-wrapper" style={{ padding: '40px', textAlign: 'center' }}>
        <h3 style={{ marginBottom: '20px' }}>No hay preguntas en este banco.</h3>
        <button onClick={onClose} className="btn btn-primary">Regresar</button>
      </div>
    );
  }

  const currentQuestion = questions[currentIndex];
  const answers = currentQuestion.respuestas;
  const progress = ((currentIndex + 1) / questions.length) * 100;

  return (
    <div className="quiz-wrapper">
      {/* Quiz Header */}
      <div className="quiz-header">
        <button 
          onClick={() => setShowExitModal(true)} 
          style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: 'var(--primary-container)' }}
        >
          ❌
        </button>
        <span style={{ fontWeight: '800', color: 'var(--primary-container)', fontSize: '1.1rem' }}>
          {bankTitle}
        </span>
        <div className={`quiz-timer-circle ${timeLeft <= 4 ? 'warning' : 'normal'}`}>
          {timeLeft}
        </div>
      </div>

      {/* Main Body */}
      <div style={{ flex: 1, padding: '24px', maxWidth: '640px', width: '100%', margin: '0 auto', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
        {/* Info row */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <div style={{ padding: '6px 12px', background: 'rgba(48,1,90,0.06)', color: 'var(--primary-container)', borderRadius: '10px', fontSize: '0.8rem', fontWeight: '800' }}>
            Pregunta {currentIndex + 1} de {questions.length}
          </div>
          {streak > 0 && (
            <div style={{ padding: '6px 12px', background: 'rgba(249,115,22,0.12)', border: '1.5px solid var(--streak-orange)', color: 'var(--streak-orange)', borderRadius: '12px', fontSize: '0.85rem', fontWeight: '800' }}>
              🔥 Racha x{streak}
            </div>
          )}
        </div>

        {/* Question Statement */}
        <h2 style={{ fontWeight: '800', fontSize: '1.5rem', marginBottom: '24px', lineHeight: '1.3', color: 'var(--on-surface)' }}>
          {currentQuestion.textoPregunta}
        </h2>

        {/* Floating Points Pop */}
        <div className="floating-points-container">
          {showFloatingScore && (
            <div className="floating-points-text animate-pop-score">
              {floatingScoreText}
            </div>
          )}
        </div>

        {/* Options list */}
        <div className={shake ? 'animate-shake' : ''} style={{ flex: 1 }}>
          {answers.map((ans, idx) => {
            const letter = String.fromCharCode(65 + idx);
            const isSelected = selectedAnswerIndex === idx;
            
            let cardClass = '';
            if (isSelected) cardClass = 'selected';
            if (isAnswered) {
              if (ans.esCorrecta) cardClass = 'correct';
              else if (isSelected) cardClass = 'incorrect';
            }

            return (
              <div 
                key={idx}
                onClick={() => !isAnswered && answerQuestion(idx, ans.esCorrecta)}
                className={`quiz-option-card ${cardClass} ${isAnswered ? 'disabled' : ''}`}
              >
                <div className="quiz-option-letter">
                  {letter}
                </div>
                <div style={{ fontWeight: '600', fontSize: '0.95rem', flex: 1 }}>
                  {ans.textoRespuesta}
                </div>
                {isAnswered && ans.esCorrecta && (
                  <span style={{ color: '#10b981', fontWeight: 'bold' }}>✓</span>
                )}
                {isAnswered && isSelected && !ans.esCorrecta && (
                  <span style={{ color: 'var(--error)', fontWeight: 'bold' }}>✗</span>
                )}
              </div>
            );
          })}
        </div>

        {/* Bottom Progress Bar */}
        <div className="quiz-progress-bar-container">
          <div className="quiz-progress-bar" style={{ width: `${progress}%` }}></div>
        </div>
      </div>

      {/* Exit Confirmation Modal */}
      {showExitModal && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '400px' }}>
            <div className="modal-header">
              <span className="modal-title">¿Interrumpir Cuestionario?</span>
              <button onClick={() => setShowExitModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <div className="modal-body">
              <p style={{ fontSize: '0.9rem', color: '#4b5563', lineHeight: '1.4' }}>
                Si sales ahora, se registrará tu puntaje acumulado actual de <strong>{accumulatedScore} PTS</strong>. No podrás reanudar esta sesión.
              </p>
            </div>
            <div className="modal-footer">
              <button onClick={() => setShowExitModal(false)} className="btn btn-outline btn-sm">
                Cancelar
              </button>
              <button onClick={handleExitWithPartialScore} className="btn btn-danger btn-sm">
                Salir y Guardar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
