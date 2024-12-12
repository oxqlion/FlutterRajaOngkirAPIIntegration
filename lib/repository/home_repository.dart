import 'package:tugas_pak_myc/data/network/network_api_service.dart';
import 'package:tugas_pak_myc/model/model.dart';
import 'dart:developer';

class HomeRepository {
  final _apiServices = NetworkApiServices();

  Future<List<Province>> fetchProvinces() async {
    try {
      log('Fetching provinces...');
      dynamic response = await _apiServices.getApiResponse('/starter/province');
      List<Province> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        log('Provinces fetched successfully.');
        result = (response['rajaongkir']['results'] as List)
            .map((e) => Province.fromJson(e))
            .toList();
      } else {
        log('Failed to fetch provinces. Status: ${response['rajaongkir']['status']['code']}, Message: ${response['rajaongkir']['status']['description']}',
            level: 2);
      }

      return result;
    } catch (e, stackTrace) {
      log('Error fetching provinces: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<City>> fetchCities(var provId) async {
    try {
      log('Fetching cities for province ID: $provId');
      dynamic response = await _apiServices.getApiResponse('/starter/city');
      List<City> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        log('Cities fetched successfully.');
        result = (response['rajaongkir']['results'] as List)
            .map((e) => City.fromJson(e))
            .toList();
      } else {
        log('Failed to fetch cities. Status: ${response['rajaongkir']['status']['code']}, Message: ${response['rajaongkir']['status']['description']}',
            level: 2);
      }

      List<City> selectedCities =
          result.where((city) => city.provinceId == provId).toList();

      log('${selectedCities.length} cities found for province ID: $provId');
      return selectedCities;
    } catch (e, stackTrace) {
      log('Error fetching cities: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<ShippingCost>> fetchShippingCosts({
    required String origin,
    required String destination,
    required int weight,
    required String courier,
  }) async {
    try {
      log('Fetching shipping costs with origin: $origin, destination: $destination, weight: $weight, courier: $courier');
      final response = await _apiServices.postApiResponse(
        'starter/cost',
        {
          'origin': origin,
          'destination': destination,
          'weight': weight.toString(),
          'courier': courier,
        },
      );

      List<ShippingCost> result = [];

      if (response['rajaongkir']['status']['code'] == 200) {
        log('Shipping costs fetched successfully.');
        result = (response['rajaongkir']['results'] as List)
            .expand((result) => (result['costs'] as List)
                .map((cost) => ShippingCost.fromJson(cost)))
            .toList();
      } else {
        log('Failed to fetch shipping costs. Status: ${response['rajaongkir']['status']['code']}, Message: ${response['rajaongkir']['status']['description']}',
            level: 2);
      }

      return result;
    } catch (e, stackTrace) {
      log('Error fetching shipping costs: $e',
          error: e, stackTrace: stackTrace);
      throw Exception('Failed to fetch shipping costs: $e');
    }
  }
}
