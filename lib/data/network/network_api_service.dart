import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tugas_pak_myc/data/app_exception.dart';
import 'package:tugas_pak_myc/data/network/base_api_services.dart';
import 'package:tugas_pak_myc/shared/shared.dart';

class NetworkApiServices implements BaseApiServices {
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 500:
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while communicating with server');
    }
  }

  @override
  Future getApiResponse(String endpoint) async {
    dynamic responseJson;
    try {
      final response = await http
          .get(Uri.https(Const.baseUrl, endpoint), headers: <String, String>{
        'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        'key': Const.apiKey
      });
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw FetchDataException('Network request time out!');
      // } on HttpException { throw NoInternetException();
    }
    return responseJson;
  }

  @override
  Future postApiResponse(String url, dynamic data) async {
    dynamic responseJson;
    try {
      final response = await http.post(
        Uri.https(Const.baseUrl, url),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
          'key': Const.apiKey
        },
        body: data,
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw FetchDataException('Network request time out!');
    }
    return responseJson;
  }
}
