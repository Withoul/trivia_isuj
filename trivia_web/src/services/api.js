/**
 * API Client Service - Trivia Mundialista
 * Connects the frontend to the PHP/MySQL backend.
 * 
 * Configuration:
 * - Set VITE_API_URL in .env for production (e.g., https://institutoj17.sg-host.com/api)
 * - In development, Vite proxy redirects /api to the PHP server
 * 
 * Public endpoints (no auth):
 *   createPlayer, getActiveBanks, getQuestions, submitScore, getRankings
 * 
 * Admin endpoints (requires admin_id):
 *   adminLogin, getAdminBanks, createBank, updateBank, deleteBank,
 *   getAdminQuestions, createQuestion, updateQuestion, deleteQuestion,
 *   getAdminUsers, deleteUser
 */

const API_BASE = import.meta.env.VITE_API_URL || '/api';

async function request(endpoint, options = {}) {
  const url = `${API_BASE}/${endpoint}`;
  const config = {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  };

  try {
    const res = await fetch(url, config);
    const data = await res.json();
    if (!res.ok) {
      throw new Error(data.message || data.error || `Error ${res.status}`);
    }
    return data;
  } catch (err) {
    console.error(`API Error [${endpoint}]:`, err);
    throw err;
  }
}

// ==================== PUBLIC (PLAYER) ====================

/** Register a new player with name + avatar */
export async function createPlayer(nombre, avatar = 'ball') {
  return request('player.php', {
    method: 'POST',
    body: JSON.stringify({ nombre, avatar }),
  });
}

/** Get all active question banks */
export async function getActiveBanks() {
  return request('banks.php');
}

/** Get questions for a bank (optionally randomized and limited) */
export async function getQuestions(bankId, randomCount = 10) {
  const params = randomCount > 0 ? `&random=${randomCount}` : '';
  return request(`questions.php?bank_id=${bankId}${params}`);
}

/** Submit a game score */
export async function submitScore(data) {
  return request('scores.php', {
    method: 'POST',
    body: JSON.stringify(data),
  });
}

/** Get global rankings/leaderboard */
export async function getRankings(limit = 50) {
  return request(`rankings.php?limit=${limit}`);
}

// ==================== ADMIN ====================

/** Admin login with email + password */
export async function adminLogin(correo, contrasena) {
  return request('admin_login.php', {
    method: 'POST',
    body: JSON.stringify({ correo, contrasena }),
  });
}

/** Get all banks (admin view includes inactive) */
export async function getAdminBanks(adminId) {
  return request(`admin_banks.php?admin_id=${adminId}`);
}

/** Create a new question bank */
export async function createBank(adminId, data) {
  return request('admin_banks.php', {
    method: 'POST',
    body: JSON.stringify({ admin_id: adminId, ...data }),
  });
}

/** Update a question bank */
export async function updateBank(adminId, bankId, data) {
  return request(`admin_banks.php?id=${bankId}`, {
    method: 'PUT',
    body: JSON.stringify({ admin_id: adminId, ...data }),
  });
}

/** Delete a question bank */
export async function deleteBank(adminId, bankId) {
  return request(`admin_banks.php?id=${bankId}&admin_id=${adminId}`, {
    method: 'DELETE',
  });
}

/** Get questions for a bank (admin view) */
export async function getAdminQuestions(adminId, bankId) {
  return request(`admin_questions.php?bank_id=${bankId}&admin_id=${adminId}`);
}

/** Create a question with answers */
export async function createQuestion(adminId, bankId, data) {
  return request(`admin_questions.php?bank_id=${bankId}`, {
    method: 'POST',
    body: JSON.stringify({ admin_id: adminId, ...data }),
  });
}

/** Update a question with answers */
export async function updateQuestion(adminId, questionId, data) {
  return request(`admin_questions.php?question_id=${questionId}`, {
    method: 'PUT',
    body: JSON.stringify({ admin_id: adminId, ...data }),
  });
}

/** Delete a question */
export async function deleteQuestion(adminId, questionId) {
  return request(`admin_questions.php?question_id=${questionId}&admin_id=${adminId}`, {
    method: 'DELETE',
  });
}

/** Get all players (admin view) */
export async function getAdminUsers(adminId) {
  return request(`admin_users.php?admin_id=${adminId}`);
}

/** Delete a player */
export async function deleteUser(adminId, userId) {
  return request(`admin_users.php?id=${userId}&admin_id=${adminId}`, {
    method: 'DELETE',
  });
}

export default {
  createPlayer, getActiveBanks, getQuestions, submitScore, getRankings,
  adminLogin, getAdminBanks, createBank, updateBank, deleteBank,
  getAdminQuestions, createQuestion, updateQuestion, deleteQuestion,
  getAdminUsers, deleteUser,
};
