class Validators {
  // Email validation with additional checks
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    
    value = value.trim();
    if (value.length > 255) {
      return 'L\'email ne doit pas dépasser 255 caractères';
    }
    
    // Regular expression for strict email validation
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9](?:[a-zA-Z0-9._%+-]*[a-zA-Z0-9])?@[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.(?:[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?)?$'
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    
    // Check for common disposable email domains
    final disposableDomains = ['tempmail.com', 'temp-mail.org', 'guerrillamail.com'];
    if (disposableDomains.any((domain) => value.toLowerCase().endsWith(domain))) {
      return 'Les emails temporaires ne sont pas acceptés';
    }
    
    return null;
  }
  
  // Password validation with stronger requirements
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre majuscule';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Le mot de passe doit contenir au moins une lettre minuscule';
    }
    
    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Le mot de passe doit contenir au moins un chiffre';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    }
    
    return null;
  }
  
  // Simple password validation (for login)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }
  
  // Name validation with special character check
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    
    value = value.trim();
    if (value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    }
    
    if (value.length < 2) {
      return 'Ce champ doit contenir au moins 2 caractères';
    }
    
    if (value.length > 50) {
      return 'Ce champ ne doit pas dépasser 50 caractères';
    }
    
    // Check for valid name characters
    final nameRegExp = RegExp(r'^[a-zA-ZÀ-ÿ\-\'\s]+$');
    if (!nameRegExp.hasMatch(value)) {
      return 'Ce champ ne doit contenir que des lettres, des tirets et des apostrophes';
    }
    
    return null;
  }

  // Matricule validation for boats
  static String? validateMatricule(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le matricule est obligatoire';
    }
    
    value = value.trim().toUpperCase();
    
    // Format: XX-999999 (2 letters followed by 6 digits)
    final matriculeRegExp = RegExp(r'^[A-Z]{2}-\d{6}$');
    if (!matriculeRegExp.hasMatch(value)) {
      return 'Format invalide. Le format doit être XX-999999';
    }
    
    return null;
  }

  // CIN validation
  static String? validateCIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro CIN est obligatoire';
    }
    
    value = value.trim().toUpperCase();
    
    // Format: X999999 (1 letter followed by 6 digits)
    final cinRegExp = RegExp(r'^[A-Z]\d{6}$');
    if (!cinRegExp.hasMatch(value)) {
      return 'Format invalide. Le format doit être X999999';
    }
    
    return null;
  }

  // License validation for veterinarians
  static String? validateLicense(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de licence est obligatoire';
    }
    
    value = value.trim().toUpperCase();
    
    // Format: VET-999999 (VET- followed by 6 digits)
    final licenseRegExp = RegExp(r'^VET-\d{6}$');
    if (!licenseRegExp.hasMatch(value)) {
      return 'Format invalide. Le format doit être VET-999999';
    }
    
    return null;
  }
  
  // Phone validation with international format support
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est obligatoire';
    }
    
    value = value.trim().replaceAll(' ', '');
    
    // Regular expression for international phone numbers
    final phoneRegExp = RegExp(
      r'^\+?([0-9]{1,3})?[-. ]?\(?([0-9]{1,3})\)?[-. ]?([0-9]{1,4})[-. ]?([0-9]{1,4})$'
    );
    
    if (!phoneRegExp.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide (+XXX XX XX XX XX)';
    }
    
    if (value.length < 8 || value.length > 15) {
      return 'Le numéro de téléphone doit contenir entre 8 et 15 chiffres';
    }
    }
    
    return null;
  }
  
  // CIN validation
  static String? validateCIN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre CIN';
    }
    
    // Regular expression for CIN validation (alphanumeric)
    final cinRegExp = RegExp(r'^[a-zA-Z0-9]+$');
    
    if (!cinRegExp.hasMatch(value)) {
      return 'Veuillez entrer un CIN valide';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return 'Le champ ${fieldName ?? ""} est obligatoire';
    }
    
    return null;
  }
  
  // Numeric validation
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    // Regular expression for numeric validation
    final numericRegExp = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    
    if (!numericRegExp.hasMatch(value)) {
      return '${fieldName ?? "Ce champ"} doit être un nombre';
    }
    
    return null;
  }
  
  // Matricule validation for Pecheur
  static String? validateMatricule(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le matricule';
    }
    
    // Regular expression for matricule validation (alphanumeric with dash)
    final matriculeRegExp = RegExp(r'^[a-zA-Z0-9-]+$');
    
    if (!matriculeRegExp.hasMatch(value)) {
      return 'Veuillez entrer un matricule valide';
    }
    
    return null;
  }
  
  // Port validation
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le port';
    }
    
    return null;
  }
  
  // Bateau validation for Pecheur
  static String? validateBateau(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le nom du bateau';
    }
    
    return null;
  }
}
