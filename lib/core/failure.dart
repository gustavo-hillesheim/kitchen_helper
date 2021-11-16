abstract class Failure {
  final String message;

  Failure(this.message);
}

class BusinessFailure extends Failure {
  BusinessFailure(String message) : super(message);
}
