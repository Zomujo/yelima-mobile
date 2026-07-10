class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? code;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'No message provided',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      code: json['code']?.toString(),
    );
  }

  factory ApiResponse.error(String message, {String? code}) {
    return ApiResponse(
      success: false,
      message: message,
      code: code,
    );
  }
}
