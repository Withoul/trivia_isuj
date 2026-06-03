// LocalStorage Database Mock for Trivia Web App
const KEYS = {
  USERS: 'trivia_users',
  BANKS: 'trivia_banks',
  QUESTIONS: 'trivia_questions',
  STORE_ITEMS: 'trivia_store_items',
  CURRENT_USER: 'trivia_current_user',
  REDEEMED_ITEMS: 'trivia_redeemed_items'
};

// Seed Data
const defaultUsers = [
  {
    id: 1,
    correo: 'admin@admin.com',
    contrasena: 'admin',
    primerNombre: 'Admin',
    primerApellido: 'ISUJ',
    institucion: 'ISUJ',
    cedula: '1723456789',
    telefono: '0999999999',
    tipoPerfil: 'ADMINISTRADOR',
    creadoEn: new Date().toISOString(),
    puntajeTotal: 0,
    puntosDisponibles: 0,
    quizzesCompletados: 0,
    rachaMaxima: 0
  },
  {
    id: 2,
    correo: 'usuario@usuario.com',
    contrasena: 'usuario',
    primerNombre: 'Carlos',
    primerApellido: 'Mendoza',
    institucion: 'Sistemas ISUJ',
    cedula: '1723456780',
    telefono: '0988888888',
    tipoPerfil: 'JUGADOR',
    creadoEn: new Date().toISOString(),
    puntajeTotal: 1250,
    puntosDisponibles: 850,
    quizzesCompletados: 8,
    rachaMaxima: 5
  },
  {
    id: 3,
    correo: 'sofia@usuario.com',
    contrasena: 'sofia',
    primerNombre: 'Sofía',
    primerApellido: 'Pérez',
    institucion: 'Contabilidad ISUJ',
    cedula: '1723456781',
    telefono: '0977777777',
    tipoPerfil: 'JUGADOR',
    creadoEn: new Date().toISOString(),
    puntajeTotal: 1540,
    puntosDisponibles: 1540,
    quizzesCompletados: 12,
    rachaMaxima: 8
  },
  {
    id: 4,
    correo: 'miguel@usuario.com',
    contrasena: 'miguel',
    primerNombre: 'Miguel',
    primerApellido: 'Torres',
    institucion: 'Administración ISUJ',
    cedula: '1723456782',
    telefono: '0966666666',
    tipoPerfil: 'JUGADOR',
    creadoEn: new Date().toISOString(),
    puntajeTotal: 980,
    puntosDisponibles: 50,
    quizzesCompletados: 5,
    rachaMaxima: 3
  }
];

const defaultBanks = [
  {
    id: 1,
    titulo: 'Química Orgánica Básica 🧪',
    isActive: true,
    esPermanente: false,
    tiempoInicio: new Date().toISOString(),
    tiempoFin: new Date(Date.now() + 1000 * 60 * 60 * 2.5).toISOString(), // 2.5 hours from now
    tiempoPorPregunta: 12,
    puntosPorPregunta: 5,
    colorBanner: '#7C3AED'
  },
  {
    id: 2,
    titulo: 'Historia General del Ecuador 🇪🇨',
    isActive: true,
    esPermanente: true,
    tiempoInicio: null,
    tiempoFin: null,
    tiempoPorPregunta: 15,
    puntosPorPregunta: 10,
    colorBanner: '#0D9488'
  },
  {
    id: 3,
    titulo: 'Álgebra Lineal & Matrices 📐',
    isActive: true,
    esPermanente: true,
    tiempoInicio: null,
    tiempoFin: null,
    tiempoPorPregunta: 20,
    puntosPorPregunta: 15,
    colorBanner: '#461F70'
  },
  {
    id: 4,
    titulo: 'Fundamentos de Programación JS 💻',
    isActive: false,
    esPermanente: true,
    tiempoInicio: null,
    tiempoFin: null,
    tiempoPorPregunta: 12,
    puntosPorPregunta: 5,
    colorBanner: '#D97706'
  }
];

