// Helper script to convert .env files to --dart-define arguments
// Usage: dart scripts/load_env.dart .dev.env

import 'dart:io';


void main(final List<String> args) {
  if (args.isEmpty) {
    exit(1);
  }

  final String envFile = args[0];
  final File file = File(envFile);

  if (!file.existsSync()) {
    exit(1);
  }

  final List<String> lines = file.readAsLinesSync();
  final List<String> dartDefines = <String>[];

  for (String line in lines) {
    line = line.trim();

    // Skip empty lines and comments
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    // Parse KEY=VALUE
    final List<String> parts = line.split('=');
    if (parts.length >= 2) {
      final String key = parts[0].trim();
      final String value = parts.sublist(1).join('=').trim();

      // Remove quotes if present
      String cleanValue = value;
      if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
          (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
      }

      dartDefines.add('--dart-define=$key=$cleanValue');
    }
  }

}
