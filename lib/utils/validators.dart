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
  
  // Password validation
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
}
