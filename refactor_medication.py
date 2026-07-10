import re

with open('lib/features/medications/data/repositories/medication_repository_impl.dart', 'r') as f:
    content = f.read()

# Replace Either<Failure, T> with AsyncResponse<T> or Either<String, T>
# For public methods, use AsyncResponse<T>. For private methods, use Either<String, T>.
content = content.replace('Future<Either<Failure, ', 'AsyncResponse<')

# For private methods returning Future<Either<Failure, T>>
content = content.replace('Future<Either<String, ', 'Future<Either<String, ') # Just to be safe, replace all private methods that didn't get caught
content = re.sub(r'Either<Failure, (.+?)>', r'Either<String, \1>', content)

# Replace networkInfo.isConnected with connectivityService.isConnected
content = content.replace('networkInfo.isConnected', 'connectivityService.isConnected')

# Replace Left(ServerFailure(e.message ?? 'Server error')) with Left(e.message ?? 'Server error')
# Wait, ServerFailure doesn't have e.message directly if we don't have ApiException imported.
# Let's import exceptions.dart back because ApiException is still there. We removed it by accident.
# Wait, let's keep ApiException in exceptions.dart, we just remove the Failure class usage.

content = content.replace("ServerFailure(e.message ?? 'Server error')", "e.message ?? 'Server error'")
content = content.replace("ServerFailure(e.toString())", "e.toString()")
content = content.replace("ServerFailure('No internet connection')", "'No internet connection'")
content = content.replace("left(CacheFailure())", "left('Cache failure')")
content = content.replace("left(CacheFailure())", "left('Cache failure')") # Just in case

# Now we need to add back exceptions.dart
if 'import \'../../../../core/exceptions/exceptions.dart\';' not in content:
    content = content.replace(
        "import '../../../../core/services/connectivity_service.dart';",
        "import '../../../../core/exceptions/exceptions.dart';\nimport '../../../../core/services/connectivity_service.dart';"
    )

with open('lib/features/medications/data/repositories/medication_repository_impl.dart', 'w') as f:
    f.write(content)
