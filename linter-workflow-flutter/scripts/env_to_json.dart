// Helper script to convert .env files to JSON format for --dart-define-from-file
// Usage: dart scripts/env_to_json.dart .dev.env .dart_defines/dev.json

import 'dart:convert';
import 'dart:io';

void main(final List<String> args) {
  if (args.length != 2) {
    exit(1);
  }

  final String envFile = args[0];
  final String outputFile = args[1];

  final File file = File(envFile);

  if (!file.existsSync()) {
    exit(1);
  }

  final List<String> lines = file.readAsLinesSync();
  final Map<String, String> envVars = <String, String>{};

  for (String line in lines) {
    line = line.trim();

    // Skip empty lines and comments
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    // Parse KEY=VALUE
    final int equalIndex = line.indexOf('=');
    if (equalIndex > 0) {
      final String key = line.substring(0, equalIndex).trim();
      final String value = line.substring(equalIndex + 1).trim();

      // Remove quotes if present
      String cleanValue = value;
      if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
          (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
        cleanValue = cleanValue.substring(1, cleanValue.length - 1);
      }

      envVars[key] = cleanValue;
    }
  }

  // Create output directory if it doesn't exist
  final Directory outputDir = File(outputFile).parent;
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  // Write JSON file
  final String jsonContent = const JsonEncoder.withIndent('  ').convert(envVars);
  File(outputFile).writeAsStringSync(jsonContent);

}
