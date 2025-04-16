import 'package:uuid/uuid.dart';

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  creditCard,
  bankTransfer,
  cash,
  paypal,
  other,
}

class Payment {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime date;
  final String? transactionId;
  final String? notes;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
    this.transactionId,
    this.notes,
  });

  // Créer un nouveau paiement avec un ID généré
  factory Payment.create({
    required String orderId,
    required String userId,
    required double amount,
    required PaymentMethod method,
    String? transactionId,
    String? notes,
  }) {
    return Payment(
      id: const Uuid().v4(),
      orderId: orderId,
      userId: userId,
      amount: amount,
      status: PaymentStatus.pending,
      method: method,
      date: DateTime.now(),
      transactionId: transactionId,
      notes: notes,
    );
  }

  // Convertir un Payment en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'amount': amount,
      'status': status.index,
      'method': method.index,
      'date': date.toIso8601String(),
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  // Créer un Payment à partir d'un Map de SQLite
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      orderId: map['orderId'],
      userId: map['userId'],
      amount: map['amount'] is int ? (map['amount'] as int).toDouble() : map['amount'],
      status: PaymentStatus.values[map['status']],
      method: PaymentMethod.values[map['method']],
      date: DateTime.parse(map['date']),
      transactionId: map['transactionId'],
      notes: map['notes'],
    );
  }

  // Créer une copie d'un Payment avec des modifications
  Payment copyWith({
    String? id,
    String? orderId,
    String? userId,
    double? amount,
    PaymentStatus? status,
    PaymentMethod? method,
    DateTime? date,
    String? transactionId,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      method: method ?? this.method,
      date: date ?? this.date,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
    );
  }
}

class CreditCard {
  final String number;
  final String holderName;
  final String expiryDate;
  final String cvv;

  CreditCard({
    required this.number,
    required this.holderName,
    required this.expiryDate,
    required this.cvv,
  });

  // Masquer le numéro de carte
  String get maskedNumber {
    if (number.length < 4) return number;
    return '**** **** **** ${number.substring(number.length - 4)}';
  }
}
