import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/moneda_icon.dart';
import '../../../data/models/tienda_item_model.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/services/api_service.dart';

class TiendaTab extends ConsumerStatefulWidget {
  const TiendaTab({super.key});

  @override
  ConsumerState<TiendaTab> createState() => _TiendaTabState();
}

class _TiendaTabState extends ConsumerState<TiendaTab> {
  final ApiService _api = ApiService();
  List<TiendaItemModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _api.getStoreItems();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'gift':
        return Icons.card_giftcard;
      case 'star':
        return Icons.star;
      case 'gamepad':
        return Icons.sports_esports;
      case 'book':
        return Icons.menu_book;
      case 'trophy':
        return Icons.emoji_events;
      case 'bag':
        return Icons.shopping_bag;
      default:
        return Icons.card_giftcard;
    }
  }

  Future<void> _confirmRedemption(TiendaItemModel item, int userPoints) async {
    if (userPoints < item.valor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Puntos insuficientes para canjear este artículo.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmar Canje 🪙'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro de que deseas canjear este artículo?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(_getIcon(item.icono), color: AppColors.primaryContainer, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('${item.valor} ', style: const TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                              const MonedaIcon(size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nota: Este artículo se puede canjear una sola vez.',
                style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Canjear'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _api.redeemStoreItem(item.id);
      
      if (success) {
        // Refresh local items
        await _loadItems();
        // Invalidate profile provider to update points top bar immediately
        ref.invalidate(profileProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Canjeaste "${item.nombre}" con éxito! 🎉'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ocurrió un error al procesar el canje.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

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
                      // Store Welcome Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondaryContainer, Color(0xFFC084FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryContainer.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tienda de Recompensas 🎁',
                              style: AppTextStyles.titleMd(color: Colors.white).copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Canjea tus puntos acumulados por artículos exclusivos. ¡Cada objeto se puede obtener una sola vez!',
                              style: AppTextStyles.bodySm(color: Colors.white.withOpacity(0.9)),
                            ),
                            const SizedBox(height: 14),
                            profileAsync.when(
                              data: (user) {
                                final pts = user?.puntosDisponibles ?? user?.puntajeTotal ?? 0;
                                final formattedPts = NumberFormat.decimalPattern().format(pts);
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.stars, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Saldo disponible: $formattedPts ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const MonedaIcon(size: 16),
                                    ],
                                  ),
                                );
                              },
                              loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              error: (_, __) => const Text('Error al cargar saldo'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid Header
                      const Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: AppColors.secondaryContainer, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Catálogo de Premios',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
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
                                Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No hay artículos disponibles',
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Vuelve pronto, se agregarán nuevas recompensas.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        profileAsync.when(
                          data: (user) {
                            final userPoints = user?.puntosDisponibles ?? user?.puntajeTotal ?? 0;
                            final availableItems = _items.where((i) => !i.canjeado).toList();
                            final redeemedItems = _items.where((i) => i.canjeado).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Available items grid
                                if (availableItems.isNotEmpty)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.76,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                    itemCount: availableItems.length,
                                    itemBuilder: (context, index) {
                                      return _buildStoreItemCard(availableItems[index], userPoints);
                                    },
                                  ),

                                // Divider + Redeemed section
                                if (redeemedItems.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Premios Canjeados',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.76,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                    itemCount: redeemedItems.length,
                                    itemBuilder: (context, index) {
                                      return _buildStoreItemCard(redeemedItems[index], userPoints);
                                    },
                                  ),
                                ],

                                if (availableItems.isEmpty && redeemedItems.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Center(
                                      child: Text(
                                        'No hay premios disponibles por ahora.',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Center(child: Text('Error al procesar el catálogo')),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStoreItemCard(TiendaItemModel item, int userPoints) {
    final isRedeemed = item.canjeado;
    final canAfford = userPoints >= item.valor;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRedeemed
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isRedeemed
                    ? Colors.green.withOpacity(0.04)
                    : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    _getIcon(item.icono),
                    size: 48,
                    color: isRedeemed
                        ? Colors.green
                        : AppColors.secondaryContainer,
                  ),
                  if (isRedeemed)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'CANJEADO',
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Details Container
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${item.valor} ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRedeemed ? Colors.green : AppColors.secondaryContainer,
                            fontSize: 14,
                          ),
                        ),
                        const MonedaIcon(size: 14),
                      ],
                    ),
                    if (!isRedeemed)
                      Text(
                        'Stock: ${item.stock}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: isRedeemed
                        ? null
                        : () => _confirmRedemption(item, userPoints),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRedeemed
                          ? Colors.green.shade100
                          : (!canAfford ? Colors.grey.shade300 : AppColors.secondaryContainer),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      isRedeemed ? 'Canjeado ✓' : 'Canjear',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
