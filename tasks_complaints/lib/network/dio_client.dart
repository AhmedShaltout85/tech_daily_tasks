import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/app_colors.dart';

class DioClient {
  static final DioClient instance = DioClient._();
  factory DioClient() => instance;

  late final Dio _dio;

  static const String _baseUrl = 'http://41.33.226.211:8099/tasks-complaint-emp';

  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  void _handleError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'انتهت مهلة الاتصال';
        break;
      case DioExceptionType.connectionError:
        message = 'لا يوجد اتصال بالإنترنت';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'تم إلغاء الطلب';
        break;
      default:
        message = 'حدث خطأ غير متوقع';
    }

    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.error,
      textColor: AppColors.card,
    );
  }

  String _handleBadResponse(Response? response) {
    if (response == null) return 'خطأ في الخادم';

    switch (response.statusCode) {
      case 400:
        if (response.data is Map) {
          final errors = response.data as Map;
          return errors.values.first.toString();
        }
        return 'بيانات غير صحيحة';
      case 404:
        return 'السجل غير موجود';
      case 500:
        return 'خطأ في الخادم';
      default:
        return 'خطأ غير معروف (${response.statusCode})';
    }
  }
}
