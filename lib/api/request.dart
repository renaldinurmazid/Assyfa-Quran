import 'package:dio/dio.dart';
import 'package:get/get.dart' as get_ext;
import 'package:quran_app/api/url.dart';
import 'package:quran_app/controller/global/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Request {
  // Singleton pattern
  static final Request _instance = Request._internal();
  factory Request() => _instance;
  Request._internal() {
    _initDio();
  }

  late Dio dio;

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: Url.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // If the request specifically asks not to use a token, skip it
          final bool useToken = options.extra['useToken'] ?? true;

          if (useToken) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle Unauthenticated
            try {
              if (get_ext.Get.isRegistered<AuthController>()) {
                AuthController.to.handleSignOut();
              }
            } catch (_) {}

            get_ext.Get.snackbar(
              'Session Expired',
              'Silahkan login kembali',
              snackPosition: get_ext.SnackPosition.BOTTOM,
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    bool useToken = true,
  }) async {
    return await dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(extra: {'useToken': useToken}),
    );
  }

  Future<Response> post(
    String url, {
    dynamic data,
    bool useToken = true,
  }) async {
    return await dio.post(
      url,
      data: data,
      options: Options(extra: {'useToken': useToken}),
    );
  }

  Future<Response> put(String url, {dynamic data, bool useToken = true}) async {
    return await dio.put(
      url,
      data: data,
      options: Options(extra: {'useToken': useToken}),
    );
  }

  Future<Response> patch(
    String url, {
    dynamic data,
    bool useToken = true,
  }) async {
    return await dio.patch(
      url,
      data: data,
      options: Options(extra: {'useToken': useToken}),
    );
  }

  Future<Response> delete(
    String url, {
    dynamic data,
    bool useToken = true,
  }) async {
    return await dio.delete(
      url,
      data: data,
      options: Options(extra: {'useToken': useToken}),
    );
  }

  // Support for file uploads
  Future<Response> postMultipart(
    String url,
    Map<String, dynamic> data, {
    bool useToken = true,
  }) async {
    FormData formData = FormData.fromMap(data);
    return await dio.post(
      url,
      data: formData,
      options: Options(
        extra: {'useToken': useToken},
        contentType: 'multipart/form-data',
      ),
    );
  }
}
