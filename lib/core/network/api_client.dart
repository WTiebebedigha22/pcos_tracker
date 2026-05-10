import 'package:dio/dio.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
    );
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  // PUT
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return await dio.put(
      path,
      data: data,
    );
  }

  // DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    return await dio.delete(
      path,
      data: data,
    );
  }
}