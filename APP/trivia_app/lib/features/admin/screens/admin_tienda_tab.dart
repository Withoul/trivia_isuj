import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/tienda_item_model.dart';
import '../../../data/services/api_service.dart';

class AdminTiendaTab extends StatefulWidget {
  const AdminTiendaTab({super.key});

  @override
  State<AdminTiendaTab> createState() => _AdminTiendaTabState();
}

class _AdminTiendaTabState extends State<AdminTiendaTab> {
  final ApiService _api = ApiService();
  List<TiendaItemModel> _items = [];
  bool _isLoading = true;

  // Predefined icons list
  static const List<Map<String, dynamic>> _availableIcons = [
    {'name': 'Regalo', 'value': 'gift', 'icon': Icons.card_giftcard},
    {'name': 'Estrella', 'value': 'star', 'icon': Icons.star},
    {'name': 'Juego', 'value': 'gamepad', 'icon': Icons.sports_esports},
    {'name': 'Libro', 'value': 'book', 'icon': Icons.menu_book},
    {'name': 'Trofeo', 'value': 'trophy', 'icon': Icons.emoji_events},
    {'name': 'Mochila', 'value': 'bag', 'icon': Icons.shopping_bag},
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _api.getAdminStoreItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  IconData _getIconData(String iconName) {
    final found = _availableIcons.firstWhere(
      (element) => element['value'] == iconName,
      orElse: () => _availableIcons[0],
    );
    return found['icon'] as IconData;
  }

  void _showFormDialog([TiendaItemModel? itemToEdit]) {
    final isEditing = itemToEdit != null;
    final nameCtrl = TextEditingController(text: itemToEdit?.nombre ?? '');
    final valorCtrl = TextEditingController(text: itemToEdit?.valor.toString() ?? '100');
    final stockCtrl = TextEditingController(text: itemToEdit?.stock.toString() ?? '10');
    String selectedIcon = itemToEdit?.icono ?? 'gift';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(isEditing ? 'Editar Artículo ✏️' : 'Crear Artículo 🎁'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre Field
                      const Text('Nombre del Objeto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(hintText: 'Ej. Termo Metálico'),
                        validator: (v) => (v == null || v.isEmpty) ? 'El nombre es obligatorio' : null,
                      ),
                      const SizedBox(height: 16),

                      // Valor Field
                      const Text('Valor (Puntos/Monedas)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: valorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Costo en puntos'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'El valor es obligatorio';
                          if (int.tryParse(v) == null) return 'Debe ser un número válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Stock Field
                      const Text('Stock Disponible', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Cantidad en almacén'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'El stock es obligatorio';
                          if (int.tryParse(v) == null) return 'Debe ser un número válido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Icon Selector
                      const Text('Icono del Objeto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableIcons.map((icoOption) {
                          final isSelected = selectedIcon == icoOption['value'];
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedIcon = icoOption['value'] as String;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryContainer.withOpacity(0.12) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryContainer : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                icoOption['icon'] as IconData,
                                color: isSelected ? AppColors.primaryContainer : Colors.grey,
                                size: 24,
                              ),
                            ),
                          );
                        }).toList(),
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

                      final name = nameCtrl.text.trim();
                      final val = int.parse(valorCtrl.text);
                      final stock = int.parse(stockCtrl.text);

                      if (isEditing) {
                        await _api.updateStoreItem(itemToEdit.id, name, val, stock, selectedIcon);
                      } else {
                        await _api.createStoreItem(name, val, stock, selectedIcon);
                      }

                      _loadItems();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteItem(TiendaItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Artículo 🚨'),
          content: Text('¿Estás seguro de que deseas eliminar permanentemente el artículo "${item.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _api.deleteStoreItem(item.id);
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header panel
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
                              'Gestión de Tienda 🛒',
                              style: AppTextStyles.titleMd(color: Colors.white).copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Crea, edita y elimina los artículos y recompensas disponibles para los estudiantes.',
                              style: AppTextStyles.bodySm(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_items.length} Recompensas',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.inventory_2_outlined, color: AppColors.primaryContainer, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Lista de Artículos',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showFormDialog(),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar Objeto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_items.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text('No hay artículos creados', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                TextButton(onPressed: () => _showFormDialog(), child: const Text('Crear el primero')),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return _buildItemRow(item);
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

  Widget _buildItemRow(TiendaItemModel item) {
    final hasStock = item.stock > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconData(item.icono), color: AppColors.primaryContainer, size: 26),
            ),
            const SizedBox(width: 14),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Costo: ${item.valor} pts',
                        style: const TextStyle(color: AppColors.secondaryContainer, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: hasStock ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hasStock ? 'Stock: ${item.stock}' : 'Agotado',
                          style: TextStyle(
                            color: hasStock ? Colors.green.shade700 : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: () => _showFormDialog(item),
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
              onPressed: () => _deleteItem(item),
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}
