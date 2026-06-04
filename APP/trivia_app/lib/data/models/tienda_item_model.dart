class TiendaItemModel {
  final int id;
  final String nombre;
  final int valor;
  final int stock;
  final String icono;
  final bool canjeado;

  TiendaItemModel({
    required this.id,
    required this.nombre,
    required this.valor,
    required this.stock,
    required this.icono,
    required this.canjeado,
  });

  factory TiendaItemModel.fromJson(Map<String, dynamic> json) {
    return TiendaItemModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      valor: json['valor'] as int,
      stock: json['stock'] as int,
      icono: json['icono'] as String? ?? 'card_giftcard',
      canjeado: json['canjeado'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'valor': valor,
      'stock': stock,
      'icono': icono,
      'canjeado': canjeado,
    };
  }

  TiendaItemModel copyWith({
    int? id,
    String? nombre,
    int? valor,
    int? stock,
    String? icono,
    bool? canjeado,
  }) {
    return TiendaItemModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      valor: valor ?? this.valor,
      stock: stock ?? this.stock,
      icono: icono ?? this.icono,
      canjeado: canjeado ?? this.canjeado,
    );
  }
}
