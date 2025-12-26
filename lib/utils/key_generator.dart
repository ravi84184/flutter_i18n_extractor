class KeyGenerator {
  static String generate(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join()
        .replaceFirstMapped(
          RegExp(r'^[A-Z]'),
          (m) => m.group(0)!.toLowerCase(),
        );
    
  }
}
