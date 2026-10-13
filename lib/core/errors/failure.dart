/// Base class for all domain/data failures.
abstract class Failure {
  final String message;
  final Object? cause;

  const Failure(this.message, [this.cause]);

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' ($cause)' : ''}';
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.cause]);
}

class PlatformFailure extends Failure {
  const PlatformFailure(super.message, [super.cause]);
}

class ParseFailure extends Failure {
  const ParseFailure(super.message, [super.cause]);
}
