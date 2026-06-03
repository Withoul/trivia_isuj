import React, { useState, useEffect } from 'react';
import { db } from './data/db';
import AuthScreens from './features/auth/AuthScreens';
import DashboardTab from './features/player/DashboardTab';
import QuizScreen from './features/player/QuizScreen';
import RankingsTab from './features/player/RankingsTab';
import TiendaTab from './features/player/TiendaTab';
import ProfileTab from './features/player/ProfileTab';

// Admin views
import BanksList from './features/admin/BanksList';
import QuestionsManager from './features/admin/QuestionsManager';
import UsersManager from './features/admin/UsersManager';
import TiendaManager from './features/admin/TiendaManager';

export default function App() {
  const [currentUser, setCurrentUser] = useState(null);
  const [activeTab, setActiveTab] = useState('dashboard'); // 'dashboard', 'rankings', 'tienda', 'profile', 'admin-banks', 'admin-questions', 'admin-users', 'admin-tienda', 'admin-profile'
  const [activeQuiz, setActiveQuiz] = useState(null); // { id, title }

  useEffect(() => {
    // Check if user is logged in
    const user = db.getCurrentUser();
    if (user) {
      setCurrentUser(user);
      if (user.tipoPerfil === 'ADMINISTRADOR') {
        setActiveTab('admin-banks');
      } else {
        setActiveTab('dashboard');
      }
    }
  }, []);

  const handleAuthSuccess = (user) => {
    setCurrentUser(user);
    if (user.tipoPerfil === 'ADMINISTRADOR') {
      setActiveTab('admin-banks');
    } else {
      setActiveTab('dashboard');
    }
  };

  const handleLogout = () => {
    db.logout();
    setCurrentUser(null);
    setActiveQuiz(null);
  };

  const refreshUser = () => {
    const freshUser = db.getCurrentUser();
    if (freshUser) {
      setCurrentUser(freshUser);
    }
  };

  // If a quiz is active, it runs in fullscreen
  if (currentUser && activeQuiz) {
    return (
      <QuizScreen 
        bankId={activeQuiz.id} 
        bankTitle={activeQuiz.title} 
        onClose={() => setActiveQuiz(null)}
        onRefreshUser={refreshUser}
      />
    );
  }

  // Unauthenticated view
  if (!currentUser) {
    return <AuthScreens onAuthSuccess={handleAuthSuccess} />;
  }

  const isAdmin = currentUser.tipoPerfil === 'ADMINISTRADOR';

  return (
    <div className="app-container">
      
      {/* Sidebar Navigation */}
      <aside className={`sidebar ${isAdmin ? 'sidebar-admin' : ''}`}>
        <div className="sidebar-logo">
          <img src="/assets/logotipos/icon_app_trivia.png" alt="Quiz App Logo" onError={(e) => { e.target.src = '🎓' }} />
          <span>{isAdmin ? 'Admin Pulse' : 'Trivia ISUJ'}</span>
        </div>

        <nav className="sidebar-menu">
          {!isAdmin ? (
            // PLAYER MENUS
            <>
              <button 
                onClick={() => setActiveTab('dashboard')} 
                className={`sidebar-item ${activeTab === 'dashboard' ? 'active' : ''}`}
              >
                🏠 Dashboard
              </button>
              <button 
                onClick={() => setActiveTab('rankings')} 
                className={`sidebar-item ${activeTab === 'rankings' ? 'active' : ''}`}
              >
                🏆 Posiciones
              </button>
              <button 
                onClick={() => setActiveTab('tienda')} 
                className={`sidebar-item ${activeTab === 'tienda' ? 'active' : ''}`}
              >
                🎁 Tienda Canje
              </button>
              <button 
                onClick={() => setActiveTab('profile')} 
                className={`sidebar-item ${activeTab === 'profile' ? 'active' : ''}`}
              >
                👤 Mi Perfil
              </button>
            </>
          ) : (
            // ADMIN MENUS
            <>
              <button 
                onClick={() => setActiveTab('admin-banks')} 
                className={`sidebar-item ${activeTab === 'admin-banks' || activeTab === 'admin-questions' ? 'active' : ''}`}
              >
                📁 Cuestionarios
              </button>
              <button 
                onClick={() => setActiveTab('admin-users')} 
                className={`sidebar-item ${activeTab === 'admin-users' ? 'active' : ''}`}
              >
                👥 Usuarios
              </button>
              <button 
                onClick={() => setActiveTab('admin-tienda')} 
                className={`sidebar-item ${activeTab === 'admin-tienda' ? 'active' : ''}`}
              >
                🛒 Tienda Admin
              </button>
              <button 
                onClick={() => setActiveTab('admin-profile')} 
                className={`sidebar-item ${activeTab === 'admin-profile' ? 'active' : ''}`}
              >
                🛡️ Mi Perfil
              </button>
            </>
          )}
        </nav>

        <div className="sidebar-footer">
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.8rem', opacity: 0.7 }}>
            <span>👤</span>
            <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              <strong>{currentUser.primerNombre} {currentUser.primerApellido[0]}.</strong>
              <div style={{ fontSize: '0.7rem' }}>{currentUser.correo}</div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Area */}
      <main className="main-content">
        
        {/* Render Tab Contents */}
        {!isAdmin ? (
          // PLAYER VIEWS
          <>
            {activeTab === 'dashboard' && (
              <DashboardTab 
                user={currentUser} 
                onStartQuiz={(quiz) => setActiveQuiz({ id: quiz.id, title: quiz.titulo })}
                onRefreshUser={refreshUser}
              />
            )}
            {activeTab === 'rankings' && <RankingsTab currentUser={currentUser} />}
            {activeTab === 'tienda' && <TiendaTab user={currentUser} onRefreshUser={refreshUser} />}
            {activeTab === 'profile' && (
              <ProfileTab 
                user={currentUser} 
                onRefreshUser={refreshUser} 
                onLogout={handleLogout} 
              />
            )}
          </>
        ) : (
          // ADMIN VIEWS
          <>
            {activeTab === 'admin-banks' && (
              <BanksList 
                onManageQuestions={(bankId, bankTitle) => {
                  setActiveTab('admin-questions');
                  // Save state in custom attribute
                  window._selectedAdminBank = { id: bankId, title: bankTitle };
                }} 
              />
            )}
            {activeTab === 'admin-questions' && (
              <QuestionsManager 
                bankId={window._selectedAdminBank?.id}
                bankTitle={window._selectedAdminBank?.title}
                onBack={() => setActiveTab('admin-banks')}
              />
            )}
            {activeTab === 'admin-users' && <UsersManager />}
            {activeTab === 'admin-tienda' && <TiendaManager />}
            {activeTab === 'admin-profile' && (
              <div style={{ maxWidth: '600px', margin: '0 auto' }}>
                <div className="glass-card" style={{ textAlign: 'center', padding: '40px' }}>
                  <div style={{ fontSize: '4rem', marginBottom: '16px' }}>🛡️</div>
                  <h2 style={{ fontWeight: '800', marginBottom: '8px' }}>Perfil de Administrador</h2>
                  <p style={{ color: '#64748b', marginBottom: '24px' }}>{currentUser.correo}</p>
                  
                  <div style={{ borderTop: '1px solid #e2e8f0', paddingTop: '24px', display: 'flex', flexDirection: 'column', gap: '12px', textAlign: 'left' }}>
                    <div><strong>Nombre completo:</strong> {currentUser.primerNombre} {currentUser.primerApellido}</div>
                    <div><strong>Institución/Carrera:</strong> {currentUser.institucion}</div>
                    <div><strong>Rol asignado:</strong> ADMINISTRADOR</div>
                  </div>

                  <button onClick={handleLogout} className="btn btn-danger" style={{ marginTop: '32px', width: '100%' }}>
                    🚪 Cerrar Sesión
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
}
