class StringFilter {
  static bool isValid(String text) {
    final lower = text.toLowerCase();

    if (lower.startsWith('http')) return false;
    if (lower.contains('error')) return true;
    if (lower.contains('{') || lower.contains('}')) return false;
    if (lower.length > 100) return false;

    return true;
  }
}
