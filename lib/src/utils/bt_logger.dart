import 'package:logger/logger.dart';

class BTLogger {
  static final Logger _instance = Logger();

  static void verbose(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance.t(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void error(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance.e(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void debug(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance.d(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void info(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance.i(message, time: time, error: error, stackTrace: stackTrace);
  }

  static void warning(
    String message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _instance.w(message, time: time, error: error, stackTrace: stackTrace);
  }
}