const defaultQuestions = {
  1: [ // Química Orgánica
    {
      id: 101,
      textoPregunta: '¿Cuál es el elemento principal en la composición de todos los compuestos orgánicos?',
      respuestas: [
        { textoRespuesta: 'Oxígeno', esCorrecta: false },
        { textoRespuesta: 'Carbono', esCorrecta: true },
        { textoRespuesta: 'Nitrógeno', esCorrecta: false },
        { textoRespuesta: 'Hidrógeno', esCorrecta: false }
      ]
    },
    {
      id: 102,
      textoPregunta: '¿Qué tipo de enlace predomina en las moléculas orgánicas?',
      respuestas: [
        { textoRespuesta: 'Enlace Iónico', esCorrecta: false },
        { textoRespuesta: 'Enlace Metálico', esCorrecta: false },
        { textoRespuesta: 'Enlace Covalente', esCorrecta: true },
        { textoRespuesta: 'Fuerzas de Van der Waals', esCorrecta: false }
      ]
    },
    {
      id: 103,
      textoPregunta: '¿Cuál es la fórmula química del Metano?',
      respuestas: [
        { textoRespuesta: 'CH4', esCorrecta: true },
        { textoRespuesta: 'C2H6', esCorrecta: false },
        { textoRespuesta: 'CO2', esCorrecta: false },
        { textoRespuesta: 'H2O', esCorrecta: false }
      ]
    }
  ],
  2: [ // Historia del Ecuador
    {
      id: 201,
      textoPregunta: '¿En qué año se fundó la República del Ecuador al separarse de la Gran Colombia?',
      respuestas: [
        { textoRespuesta: '1809', esCorrecta: false },
        { textoRespuesta: '1822', esCorrecta: false },
        { textoRespuesta: '1830', esCorrecta: true },
        { textoRespuesta: '1895', esCorrecta: false }
      ]
    },
    {
      id: 202,
      textoPregunta: '¿Quién fue el primer presidente de la República del Ecuador?',
      respuestas: [
        { textoRespuesta: 'Eloy Alfaro', esCorrecta: false },
        { textoRespuesta: 'Juan José Flores', esCorrecta: true },
        { textoRespuesta: 'Gabriel García Moreno', esCorrecta: false },
        { textoRespuesta: 'Vicente Rocafuerte', esCorrecta: false }
      ]
    },
    {
      id: 203,
      textoPregunta: '¿Qué batalla selló la independencia del Ecuador el 24 de mayo de 1822?',
      respuestas: [
        { textoRespuesta: 'Batalla de Tarqui', esCorrecta: false },
        { textoRespuesta: 'Batalla de Pichincha', esCorrecta: true },
        { textoRespuesta: 'Batalla de Huachi', esCorrecta: false },
        { textoRespuesta: 'Batalla de Junín', esCorrecta: false }
      ]
    }
  ],
  3: [ // Álgebra Lineal
    {
      id: 301,
      textoPregunta: '¿Qué es una matriz identidad?',
      respuestas: [
        { textoRespuesta: 'Una matriz llena de ceros.', esCorrecta: false },
        { textoRespuesta: 'Una matriz cuadrada con unos en la diagonal principal y ceros en el resto.', esCorrecta: true },
        { textoRespuesta: 'Una matriz que no tiene determinante.', esCorrecta: false },
        { textoRespuesta: 'Una matriz de una sola fila.', esCorrecta: false }
      ]
    },
    {
      id: 302,
      textoPregunta: '¿Qué ocurre con el determinante de una matriz si se intercambian dos filas?',
      respuestas: [
        { textoRespuesta: 'No cambia.', esCorrecta: false },
        { textoRespuesta: 'Se vuelve cero.', esCorrecta: false },
        { textoRespuesta: 'Cambia de signo.', esCorrecta: true },
        { textoRespuesta: 'Se duplica su valor.', esCorrecta: false }
      ]
    }
  ],
  4: [ // Fundamentos de JS
    {
      id: 401,
      textoPregunta: '¿Cuál palabra clave se usa para declarar una variable de ámbito de bloque en JS moderno?',
      respuestas: [
        { textoRespuesta: 'var', esCorrecta: false },
        { textoRespuesta: 'let', esCorrecta: true },
        { textoRespuesta: 'constante', esCorrecta: false },
        { textoRespuesta: 'make', esCorrecta: false }
      ]
    }
  ]
};

