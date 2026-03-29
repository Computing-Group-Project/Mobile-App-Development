import 'package:flutter/foundation.dart';
import 'receipt_parser_service.dart';

void testReceiptParser() {
  final parser = ReceiptParserService();
  
  // Sample receipt text
  const sampleReceipt = '''
  STARBUCKS COFFEE
  123 Main Street
  
  Coffee               5.50
  Pastry              3.25
  
  Subtotal            8.75
  Tax                 0.65
  Total              9.40
  
  Date: 23 Mar 2024
  ''';

  final result = parser.parseReceipt(sampleReceipt);
  debugPrint('Merchant: ${result.merchantName}');
  debugPrint('Amount: ${result.totalAmount}');
  debugPrint('Date: ${result.date}');
  debugPrint('Confidence: ${(result.confidence * 100).toStringAsFixed(0)}%');
}