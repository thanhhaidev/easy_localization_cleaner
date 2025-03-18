/// Writes a success message to the console with a green checkmark.
///
/// [text] is the message to display.
void writeSuccess(String text) {
  print('✅ \x1B[32m$text\x1B[0m');
}

/// Writes an error message to the console with a red cross.
///
/// [text] is the message to display.
void writeError(String text) {
  print('❌ \x1B[31m$text\x1B[0m');
}

/// Writes an informational message to the console with a blue rocket icon.
///
/// [text] is the message to display.
void writeInfo(String text) {
  print('🚀 \x1B[34m$text\x1B[0m');
}
