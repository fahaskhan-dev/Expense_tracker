import 'package:hive/hive.dart';

/// The type of credit record from the user's perspective.
enum CreditType {
  /// Money other people owe the user ("Money to Receive")
  toReceive,

  /// Money the user owes other people ("Money to Pay")
  toPay,
}

class CreditModel {
  final String id;
  final String personName;
  final String? phoneNumber;
  final double originalAmount;
  final CreditType creditType;
  final DateTime date;
  final DateTime? dueDate;
  final String? description;
  final String? notes;

  const CreditModel({
    required this.id,
    required this.personName,
    this.phoneNumber,
    required this.originalAmount,
    required this.creditType,
    required this.date,
    this.dueDate,
    this.description,
    this.notes,
  });

  CreditModel copyWith({
    String? id,
    String? personName,
    String? phoneNumber,
    double? originalAmount,
    CreditType? creditType,
    DateTime? date,
    DateTime? dueDate,
    String? description,
    String? notes,
  }) {
    return CreditModel(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      originalAmount: originalAmount ?? this.originalAmount,
      creditType: creditType ?? this.creditType,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personName': personName,
      'phoneNumber': phoneNumber,
      'originalAmount': originalAmount,
      'creditType': creditType.index,
      'date': date.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'description': description,
      'notes': notes,
    };
  }

  factory CreditModel.fromMap(Map<dynamic, dynamic> map) {
    return CreditModel(
      id: map['id'] as String,
      personName: map['personName'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      originalAmount: (map['originalAmount'] as num).toDouble(),
      creditType: CreditType.values[map['creditType'] as int],
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int)
          : null,
      description: map['description'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

class CreditAdapter extends TypeAdapter<CreditModel> {
  @override
  final int typeId = 1;

  @override
  CreditModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreditModel(
      id: fields[0] as String,
      personName: fields[1] as String,
      phoneNumber: fields[2] as String?,
      originalAmount: (fields[3] as num).toDouble(),
      creditType: CreditType.values[fields[4] as int],
      date: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      dueDate: fields[6] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int)
          : null,
      description: fields[7] as String?,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CreditModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.originalAmount)
      ..writeByte(4)
      ..write(obj.creditType.index)
      ..writeByte(5)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.dueDate?.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.notes);
  }
}
