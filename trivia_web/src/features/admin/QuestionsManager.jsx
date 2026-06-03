import React, { useState, useEffect } from 'react';
import { db } from '../../data/db';

export default function QuestionsManager({ bankId, bankTitle, onBack }) {
  const [questions, setQuestions] = useState([]);
  const [loading, setLoading] = useState(true);

  // New question form states
  const [showAddPanel, setShowAddPanel] = useState(false);
  const [newQuestionText, setNewQuestionText] = useState('');
  const [optA, setOptA] = useState('');
  const [optB, setOptB] = useState('');
  const [optC, setOptC] = useState('');
  const [optD, setOptD] = useState('');
  const [correctIndex, setCorrectIndex] = useState(0);

  // Edit question states
  const [showEditModal, setShowEditModal] = useState(false);
  const [questionToEdit, setQuestionToEdit] = useState(null);
  const [editQuestionText, setEditQuestionText] = useState('');
  const [editOptA, setEditOptA] = useState('');
  const [editOptB, setEditOptB] = useState('');
  const [editOptC, setEditOptC] = useState('');
  const [editOptD, setEditOptD] = useState('');
  const [editCorrectIndex, setEditCorrectIndex] = useState(0);

  useEffect(() => {
    loadQuestions();
  }, [bankId]);

  const loadQuestions = () => {
    setLoading(true);
    const list = db.getQuestions(bankId);
    setQuestions(list);
    setLoading(false);
  };

  const handleAddQuestion = (e) => {
    e.preventDefault();
    if (!newQuestionText || !optA || !optB || !optC || !optD) {
      alert('Por favor completa la pregunta y las 4 alternativas.');
      return;
    }

    const respuestas = [
      { textoRespuesta: optA, esCorrecta: correctIndex === 0 },
      { textoRespuesta: optB, esCorrecta: correctIndex === 1 },
      { textoRespuesta: optC, esCorrecta: correctIndex === 2 },
      { textoRespuesta: optD, esCorrecta: correctIndex === 3 }
    ];

    db.createQuestion(bankId, newQuestionText, respuestas);
    alert('Pregunta agregada con éxito');

    // Reset Form
    setNewQuestionText('');
    setOptA('');
    setOptB('');
    setOptC('');
    setOptD('');
    setCorrectIndex(0);
    setShowAddPanel(false);

    loadQuestions();
  };

  const handleDeleteClick = (question) => {
    const confirm = window.confirm(`¿Estás seguro que deseas eliminar esta pregunta?\n\n"${question.textoPregunta}"`);
    if (confirm) {
      db.deleteQuestion(bankId, question.id);
      alert('Pregunta eliminada correctamente');
      loadQuestions();
    }
  };

  const handleEditClick = (question) => {
    setQuestionToEdit(question);
    setEditQuestionText(question.textoPregunta);
    setEditOptA(question.respuestas[0]?.textoRespuesta || '');
    setEditOptB(question.respuestas[1]?.textoRespuesta || '');
    setEditOptC(question.respuestas[2]?.textoRespuesta || '');
    setEditOptD(question.respuestas[3]?.textoRespuesta || '');

    const correctIdx = question.respuestas.findIndex(r => r.esCorrecta);
    setEditCorrectIndex(correctIdx !== -1 ? correctIdx : 0);
    
    setShowEditModal(true);
  };

  const handleSaveEdit = (e) => {
    e.preventDefault();
    if (!editQuestionText || !editOptA || !editOptB || !editOptC || !editOptD) {
      alert('Completa todos los campos');
      return;
    }

    const respuestas = [
      { textoRespuesta: editOptA, esCorrecta: editCorrectIndex === 0 },
      { textoRespuesta: editOptB, esCorrecta: editCorrectIndex === 1 },
      { textoRespuesta: editOptC, esCorrecta: editCorrectIndex === 2 },
      { textoRespuesta: editOptD, esCorrecta: editCorrectIndex === 3 }
    ];

    db.updateQuestion(bankId, questionToEdit.id, editQuestionText, respuestas);
    alert('Pregunta actualizada');
    setShowEditModal(false);
    loadQuestions();
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
      {/* Header toolbar */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <button onClick={onBack} className="btn btn-outline btn-sm" style={{ padding: '8px 12px' }}>
            ⬅️ Volver
          </button>
          <div>
            <h2 style={{ fontWeight: '800', color: 'var(--on-surface)', fontSize: '1.4rem' }}>
              {bankTitle}
            </h2>
            <p style={{ color: '#64748b', fontSize: '0.8rem', fontWeight: '600' }}>
              Gestión de Preguntas
            </p>
          </div>
        </div>
        <div style={{ padding: '6px 12px', background: 'rgba(70,31,112,0.06)', color: 'var(--primary-container)', borderRadius: '10px', fontSize: '0.8rem', fontWeight: '800' }}>
          ❓ {questions.length} pregunta{questions.length === 1 ? '' : 's'} registrada{questions.length === 1 ? '' : 's'}
        </div>
      </div>

      {/* Questions list */}
      {questions.length === 0 ? (
        <div className="glass-card" style={{ textAlign: 'center', padding: '60px 20px', color: '#64748b', marginBottom: '32px' }}>
          <div style={{ fontSize: '3rem', marginBottom: '16px' }}>❓</div>
          <h4 style={{ fontWeight: '800', marginBottom: '4px' }}>No hay preguntas creadas</h4>
          <p style={{ fontSize: '0.85rem' }}>Crea una pregunta en el panel inferior.</p>
        </div>
      ) : (
        <div style={{ marginBottom: '32px' }}>
          {questions.map((q, idx) => (
            <div key={q.id} className="glass-card" style={{ marginBottom: '16px', padding: '20px' }}>
              {/* Question Header */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: '12px', marginBottom: '16px' }}>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'flex-start' }}>
                  <div style={{ 
                    minWidth: '28px', 
                    height: '28px', 
                    background: 'linear-gradient(135deg, var(--primary-container) 0%, #5a259d 100%)', 
                    color: 'white',
                    fontWeight: 'bold',
                    borderRadius: '8px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    fontSize: '0.85rem'
                  }}>
                    {idx + 1}
                  </div>
                  <h4 style={{ fontWeight: '800', color: '#0f172a', fontSize: '0.95rem', marginTop: '3px', lineHeight: '1.4' }}>
                    {q.textoPregunta}
                  </h4>
                </div>
                
                {/* Action buttons */}
                <div style={{ display: 'flex', gap: '4px' }}>
                  <button 
                    onClick={() => handleEditClick(q)}
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '6px', fontSize: '1rem' }} 
                    title="Editar pregunta"
                  >
                    ✏️
                  </button>
                  <button 
                    onClick={() => handleDeleteClick(q)}
                    style={{ background: 'none', border: 'none', cursor: 'pointer', padding: '6px', fontSize: '1rem' }} 
                    title="Eliminar pregunta"
                  >
                    🗑️
                  </button>
                </div>
              </div>

              {/* Answers */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                {q.respuestas.map((ans, aIdx) => {
                  const letter = String.fromCharCode(65 + aIdx);
                  return (
                    <div 
                      key={aIdx}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '8px',
                        padding: '10px 14px',
                        borderRadius: '10px',
                        backgroundColor: ans.esCorrecta ? '#ecfdf5' : '#f8fafc',
                        border: ans.esCorrecta ? '1.5px solid #10b981' : '1px solid #e2e8f0',
                        color: ans.esCorrecta ? '#065f46' : '#334155',
                        fontSize: '0.85rem'
                      }}
                    >
                      <span style={{ 
                        fontWeight: '800', 
                        color: ans.esCorrecta ? '#10b981' : '#64748b',
                        background: ans.esCorrecta ? 'white' : '#e2e8f0',
                        width: '20px',
                        height: '20px',
                        borderRadius: '4px',
                        display: 'inline-flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.75rem'
                      }}>
                        {letter}
                      </span>
                      <span style={{ fontWeight: ans.esCorrecta ? '700' : 'normal', flex: 1 }}>
                        {ans.textoRespuesta}
                      </span>
                      {ans.esCorrecta && <span style={{ color: '#10b981', fontWeight: 'bold' }}>✓</span>}
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add New Question panel (Collapsible Accordion) */}
      <div className="glass-card" style={{ padding: '0', overflow: 'hidden' }}>
        <div 
          onClick={() => setShowAddPanel(!showAddPanel)}
          style={{ 
            padding: '16px 20px', 
            cursor: 'pointer', 
            background: 'rgba(70,31,112,0.02)', 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center',
            borderBottom: showAddPanel ? '1px solid #e2e8f0' : 'none'
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <span style={{ color: 'var(--primary-container)', fontSize: '1.2rem' }}>➕</span>
            <span style={{ fontWeight: '800', color: 'var(--primary-container)', fontSize: '0.95rem' }}>
              Agregar Nueva Pregunta
            </span>
          </div>
          <span>{showAddPanel ? '▲' : '▼'}</span>
        </div>

        {showAddPanel && (
          <form onSubmit={handleAddQuestion} style={{ padding: '20px' }}>
            <div className="form-group">
              <label className="form-label">Enunciado de la Pregunta *</label>
              <textarea 
                className="form-control"
                rows="2"
                value={newQuestionText}
                onChange={e => setNewQuestionText(e.target.value)}
                placeholder="Ej. ¿Cuál es la capital del Ecuador?"
                required
              />
            </div>

            <label className="form-label" style={{ marginBottom: '12px' }}>
              Alternativas (Marca la opción correcta con el botón radial lateral) *
            </label>

            {/* Option rows */}
            {[
              { label: 'Alternativa A', val: optA, set: setOptA, idx: 0 },
              { label: 'Alternativa B', val: optB, set: setOptB, idx: 1 },
              { label: 'Alternativa C', val: optC, set: setOptC, idx: 2 },
              { label: 'Alternativa D', val: optD, set: setOptD, idx: 3 }
            ].map(row => (
              <div key={row.idx} style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
                <input 
                  type="radio" 
                  name="correct-option-radio"
                  checked={correctIndex === row.idx}
                  onChange={() => setCorrectIndex(row.idx)}
                  style={{ width: '20px', height: '20px', cursor: 'pointer', accentColor: '#10b981' }}
                />
                <input 
                  type="text" 
                  className="form-control"
                  value={row.val}
                  onChange={e => row.set(e.target.value)}
                  placeholder={row.label}
                  style={{ 
                    borderColor: correctIndex === row.idx ? '#10b981' : '#e2e8f0',
                    borderWidth: correctIndex === row.idx ? '2px' : '1px' 
                  }}
                  required
                />
              </div>
            ))}

            <button type="submit" className="btn btn-primary" style={{ marginTop: '16px', minWidth: '160px' }}>
              Guardar Pregunta
            </button>
          </form>
        )}
      </div>

      {/* Edit Question Modal */}
      {showEditModal && questionToEdit && (
        <div className="modal-overlay">
          <div className="modal-card" style={{ maxWidth: '500px' }}>
            <div className="modal-header">
              <span className="modal-title">Editar Pregunta ✏️</span>
              <button onClick={() => setShowEditModal(false)} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>❌</button>
            </div>
            <form onSubmit={handleSaveEdit}>
              <div className="modal-body">
                <div className="form-group">
                  <label className="form-label">Enunciado</label>
                  <textarea 
                    className="form-control"
                    rows="2"
                    value={editQuestionText}
                    onChange={e => setEditQuestionText(e.target.value)}
                    required
                  />
                </div>

                <label className="form-label" style={{ marginBottom: '12px' }}>
                  Alternativas (marca la correcta)
                </label>

                {[
                  { letter: 'A', val: editOptA, set: setEditOptA, idx: 0 },
                  { letter: 'B', val: editOptB, set: setEditOptB, idx: 1 },
                  { letter: 'C', val: editOptC, set: setEditOptC, idx: 2 },
                  { letter: 'D', val: editOptD, set: setEditOptD, idx: 3 }
                ].map(row => (
                  <div key={row.idx} style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
                    <input 
                      type="radio" 
                      name="edit-correct-option"
                      checked={editCorrectIndex === row.idx}
                      onChange={() => setEditCorrectIndex(row.idx)}
                      style={{ width: '20px', height: '20px', cursor: 'pointer', accentColor: '#10b981' }}
                    />
                    <input 
                      type="text" 
                      className="form-control"
                      value={row.val}
                      onChange={e => row.set(e.target.value)}
                      placeholder={`Alternativa ${row.letter}`}
                      style={{ 
                        borderColor: editCorrectIndex === row.idx ? '#10b981' : '#e2e8f0',
                        borderWidth: editCorrectIndex === row.idx ? '2px' : '1px' 
                      }}
                      required
                    />
                  </div>
                ))}
              </div>
              <div className="modal-footer">
                <button type="button" onClick={() => setShowEditModal(false)} className="btn btn-outline btn-sm">
                  Cancelar
                </button>
                <button type="submit" className="btn btn-primary btn-sm">
                  Guardar Cambios
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