const defaultStoreItems = [
  {
    id: 1,
    nombre: 'Beca ISUJ del 10%',
    valor: 800,
    stock: 5,
    icono: 'gift'
  },
  {
    id: 2,
    nombre: 'Termo Metálico Académico',
    valor: 450,
    stock: 12,
    icono: 'bag'
  },
  {
    id: 3,
    nombre: 'Camiseta Oficial ISUJ',
    valor: 300,
    stock: 15,
    icono: 'star'
  },
  {
    id: 4,
    nombre: 'Pase Exento Lección',
    valor: 600,
    stock: 3,
    icono: 'trophy'
  },
  {
    id: 5,
    nombre: 'Libro de Ejercicios Guía',
    valor: 200,
    stock: 20,
    icono: 'book'
  },
  {
    id: 6,
    nombre: 'Mousepad Gamer ISUJ',
    valor: 150,
    stock: 0, // out of stock
    icono: 'gamepad'
  }
];

// Helper initialization
const initDb = () => {
  if (!localStorage.getItem(KEYS.USERS)) {
    localStorage.setItem(KEYS.USERS, JSON.stringify(defaultUsers));
  }
  if (!localStorage.getItem(KEYS.BANKS)) {
    localStorage.setItem(KEYS.BANKS, JSON.stringify(defaultBanks));
  }
  if (!localStorage.getItem(KEYS.QUESTIONS)) {
    localStorage.setItem(KEYS.QUESTIONS, JSON.stringify(defaultQuestions));
  }
  if (!localStorage.getItem(KEYS.STORE_ITEMS)) {
    localStorage.setItem(KEYS.STORE_ITEMS, JSON.stringify(defaultStoreItems));
  }
  if (!localStorage.getItem(KEYS.REDEEMED_ITEMS)) {
    localStorage.setItem(KEYS.REDEEMED_ITEMS, JSON.stringify([])); // array of { userId, itemId, redeemedAt }
  }
};

initDb();

