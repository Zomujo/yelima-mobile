import 'package:fpdart/fpdart.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptoms_repository.dart';
import '../datasources/symptoms_remote_data_source.dart';

class SymptomsRepositoryImpl implements SymptomsRepository {
  final SymptomsRemoteDataSource remoteDataSource;

  SymptomsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, String>> createSymptom(String description) async {
    try {
      final id = await remoteDataSource.createSymptom(description);
      return Right(id);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<SymptomEntity>>> getSymptoms({int page = 1, int pageSize = 10}) async {
    try {
      final symptoms = await remoteDataSource.getSymptoms(page: page, pageSize: pageSize);
      return Right(symptoms);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, SymptomEntity>> getSymptomById(String id) async {
    try {
      final symptom = await remoteDataSource.getSymptomById(id);
      return Right(symptom);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateSymptom(String id, String description) async {
    try {
      await remoteDataSource.updateSymptom(id, description);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteSymptom(String id) async {
    try {
      await remoteDataSource.deleteSymptom(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message ?? 'Unknown error');
    } catch (e) {
      return Left(e.toString());
    }
  }
}
