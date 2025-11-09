import 'package:intl/intl.dart';

/// Utility class for formatting data
class Formatters {
  // Prevent instantiation
  Formatters._();

  // Date Formatters
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateFormatLong = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');
  static final DateFormat _dateFormatShort = DateFormat('dd MMM', 'fr_FR');
  static final DateFormat _dateFormatApi = DateFormat('yyyy-MM-dd');

  // Time Formatters
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _timeFormatWithSeconds = DateFormat('HH:mm:ss');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Format date to dd/MM/yyyy
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format date to long format (Lundi 15 Juillet 2025)
  static String formatDateLong(DateTime date) {
    return _dateFormatLong.format(date);
  }

  /// Format date to short format (15 Jul)
  static String formatDateShort(DateTime date) {
    return _dateFormatShort.format(date);
  }

  /// Format date for API (yyyy-MM-dd)
  static String formatDateForApi(DateTime date) {
    return _dateFormatApi.format(date);
  }

  /// Format time to HH:mm
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }

  /// Format time with seconds to HH:mm:ss
  static String formatTimeWithSeconds(DateTime time) {
    return _timeFormatWithSeconds.format(time);
  }

  /// Format date and time to dd/MM/yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Format duration to hours and minutes (9h 15m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Format hours from double to hours and minutes (9.25 -> 9h 15m)
  static String formatHours(double hours) {
    final hoursInt = hours.floor();
    final minutes = ((hours - hoursInt) * 60).round();

    if (hoursInt > 0 && minutes > 0) {
      return '${hoursInt}h ${minutes}m';
    } else if (hoursInt > 0) {
      return '${hoursInt}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Format hours with decimal (9.25h)
  static String formatHoursDecimal(double hours) {
    return '${hours.toStringAsFixed(2)}h';
  }

  /// Format posts list to display string (DEVELOPER, DEVOPS -> "Dev \u2022 DevOps")
  static String formatPostsList(List<String> posts) {
    if (posts.isEmpty) return 'Aucun poste';

    return posts
        .map((post) => _formatPostName(post))
        .join(' \u2022 ');
  }

  /// Format single post name (DEVELOPER -> Dev)
  static String formatPostName(String post) {
    return _formatPostName(post);
  }

  static String _formatPostName(String post) {
    switch (post.toUpperCase()) {
      case 'DEVELOPER':
        return 'Dev';
      case 'DEVOPS':
        return 'DevOps';
      case 'SECURITY_AGENT':
        return 'S\u00e9curit\u00e9';
      case 'HR_MANAGER':
        return 'RH';
      case 'ACCOUNTANT':
        return 'Comptable';
      case 'IT_SUPPORT':
        return 'IT Support';
      case 'MANAGER':
        return 'Manager';
      case 'RECEPTIONIST':
        return 'R\u00e9ception';
      case 'MAINTENANCE':
        return 'Maintenance';
      case 'EXECUTIVE':
        return 'Cadre';
      default:
        return post;
    }
  }

  /// Format security level (LOW -> Faible)
  static String formatSecurityLevel(String level) {
    switch (level.toUpperCase()) {
      case 'LOW':
        return 'Faible';
      case 'MEDIUM':
        return 'Moyenne';
      case 'HIGH':
        return 'Maximale';
      default:
        return level;
    }
  }

  /// Format access status (GRANTED -> Autoris\u00e9)
  static String formatAccessStatus(String status) {
    switch (status.toUpperCase()) {
      case 'GRANTED':
        return 'Autoris\u00e9';
      case 'PENDING_PIN':
        return 'En attente PIN';
      case 'DENIED':
        return 'Refus\u00e9';
      default:
        return status;
    }
  }

  /// Format request status (PENDING -> En attente)
  static String formatRequestStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuv\u00e9e';
      case 'REJECTED':
        return 'Rejet\u00e9e';
      default:
        return status;
    }
  }

  /// Format number with padding (1 -> 01)
  static String formatNumberWithPadding(int number, {int width = 2}) {
    return number.toString().padLeft(width, '0');
  }

  /// Format percentage (0.75 -> 75%)
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  /// Format relative time (Il y a 5 minutes)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Il y a quelques secondes';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format file size (bytes -> KB, MB, GB)
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon apr\u00e8s-midi';
    } else {
      return 'Bonsoir';
    }
  }
}
