class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    
    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
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
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ est obligatoire';
    }
    
    if (value.length < 2) {
      return 'Ce champ doit contenir au moins 2 caractères';
    }
    
    return null;
  }
  
  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    // Regular expression for phone validation (numbers only)
    final phoneRegExp = RegExp(r'^[0-9]+$');
    
    if (!phoneRegExp.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
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
