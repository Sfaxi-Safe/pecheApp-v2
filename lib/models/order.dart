import 'package:uuid/uuid.dart';

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  delivered,
  cancelled,
}

class PecheOrder {
  final String id;
  final String clientId;
  final String fishId;
  final String fishermanId;
  final double quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? deliveryAddress;
  final String? notes;

  PecheOrder({
    required this.id,
    required this.clientId,
    required this.fishId,
    required this.fishermanId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    this.deliveryAddress,
    this.notes,
  });

  // Créer une nouvelle commande avec un ID généré
  factory PecheOrder.create({
    required String clientId,
    required String fishId,
    required String fishermanId,
    required double quantity,
    required double totalPrice,
    String? deliveryAddress,
    String? notes,
  }) {
    return PecheOrder(
      id: const Uuid().v4(),
      clientId: clientId,
      fishId: fishId,
      fishermanId: fishermanId,
      quantity: quantity,
      totalPrice: totalPrice,
      status: OrderStatus.pending,
      orderDate: DateTime.now(),
      deliveryAddress: deliveryAddress,
      notes: notes,
    );
  }

  // Convertir un PecheOrder en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'fishId': fishId,
      'fishermanId': fishermanId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status.index,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
  }

  // Créer un PecheOrder à partir d'un Map de SQLite
  factory PecheOrder.fromMap(Map<String, dynamic> map) {
    return PecheOrder(
      id: map['id'],
      clientId: map['clientId'],
      fishId: map['fishId'],
      fishermanId: map['fishermanId'],
      quantity: map['quantity'] is int ? (map['quantity'] as int).toDouble() : map['quantity'],
      totalPrice: map['totalPrice'] is int ? (map['totalPrice'] as int).toDouble() : map['totalPrice'],
      status: OrderStatus.values[map['status']],
      orderDate: DateTime.parse(map['orderDate']),
      deliveryDate: map['deliveryDate'] != null ? DateTime.parse(map['deliveryDate']) : null,
      deliveryAddress: map['deliveryAddress'],
      notes: map['notes'],
    );
  }

  // Créer une copie d'un PecheOrder avec des modifications
  PecheOrder copyWith({
    String? id,
    String? clientId,
    String? fishId,
    String? fishermanId,
    double? quantity,
    double? totalPrice,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? deliveryAddress,
    String? notes,
  }) {
    return PecheOrder(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      fishId: fishId ?? this.fishId,
      fishermanId: fishermanId ?? this.fishermanId,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
    );
  }
}
