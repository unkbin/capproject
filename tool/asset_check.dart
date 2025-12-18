import 'dart:io';

// Regex to capture asset references in code (images, pdfs).
final _assetRegex = RegExp(r'assets\/[A-Za-z0-9_\-\.\/]+\.(?:png|jpe?g|pdf)');

void main() {
  final issues = <String>[];
  final warnings = <String>[];

  final codeReferences = _collectAssetReferences();

  // Ensure referenced assets exist.
  final missing = codeReferences.where((p) => !File(p).existsSync()).toList()
    ..sort();
  if (missing.isNotEmpty) {
    issues.add('Missing assets referenced in code:\n'
        '${missing.map((e) => ' - $e').join('\n')}');
  }

  // Enforce structure: recipe assets should live under assets/recipes/images.
  final strayRecipeFiles = _listFiles('assets/recipes')
      .where((path) => !path.startsWith('assets/recipes/images/'))
      .toList()
    ..sort();
  if (strayRecipeFiles.isNotEmpty) {
    issues.add('Recipe assets should be inside assets/recipes/images/:\n'
        '${strayRecipeFiles.map((e) => ' - $e').join('\n')}');
  }

  // Surface unused docs to keep the folder tidy (does not fail build).
  final docAssets = _listFiles('assets/docs', extensions: const ['.pdf']);
  final unusedDocs = docAssets.difference(codeReferences.toSet()).toList()
    ..sort();
  if (unusedDocs.isNotEmpty) {
    warnings.add('Docs not referenced in code (clean up or document usage):\n'
        '${unusedDocs.map((e) => ' - $e').join('\n')}');
  }

  _printOutcome(issues, warnings);
  exit(issues.isEmpty ? 0 : 1);
}

Set<String> _collectAssetReferences() {
  final references = <String>{};
  for (final file in _dartFiles(Directory('lib'))) {
    final content = file.readAsStringSync();
    for (final match in _assetRegex.allMatches(content)) {
      references.add(match.group(0)!);
    }
  }
  return references;
}

Iterable<File> _dartFiles(Directory dir) sync* {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      yield entity;
    }
  }
}

Set<String> _listFiles(
  String directory, {
  List<String> extensions = const ['.png', '.jpg', '.jpeg'],
}) {
  final dir = Directory(directory);
  if (!dir.existsSync()) return <String>{};

  final extSet = extensions.toSet();
  final results = <String>{};

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File) continue;
    final normalized = entity.path.replaceAll('\\', '/');
    if (extSet.any(normalized.toLowerCase().endsWith)) {
      results.add(normalized);
    }
  }

  return results;
}

void _printOutcome(List<String> issues, List<String> warnings) {
  if (issues.isEmpty && warnings.isEmpty) {
    stdout.writeln('Asset check passed: no issues found.');
    return;
  }

  if (issues.isNotEmpty) {
    stdout.writeln('Issues:');
    for (final issue in issues) {
      stdout.writeln(issue);
    }
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('\nWarnings:');
    for (final warning in warnings) {
      stdout.writeln(warning);
    }
  }
}
