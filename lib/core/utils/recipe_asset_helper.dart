const String recipePlaceholderAsset = 'assets/recipes/images/placeholder.jpg';

/// Normalizes recipe asset paths so we can reorganize files without breaking
/// existing Firestore data that might still point at legacy paths.
String normalizeRecipeAsset(String? assetPath) {
  final path = assetPath?.trim() ?? '';
  if (path.isEmpty) return recipePlaceholderAsset;

  const imagesRoot = 'assets/recipes/images/';
  const legacyRoot = 'assets/recipes/';

  if (path.startsWith(imagesRoot)) return path;

  if (path.startsWith(legacyRoot)) {
    final fileName = path.substring(legacyRoot.length);
    if (fileName.isEmpty) return recipePlaceholderAsset;
    return '$imagesRoot$fileName';
  }

  // If a bare filename is provided (e.g., "foo.jpg"), place it in the images folder.
  if (!path.contains('/')) return '$imagesRoot$path';

  return path;
}
