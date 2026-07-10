import 'package:fpdart/fpdart.dart';

typedef JSON = Map<String, dynamic>;

typedef AsyncResponse<T> = Future<Either<String, T>>;
