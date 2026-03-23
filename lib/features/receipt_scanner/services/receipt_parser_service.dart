import 'package:intl/intl.dart';
import '../models/receipt_data.dart';

class ReceiptParserService {
  /// Parse raw OCR text and extract receipt data
  ReceiptData parseReceipt(String rawText) {
    if (rawText.isEmpty) {
      return ReceiptData(rawText: rawText, confidence: 0.0);
    }

    // Extract each field
    final merchantName = _extractMerchantName(rawText);
    final totalAmount = _extractTotalAmount(rawText);
    final date = _extractDate(rawText);

    // Calculate confidence based on what we found
    int foundFields = 0;
    if (merchantName != null) foundFields++;
    if (totalAmount != null) foundFields++;
    if (date != null) foundFields++;
    
    final confidence = foundFields / 3.0; // 0.0 to 1.0

    return ReceiptData(
      merchantName: merchantName,
      totalAmount: totalAmount,
      date: date,
      rawText: rawText,
      confidence: confidence,
    );
  }

  /// Extract merchant/store name from receipt text
  /// Strategy: Usually at the top, could be a company name or brand
  String? _extractMerchantName(String text) {
    final lines = text.split('\n');
    
    // Filter out empty lines
    final nonEmptyLines = lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    if (nonEmptyLines.isEmpty) return null;

    // First line is often the merchant name
    String firstLine = nonEmptyLines.first;
    
    // Remove common receipts headers
    if (firstLine.toLowerCase().contains('receipt') ||
        firstLine.toLowerCase().contains('invoice')) {
      if (nonEmptyLines.length > 1) {
        firstLine = nonEmptyLines[1];
      }
    }

    // Skip if it looks like a date or number
    if (RegExp(r'^\d+').hasMatch(firstLine)) {
      if (nonEmptyLines.length > 1) return nonEmptyLines[1];
      return null;
    }

    return firstLine.length > 2 ? firstLine : null;
  }

  /// Extract total amount from receipt text
  /// Looks for patterns like "Total: $100.00" or "Total: 100.00"
  double? _extractTotalAmount(String text) {
    final lines = text.split('\n');
    
    // Common patterns for total: "Total", "TOTAL", "Grand Total", "Amount Due"
    final totalPatterns = [
      RegExp(r'(?:total|grand total|amount due|balance due|total amount)[\s:]*\$?[\s]*(\d+\.?\d*)',
          caseSensitive: false),
      RegExp(r'\$(\d+\.?\d*)'), // Dollar sign followed by amount
      RegExp(r'(\d+\.\d{2})\s*(?:only|total)?$'), // Amount at end of line
    ];

    double? maxAmount;

    for (var line in lines) {
      for (var pattern in totalPatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            final amount = double.parse(match.group(1)!);
            // Assume total is a reasonable amount (between 0.01 and 10000)
            if (amount > 0.01 && amount < 10000) {
              // Take the largest amount as likely total
              if (maxAmount == null || amount > maxAmount) {
                maxAmount = amount;
              }
            }
          } catch (e) {
            // Skip invalid amounts
            continue;
          }
        }
      }
    }

    return maxAmount;
  }

  /// Extract date from receipt text
  /// Looks for common date formats: dd/mm/yyyy, mm/dd/yyyy, yyyy-mm-dd, etc.
  DateTime? _extractDate(String text) {
    final datePatterns = [
      // dd/mm/yyyy or mm/dd/yyyy
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'),
      // yyyy-mm-dd
      RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})'),
      // "Date: 23 Mar 2024"
      RegExp(r'(?:date|on)\s*:?\s*(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})', caseSensitive: false),
      // "23 March 2024" or "23 Mar 2024"
      RegExp(r'(\d{1,2})\s+([a-zA-Z]+)\s+(\d{4})'),
    ];

    for (var pattern in datePatterns) {
      final matches = pattern.allMatches(text);
      
      for (var match in matches) {
        try {
          DateTime? date = _parseDate(match, pattern);
          if (date != null) {
            // Only return valid dates (in the past or today)
            if (date.isBefore(DateTime.now().add(Duration(days: 1)))) {
              return date;
            }
          }
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  /// Helper method to parse date from regex match
  DateTime? _parseDate(RegExpMatch match, RegExp pattern) {
    try {
      if (match.groupCount >= 3) {
        String first = match.group(1)!;
        String second = match.group(2)!;
        String third = match.group(3)!;

        // Try to determine format
        if (RegExp(r'^\d{4}$').hasMatch(third)) {
          // Format: dd/mm/yyyy or mm/dd/yyyy
          int day = int.parse(first);
          int month = int.parse(second);
          int year = int.parse(third);

          // Guess format: if day > 12, it's dd/mm/yyyy, otherwise ambiguous
          if (day > 12) {
            return DateTime(year, month, day);
          } else {
            // Try mm/dd/yyyy first
            try {
              return DateTime(year, month, day);
            } catch (e) {
              return DateTime(year, day, month);
            }
          }
        } else if (RegExp(r'^\d{4}$').hasMatch(first)) {
          // Format: yyyy-mm-dd
          int year = int.parse(first);
          int month = int.parse(second);
          int day = int.parse(third);
          return DateTime(year, month, day);
        } else if (RegExp(r'^[a-zA-Z]+$').hasMatch(second)) {
          // Format: day Month year
          int day = int.parse(first);
          int year = int.parse(third);
          int month = _parseMonth(second);
          if (month > 0) {
            return DateTime(year, month, day);
          }
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// Parse month name to number (1-12)
  int _parseMonth(String monthStr) {
    final months = {
      'january': 1, 'j': 1, 'jan': 1,
      'february': 2, 'f': 2, 'feb': 2,
      'march': 3, 'm': 3, 'mar': 3,
      'april': 4, 'a': 4, 'apr': 4,
      'may': 5,
      'june': 6, 'jun': 6,
      'july': 7, 'jul': 7,
      'august': 8, 'aug': 8,
      'september': 9, 's': 9, 'sep': 9,
      'october': 10, 'o': 10, 'oct': 10,
      'november': 11, 'n': 11, 'nov': 11,
      'december': 12, 'd': 12, 'dec': 12,
    };

    return months[monthStr.toLowerCase()] ?? 0;
  }
}