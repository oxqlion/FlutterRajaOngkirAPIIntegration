abstract class BaseApiServices {
  Future<dynamic> getApiResponse(String endpoint);
  Future<dynamic> postApiResponse(String url, dynamic data);
  // Future<dynamic> putApiResponse(String url, dynamic data);
  // Future<dynamic> deleteApiResponse(String url);
}