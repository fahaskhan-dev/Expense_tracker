import 'package:hive/hive.dart';

/// Represents a single partial payment toward a credit record.
class CreditPaymentModel {
  final String id;

  /// The credit record this payment belongs to.
  final String creditId;

  /// Amount paid/collected in this single payment.
  final double amount;

  final DateTime date;

  /// Optional note for this payment.
  final String? note;

  const CreditPaymentModel({
    required this.id,
    required this.creditId,
    required this.amount,
    required this.date,
    this.note,
  });

  CreditPaymentModel copyWith({
    String? id,
    String? creditId,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return CreditPaymentModel(
      id: id ?? this.id,
      creditId: creditId ?? this.creditId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creditId': creditId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory CreditPaymentModel.fromMap(Map<dynamic, dynamic> map) {
    return CreditPaymentModel(
      id: map['id'] as String,
      creditId: map['creditId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
    );
  }
}

class CreditPaymentAdapter extends TypeAdapter<CreditPaymentModel> {
  @override
  final int typeId = 2;

  @override
  CreditPaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditPaymentModel(
      id: fields[0] as String,
      creditId: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(fields[3] as int),
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditPaymentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.creditId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.note);
  }
}
