enum OrderStatus { pending, confirmed, inProgress, delivered, cancelled }

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

  // Convertir un objet Order en Map
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

  // Créer un objet Order à partir d'un Map
  factory PecheOrder.fromMap(Map<String, dynamic> map) {
    return PecheOrder(
      id: map['id'],
      clientId: map['clientId'],
      fishId: map['fishId'],
      fishermanId: map['fishermanId'],
      quantity: map['quantity'],
      totalPrice: map['totalPrice'],
      status: OrderStatus.values[map['status']],
      orderDate: DateTime.parse(map['orderDate']),
      deliveryDate: map['deliveryDate'] != null ? DateTime.parse(map['deliveryDate']) : null,
      deliveryAddress: map['deliveryAddress'],
      notes: map['notes'],
    );
  }
}