// DB API Wrappers
export const db = {
  // --- AUTH SERVICES ---
  login: (correo, contrasena) => {
    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const user = users.find(u => u.correo.toLowerCase() === correo.toLowerCase() && u.contrasena === contrasena);
    if (user) {
      localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(user));
      return { success: true, user };
    }
    return { success: false, message: 'Correo o contraseña incorrectos.' };
  },

  signup: (userData) => {
    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    if (users.some(u => u.correo.toLowerCase() === userData.correo.toLowerCase())) {
      return { success: false, message: 'El correo electrónico ya está registrado.' };
    }

    const newUser = {
      id: Date.now(),
      contrasena: userData.contrasena,
      correo: userData.correo,
      primerNombre: userData.primerNombre,
      primerApellido: userData.primerApellido,
      institucion: userData.institucion,
      cedula: userData.cedula || '',
      telefono: userData.telefono || '',
      tipoPerfil: 'JUGADOR',
      creadoEn: new Date().toISOString(),
      puntajeTotal: 0,
      puntosDisponibles: 0,
      quizzesCompletados: 0,
      rachaMaxima: 0
    };

    users.push(newUser);
    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    return { success: true, user: newUser };
  },

  logout: () => {
    localStorage.removeItem(KEYS.CURRENT_USER);
  },

  getCurrentUser: () => {
    return JSON.parse(localStorage.getItem(KEYS.CURRENT_USER));
  },

  updateProfile: (userId, profileData) => {
    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const index = users.findIndex(u => u.id === userId);
    if (index === -1) return null;

    users[index] = {
      ...users[index],
      correo: profileData.correo,
      primerNombre: profileData.primerNombre,
      primerApellido: profileData.primerApellido,
      institucion: profileData.institucion,
      cedula: profileData.cedula,
      telefono: profileData.telefono
    };

    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    // Update logged in state if same user
    const curUser = db.getCurrentUser();
    if (curUser && curUser.id === userId) {
      localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(users[index]));
    }

    return users[index];
  },

  // --- PLAYER QUIZ & DASHBOARD SERVICES ---
  getActiveBanks: () => {
    const banks = JSON.parse(localStorage.getItem(KEYS.BANKS));
    return banks.filter(b => b.isActive);
  },

  getQuestions: (bankId) => {
    const allQuestions = JSON.parse(localStorage.getItem(KEYS.QUESTIONS));
    return allQuestions[bankId] || [];
  },

  submitScore: (bankId, score) => {
    const curUser = db.getCurrentUser();
    if (!curUser) return false;

    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const userIndex = users.findIndex(u => u.id === curUser.id);
    if (userIndex === -1) return false;

    // Increment stats
    users[userIndex].puntajeTotal += score;
    users[userIndex].puntosDisponibles += score;
    users[userIndex].quizzesCompletados += 1;

    // Mocking streak increment logic
    // Just general gameplay updates
    if (score > 10) {
      users[userIndex].rachaMaxima = Math.max(users[userIndex].rachaMaxima, 3);
    }

    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(users[userIndex]));
    return true;
  },

  // --- RANKINGS SERVICES ---
  getGlobalRankings: () => {
    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const players = users.filter(u => u.tipoPerfil === 'JUGADOR');

    // Return mapped ranking model values (sorting by points descending)
    return players.map(p => ({
      fullName: `${p.primerNombre} ${p.primerApellido}`,
      primerNombre: p.primerNombre,
      primerApellido: p.primerApellido,
      correo: p.correo,
      puntajeAcumulado: p.puntajeTotal,
      accuracy: p.quizzesCompletados > 0 ? Math.min(95, Math.max(60, Math.round(70 + Math.random() * 25))) : 0, // Mock accuracy
      puntosDisponibles: p.puntosDisponibles
    })).sort((a, b) => b.puntajeAcumulado - a.puntajeAcumulado);
  },

  // --- STORE / TIENDA SERVICES ---
  getStoreItems: (userId) => {
    const items = JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
    const redeemed = JSON.parse(localStorage.getItem(KEYS.REDEEMED_ITEMS));
    
    return items.map(item => {
      const isRedeemed = redeemed.some(r => r.userId === userId && r.itemId === item.id);
      return {
        ...item,
        canjeado: isRedeemed
      };
    });
  },

  redeemStoreItem: (itemId) => {
    const curUser = db.getCurrentUser();
    if (!curUser) return false;

    const items = JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
    const itemIndex = items.findIndex(i => i.id === itemId);
    if (itemIndex === -1 || items[itemIndex].stock <= 0) return false;

    const redeemed = JSON.parse(localStorage.getItem(KEYS.REDEEMED_ITEMS));
    const isAlreadyRedeemed = redeemed.some(r => r.userId === curUser.id && r.itemId === itemId);
    if (isAlreadyRedeemed) return false;

    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const userIndex = users.findIndex(u => u.id === curUser.id);
    if (userIndex === -1 || users[userIndex].puntosDisponibles < items[itemIndex].valor) return false;

    // Deduct stock & balance
    items[itemIndex].stock -= 1;
    users[userIndex].puntosDisponibles -= items[itemIndex].valor;
    
    redeemed.push({
      userId: curUser.id,
      itemId: itemId,
      redeemedAt: new Date().toISOString()
    });

    localStorage.setItem(KEYS.STORE_ITEMS, JSON.stringify(items));
    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    localStorage.setItem(KEYS.CURRENT_USER, JSON.stringify(users[userIndex]));
    localStorage.setItem(KEYS.REDEEMED_ITEMS, JSON.stringify(redeemed));

    return true;
  },

  // --- ADMIN PORTAL SERVICES ---
  getAdminBanks: () => {
    return JSON.parse(localStorage.getItem(KEYS.BANKS));
  },

  createBank: (bankData) => {
    const banks = JSON.parse(localStorage.getItem(KEYS.BANKS));
    const newBank = {
      id: Date.now(),
      titulo: bankData.titulo,
      isActive: bankData.isActive,
      esPermanente: bankData.esPermanente,
      tiempoInicio: bankData.esPermanente ? null : bankData.tiempoInicio,
      tiempoFin: bankData.esPermanente ? null : bankData.tiempoFin,
      tiempoPorPregunta: bankData.tiempoPorPregunta,
      puntosPorPregunta: bankData.puntosPorPregunta,
      colorBanner: bankData.colorBanner || '#461F70'
    };

    banks.push(newBank);
    localStorage.setItem(KEYS.BANKS, JSON.stringify(banks));

    // Initialize empty question bank list
    const allQuestions = JSON.parse(localStorage.getItem(KEYS.QUESTIONS));
    allQuestions[newBank.id] = [];
    localStorage.setItem(KEYS.QUESTIONS, JSON.stringify(allQuestions));

    return newBank;
  },

  updateBank: (bankId, bankData) => {
    const banks = JSON.parse(localStorage.getItem(KEYS.BANKS));
    const index = banks.findIndex(b => b.id === bankId);
    if (index === -1) return null;

    banks[index] = {
      ...banks[index],
      titulo: bankData.titulo,
      isActive: bankData.isActive,
      esPermanente: bankData.esPermanente,
      tiempoInicio: bankData.esPermanente ? null : bankData.tiempoInicio,
      tiempoFin: bankData.esPermanente ? null : bankData.tiempoFin,
      tiempoPorPregunta: bankData.tiempoPorPregunta,
      puntosPorPregunta: bankData.puntosPorPregunta,
      colorBanner: bankData.colorBanner
    };

    localStorage.setItem(KEYS.BANKS, JSON.stringify(banks));
    return banks[index];
  },

  // QUESTION CRUD
  createQuestion: (bankId, textoPregunta, respuestas) => {
    const allQuestions = JSON.parse(localStorage.getItem(KEYS.QUESTIONS));
    if (!allQuestions[bankId]) {
      allQuestions[bankId] = [];
    }

    const newQuestion = {
      id: Date.now(),
      textoPregunta,
      respuestas: respuestas.map(r => ({
        textoRespuesta: r.textoRespuesta,
        esCorrecta: r.esCorrecta
      }))
    };

    allQuestions[bankId].push(newQuestion);
    localStorage.setItem(KEYS.QUESTIONS, JSON.stringify(allQuestions));
    return newQuestion;
  },

  updateQuestion: (bankId, questionId, textoPregunta, respuestas) => {
    const allQuestions = JSON.parse(localStorage.getItem(KEYS.QUESTIONS));
    if (!allQuestions[bankId]) return null;

    const index = allQuestions[bankId].findIndex(q => q.id === questionId);
    if (index === -1) return null;

    allQuestions[bankId][index] = {
      id: questionId,
      textoPregunta,
      respuestas: respuestas.map(r => ({
        textoRespuesta: r.textoRespuesta,
        esCorrecta: r.esCorrecta
      }))
    };

    localStorage.setItem(KEYS.QUESTIONS, JSON.stringify(allQuestions));
    return allQuestions[bankId][index];
  },

  deleteQuestion: (bankId, questionId) => {
    const allQuestions = JSON.parse(localStorage.getItem(KEYS.QUESTIONS));
    if (!allQuestions[bankId]) return false;

    const filtered = allQuestions[bankId].filter(q => q.id !== questionId);
    allQuestions[bankId] = filtered;
    
    localStorage.setItem(KEYS.QUESTIONS, JSON.stringify(allQuestions));
    return true;
  },

  // USERS MANAGEMENT CRUD
  getAdminUsers: () => {
    return JSON.parse(localStorage.getItem(KEYS.USERS));
  },

  updateAdminUser: (userId, updatedUser) => {
    const users = JSON.parse(localStorage.getItem(KEYS.USERS));
    const index = users.findIndex(u => u.id === userId);
    if (index === -1) return null;

    users[index] = {
      ...users[index],
      correo: updatedUser.correo,
      primerNombre: updatedUser.primerNombre,
      primerApellido: updatedUser.primerApellido,
      institucion: updatedUser.institucion,
      cedula: updatedUser.cedula,
      telefono: updatedUser.telefono,
      tipoPerfil: updatedUser.tipoPerfil
    };

    localStorage.setItem(KEYS.USERS, JSON.stringify(users));
    return users[index];
  },

  // STORE ITEMS CRUD
  getAdminStoreItems: () => {
    return JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
  },

  createStoreItem: (nombre, valor, stock, icono) => {
    const items = JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
    const newItem = {
      id: Date.now(),
      nombre,
      valor,
      stock,
      icono
    };

    items.push(newItem);
    localStorage.setItem(KEYS.STORE_ITEMS, JSON.stringify(items));
    return newItem;
  },

  updateStoreItem: (itemId, nombre, valor, stock, icono) => {
    const items = JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
    const index = items.findIndex(i => i.id === itemId);
    if (index === -1) return null;

    items[index] = {
      id: itemId,
      nombre,
      valor,
      stock,
      icono
    };

    localStorage.setItem(KEYS.STORE_ITEMS, JSON.stringify(items));
    return items[index];
  },

  deleteStoreItem: (itemId) => {
    const items = JSON.parse(localStorage.getItem(KEYS.STORE_ITEMS));
    const filtered = items.filter(i => i.id !== itemId);
    localStorage.setItem(KEYS.STORE_ITEMS, JSON.stringify(filtered));
    return true;
  }
};
