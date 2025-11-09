/// Utility class for form validation
class Validators {
  // Prevent instantiation
  Validators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }

    return null;
  }

  /// Validate password (not empty)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caract\u00e8res';
    }

    return null;
  }

  /// Validate PIN code (4 digits)
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le code PIN est requis';
    }

    if (value.length != 4) {
      return 'Le code PIN doit contenir 4 chiffres';
    }

    final pinRegex = RegExp(r'^\d{4}$');
    if (!pinRegex.hasMatch(value)) {
      return 'Le code PIN doit contenir uniquement des chiffres';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return null;
  }

  /// Validate text length
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }

    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'Ce champ'} doit contenir au moins $minLength caract\u00e8res';
    }

    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Ce champ'} ne peut pas d\u00e9passer $maxLength caract\u00e8res';
    }

    return null;
  }

  /// Validate justification for access request
  static String? validateJustification(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La justification est requise';
    }

    if (value.length < 20) {
      return 'La justification doit contenir au moins 20 caract\u00e8res';
    }

    if (value.length > 500) {
      return 'La justification ne peut pas d\u00e9passer 500 caract\u00e8res';
    }

    return null;
  }

  /// Validate phone number (French format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Remove spaces and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

    final phoneRegex = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    if (!phoneRegex.hasMatch(cleanedValue)) {
      return 'Format de num\u00e9ro de t\u00e9l\u00e9phone invalide';
    }

    return null;
  }

  /// Validate date (not null)
  static String? validateDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'La date'} est requise';
    }
    return null;
  }

  /// Validate date range (start must be before end)
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Les deux dates sont requises';
    }

    if (startDate.isAfter(endDate)) {
      return 'La date de d\u00e9but doit \u00eatre avant la date de fin';
    }

    return null;
  }

  /// Validate date is in the future
  static String? validateFutureDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'La date'} est requise';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(value.year, value.month, value.day);

    if (inputDate.isBefore(today)) {
      return '${fieldName ?? 'La date'} doit \u00eatre dans le futur';
    }

    return null;
  }

  /// Validate date is not in the past
  static String? validateNotPastDate(DateTime? value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'La date'} est requise';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(value.year, value.month, value.day);

    if (inputDate.isBefore(today)) {
      return '${fieldName ?? 'La date'} ne peut pas \u00eatre dans le pass\u00e9';
    }

    return null;
  }

  /// Validate dropdown selection
  static String? validateDropdown(dynamic value, {String? fieldName}) {
    if (value == null) {
      return '${fieldName ?? 'Une s\u00e9lection'} est requise';
    }
    return null;
  }

  /// Validate number
  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }

    final number = num.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Ce champ'} doit \u00eatre un nombre valide';
    }

    return null;
  }

  /// Validate number range
  static String? validateNumberRange(
    String? value, {
    num? min,
    num? max,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }

    final number = num.tryParse(value);
    if (number == null) {
      return '${fieldName ?? 'Ce champ'} doit \u00eatre un nombre valide';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Ce champ'} doit \u00eatre sup\u00e9rieur ou \u00e9gal \u00e0 $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Ce champ'} doit \u00eatre inf\u00e9rieur ou \u00e9gal \u00e0 $max';
    }

    return null;
  }

  /// Check if email is valid (returns bool)
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is valid (returns bool)
  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if PIN is valid (returns bool)
  static bool isValidPin(String pin) {
    return validatePin(pin) == null;
  }
}
