import 'package:fpdart/fpdart.dart';
import '../entities/symptom_entity.dart';

abstract class SymptomsRepository {
  Future<Either<String, String>> createSymptom(String description);
  Future<Either<String, List<SymptomEntity>>> getSymptoms({int page = 1, int pageSize = 10});
  Future<Either<String, SymptomEntity>> getSymptomById(String id);
  Future<Either<String, void>> updateSymptom(String id, String description);
  Future<Either<String, void>> deleteSymptom(String id);
}
