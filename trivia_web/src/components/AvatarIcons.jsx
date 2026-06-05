import React from 'react';

export const AVATAR_LIST = ['ball', 'gloves', 'trophy', 'boot'];

export const AVATAR_LABELS = {
  ball: 'Balón',
  gloves: 'Guantes',
  trophy: 'Trofeo',
  boot: 'Bota',
};

export default function AvatarIcon({ type = 'ball', size = 48, selected = false, onClick }) {
  // Validate type fallback
  const safeType = AVATAR_LIST.includes(type) ? type : 'ball';

  return (
    <div
      onClick={onClick}
      className={`avatar-icon ${selected ? 'avatar-icon--selected' : ''}`}
      style={{
        width: size,
        height: size,
        cursor: onClick ? 'pointer' : 'default',
        borderRadius: '50%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: selected
          ? 'radial-gradient(circle, rgba(255,221,0,0.4) 0%, rgba(255,221,0,0.1) 100%)'
          : 'rgba(0,0,0,0.5)',
        border: selected ? '2px solid #FFDD00' : '2px solid rgba(255,255,255,0.2)',
        transition: 'all 0.2s ease',
        flexShrink: 0,
        overflow: 'hidden'
      }}
      title={AVATAR_LABELS[safeType]}
    >
      <img 
        src={`/assets/avatars/${safeType}.png`} 
        alt={AVATAR_LABELS[safeType]} 
        style={{ width: '100%', height: '100%', objectFit: 'cover' }} 
      />
    </div>
  );
}
