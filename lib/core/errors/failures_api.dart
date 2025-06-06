import 'package:dio/dio.dart';

abstract class FailureApi {
  final String errMessage;

  const FailureApi(this.errMessage);
}

class ServerFailureApi extends FailureApi {
  ServerFailureApi(super.errMessage);

  factory ServerFailureApi.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.connectionTimeout:
        return ServerFailureApi('Connection timeout with ApiServer');

      case DioErrorType.sendTimeout:
        return ServerFailureApi('Send timeout with ApiServer');

      case DioErrorType.receiveTimeout:
        return ServerFailureApi('Receive timeout with ApiServer');

      case DioErrorType.badResponse:
        return ServerFailureApi.fromResponse(
            dioError.response!.statusCode, dioError.response!.data);
      case DioErrorType.cancel:
        return ServerFailureApi('Request to ApiServer was canceld');

      default:
        return ServerFailureApi('Opps There was an Error, Please try again');
    }
  }

  factory ServerFailureApi.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailureApi(response['error']['message']);
    } else if (statusCode == 404) {
      return ServerFailureApi('Your request not found, Please try later!');
    } else if (statusCode == 500) {
      return ServerFailureApi('Internal Server error, Please try later');
    } else {
      return ServerFailureApi('Opps There was an Error, Please try again');
    }
  }
}
