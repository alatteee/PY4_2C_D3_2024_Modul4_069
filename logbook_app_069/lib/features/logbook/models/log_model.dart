import 'package:mongo_dart/mongo_dart.dart';

class LogModel {
  // Penanda unik global dari MongoDB
  final ObjectId? id;
  final String title;
  final String description;
  // Simpan tanggal sebagai DateTime agar mudah diformat dan diproses
  final DateTime date;
  final String category;

  LogModel({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.category = 'Pribadi',
  });

  // [CONVERT] Untuk MongoDB: memasukkan data ke "kardus" (BSON/Map)
  Map<String, dynamic> toMap() {
    return {
      '_id': id ?? ObjectId(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  // [REVERT] Untuk MongoDB: membongkar Map (BSON) menjadi objek Flutter
  factory LogModel.fromMap(Map<String, dynamic> map) {
    final dynamic rawDate = map['date'];
    DateTime parsedDate;
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate != null) {
      parsedDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return LogModel(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: parsedDate,
      category: map['category'] ?? 'Pribadi',
    );
  }

  // =========================
  // Mapping untuk penyimpanan lokal (SharedPreferences / JSON)
  // =========================

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id?.toHexString(),
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory LogModel.fromLocalMap(Map<String, dynamic> map) {
    final String? idString = map['id'] as String?;

    return LogModel(
      id: (idString != null && idString.isNotEmpty)
          ? ObjectId.fromHexString(idString)
          : null,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      category: map['category'] ?? 'Pribadi',
    );
  }
}
