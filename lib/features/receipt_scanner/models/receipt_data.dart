class ReceiptData {
  final String? merchantName;
  final double? totalAmount;
  final DateTime? date;
  final String? rawText;
  final double confidence; // How confident we are in the extraction

  ReceiptData({
    this.merchantName,
    this.totalAmount,
    this.date,
    this.rawText,
    this.confidence = 0.0,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'merchantName': merchantName,
    'totalAmount': totalAmount,
    'date': date?.toIso8601String(),
    'rawText': rawText,
    'confidence': confidence,
  };

  // Create from JSON
  factory ReceiptData.fromJson(Map<String, dynamic> json) => ReceiptData(
    merchantName: json['merchantName'] as String?,
    totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    rawText: json['rawText'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  String toString() =>
      'ReceiptData(merchant: $merchantName, total: $totalAmount, date: $date)';
}