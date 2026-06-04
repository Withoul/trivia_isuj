import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final ApiService _api = ApiService();
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _api.getAdminUsers();
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _isLoading = false;
    });
    _onSearchChanged();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final fullName = user.fullName.toLowerCase();
          final email = user.correo.toLowerCase();
          final inst = user.institucion.toLowerCase();
          final cedula = (user.cedula ?? '').toLowerCase();
          final phone = (user.telefono ?? '').toLowerCase();
          return fullName.contains(query) ||
              email.contains(query) ||
              inst.contains(query) ||
              cedula.contains(query) ||
              phone.contains(query);
        }).toList();
      }
    });
  }

  void _showEditDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController(text: user.correo);
    final nameCtrl = TextEditingController(text: user.primerNombre);
    final lastNameCtrl = TextEditingController(text: user.primerApellido);
    final instCtrl = TextEditingController(text: user.institucion);
    final cedulaCtrl = TextEditingController(text: user.cedula ?? '');
    final telCtrl = TextEditingController(text: user.telefono ?? '');
    final passCtrl = TextEditingController(); // optional password update
    String selectedRole = user.tipoPerfil; // "JUGADOR" or "ADMINISTRADOR"

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Editar Usuario 👤'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Correo
                      const Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(hintText: 'correo@ujapon.edu.ec'),
                        validator: (v) => (v == null || v.isEmpty) ? 'El correo es requerido' : null,
                      ),
                      const SizedBox(height: 12),

                      // Nombres
                      const Text('Nombres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(hintText: 'Primer nombre'),
                        validator: (v) => (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
                      ),
                      const SizedBox(height: 12),

                      // Apellidos
                      const Text('Apellidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: lastNameCtrl,
                        decoration: const InputDecoration(hintText: 'Primer apellido'),
                        validator: (v) => (v == null || v.isEmpty) ? 'El apellido es requerido' : null,
                      ),
                      const SizedBox(height: 12),

                      // Institución
                      const Text('Institución / Carrera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: instCtrl,
                        decoration: const InputDecoration(hintText: 'Ej. Sistemas / Juan Montalvo'),
                        validator: (v) => (v == null || v.isEmpty) ? 'La institución es requerida' : null,
                      ),
                      const SizedBox(height: 12),

                      // Cédula
                      const Text('Cédula de Identidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: cedulaCtrl,
                        decoration: const InputDecoration(hintText: 'Cédula de identidad'),
                      ),
                      const SizedBox(height: 12),

                      // Teléfono
                      const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: telCtrl,
                        decoration: const InputDecoration(hintText: 'Teléfono de contacto'),
                      ),
                      const SizedBox(height: 12),

                      // Rol
                      const Text('Perfil / Rol', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'JUGADOR',
                            groupValue: selectedRole,
                            onChanged: (v) => setDialogState(() => selectedRole = v!),
                          ),
                          const Text('Jugador', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 14),
                          Radio<String>(
                            value: 'ADMINISTRADOR',
                            groupValue: selectedRole,
                            onChanged: (v) => setDialogState(() => selectedRole = v!),
                          ),
                          const Text('Admin', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Contraseña (opcional)
                      const Text('Nueva Contraseña (Opcional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Dejar en blanco para no cambiar'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      setState(() => _isLoading = true);

                      final updatedUser = UserModel(
                        id: user.id,
                        correo: emailCtrl.text.trim(),
                        primerNombre: nameCtrl.text.trim(),
                        primerApellido: lastNameCtrl.text.trim(),
                        institucion: instCtrl.text.trim(),
                        cedula: cedulaCtrl.text.trim(),
                        telefono: telCtrl.text.trim(),
                        tipoPerfil: selectedRole,
                        // Conserve stats
                        creadoEn: user.creadoEn,
                        puntajeTotal: user.puntajeTotal,
                        puntosDisponibles: user.puntosDisponibles,
                        quizzesCompletados: user.quizzesCompletados,
                        rachaMaxima: user.rachaMaxima,
                      );

                      await _api.updateAdminUser(user.id, updatedUser);
                      await _loadUsers();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : RefreshIndicator(
              onRefresh: _loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryContainer, Color(0xFF2E1052)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestión de Usuarios 👥',
                              style: AppTextStyles.titleMd(color: Colors.white).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Busca y edita toda la información de los usuarios registrados, incluyendo roles e información de contacto.',
                              style: AppTextStyles.bodySm(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_allUsers.length} Usuarios Registrados',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search bar
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, correo, cédula...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.primaryContainer),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (_filteredUsers.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              'No se encontraron usuarios coincidentes.',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return _buildUserCard(user);
                          },
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final isAdmin = user.tipoPerfil == 'ADMINISTRADOR';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User Avatar/Initial Circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isAdmin ? AppColors.primaryContainer.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user.primerNombre.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isAdmin ? AppColors.primaryContainer : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                      ),
                      const SizedBox(width: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.primaryContainer.withOpacity(0.12) : AppColors.secondaryContainer.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAdmin ? 'ADMIN' : 'JUGADOR',
                          style: TextStyle(
                            color: isAdmin ? AppColors.primaryContainer : AppColors.onSecondaryContainer,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.correo,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Inst: ${user.institucion}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Edit Action
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primaryContainer, size: 22),
              onPressed: () => _showEditDialog(user),
              tooltip: 'Editar Usuario',
            ),
          ],
        ),
      ),
    );
  }
}
