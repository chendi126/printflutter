
class HistoryRecord {
  String id;
  DateTime timestamp;
  String type; // "document" or "photo"
  String description; // "50页 双面"
  double totalCost;

  HistoryRecord({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.totalCost,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      description: json['description'],
      totalCost: (json['totalCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'description': description,
      'totalCost': totalCost,
    };
  }
}
