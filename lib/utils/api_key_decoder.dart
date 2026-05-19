class ApiKeyDecoder {
  // Salt for XOR
  static const int _salt = 42; 
  
  // Encoded Zhipu GLM API Key
  static const List<int> _encoded = [72, 79, 30, 31, 19, 31, 76, 25, 76, 76, 30, 73, 30, 73, 72, 24, 18, 30, 78, 72, 25, 24, 78, 19, 28, 31, 24, 24, 78, 28, 30, 26, 4, 127, 68, 121, 88, 112, 80, 121, 124, 112, 78, 98, 26, 98, 115, 28, 75];

  static String getGlmFreeKey() {
    if (_encoded.isEmpty || _encoded.length < 5) return '';
    return String.fromCharCodes(_encoded.map((e) => e ^ _salt));
  }
}
