import 'package:fpdart/fpdart.dart';

import '../exceptions/exceptions.dart';

typedef JSON = Map<String, dynamic>;

typedef AsyncResponse<T> = Future<Either<String, T>>;

typedef AsyncResponseTyped<T> = Future<Either<ErrorException, T>>;
