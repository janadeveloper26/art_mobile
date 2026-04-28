import 'package:flutter/material.dart';

class ValidationUtils {
  static bool isValidEmail(String email) {
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // Minimum 8 characters, at least one uppercase, one lowercase, one digit
    const pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  static bool isValidPhone(String phone) {
    const pattern = r'^\+?[\d\s\-\(\)]{7,}$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    const pattern = r'^https?:\/\/[^\s/$.?#].[^\s]*$';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(url);
  }
}

class TextUtils {
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String toCamelCase(String text) {
    final List<String> words = text.split(RegExp(r'[\s\-_]+'));
    return words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;
      return index == 0 ? word : capitalize(word);
    }).join();
  }
}

class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }
}

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
