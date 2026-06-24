import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class HttpService {
  HttpService._();

  static final HttpService _instance = HttpService._();
  static HttpService get instance => _instance;

  late final Dio dio;

  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        queryParameters: {'api_key': ApiConstants.apiKey},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_ErrorInterceptor());
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = DioException(
          requestOptions: err.requestOptions,
          message: 'Connection timed out. Please check your internet.',
          type: err.type,
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        err = DioException(
          requestOptions: err.requestOptions,
          message: _statusMessage(statusCode),
          type: err.type,
          response: err.response,
        );
      case DioExceptionType.connectionError:
        err = DioException(
          requestOptions: err.requestOptions,
          message: 'No internet connection.',
          type: err.type,
        );
      default:
        err = DioException(
          requestOptions: err.requestOptions,
          message: 'Something went wrong. Please try again.',
          type: err.type,
        );
    }
    handler.next(err);
  }

  String _statusMessage(int? code) {
    switch (code) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Unauthorized. Please check your API key.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Request failed (code $code).';
    }
  }
}
