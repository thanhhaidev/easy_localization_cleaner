import 'package:logger/logger.dart';

export 'package:logger/logger.dart';

final _filter = ProductionFilter();

/// A logger instance.
final Logger logger = Logger(
  filter: _filter,
  printer: SimplePrinter(),
  level: Level.info,
);

/// A logger extension to log messages only once.
extension LoggerExt on Logger {
  static final Set<int> _loggedOnce = {};

  /// Logs a message only once.
  void logOnce(Level level, Object message) {
    final hashCode = message.hashCode;

    if (_loggedOnce.contains(hashCode)) {
      return;
    }

    log(level, message);
    _loggedOnce.add(hashCode);
  }

  /// Sets the filter level using a setter.
  set filterLevel(Level level) {
    _filter.level = level;
  }
}
