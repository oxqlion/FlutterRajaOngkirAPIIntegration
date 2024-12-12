import 'package:flutter/material.dart';
import 'package:tugas_pak_myc/data/response/api_response.dart';
import 'package:tugas_pak_myc/model/model.dart';
import 'package:tugas_pak_myc/repository/home_repository.dart';

class HomeViewmodel with ChangeNotifier {
  final _homeRepo = HomeRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.loading();

  // Separate city lists for origin and destination
  ApiResponse<List<City>> originCityList = ApiResponse.loading();
  ApiResponse<List<City>> destinationCityList = ApiResponse.loading();
  ApiResponse<List<ShippingCost>> shippingCosts = ApiResponse.loading();

  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  // Separate setters for origin and destination city lists
  setOriginCityList(ApiResponse<List<City>> response) {
    originCityList = response;
    notifyListeners();
  }

  setDestinationCityList(ApiResponse<List<City>> response) {
    destinationCityList = response;
    notifyListeners();
  }

  Future<void> getProvinceList() async {
    setProvinceList(ApiResponse.loading());
    _homeRepo.fetchProvinces().then((value) {
      setProvinceList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setProvinceList(ApiResponse.error(error.toString()));
    });
  }

  // Modified to distinguish between origin and destination
  Future<void> getCityList({required var provId, bool isOrigin = true}) async {
    if (isOrigin) {
      setOriginCityList(ApiResponse.loading());
      _homeRepo.fetchCities(provId).then((value) {
        setOriginCityList(ApiResponse.completed(value));
      }).onError((error, stackTrace) {
        setOriginCityList(ApiResponse.error(error.toString()));
      });
    } else {
      setDestinationCityList(ApiResponse.loading());
      _homeRepo.fetchCities(provId).then((value) {
        setDestinationCityList(ApiResponse.completed(value));
      }).onError((error, stackTrace) {
        setDestinationCityList(ApiResponse.error(error.toString()));
      });
    }
  }

  Future<void> calculateShippingCost({
    required String originCityId,
    required String destinationCityId,
    required int weight,
    required String courier,
  }) async {
    try {
      // Set loading state
      shippingCosts = ApiResponse.loading();
      notifyListeners();

      // Fetch shipping costs
      final results = await _homeRepo.fetchShippingCosts(
        origin: originCityId,
        destination: destinationCityId,
        weight: weight,
        courier: courier.toLowerCase(),
      );

      // Convert results to ShippingCost objects
      final costs = results;

      // Set completed state
      shippingCosts = ApiResponse.completed(costs);
      notifyListeners();
    } catch (e) {
      // Set error state
      shippingCosts = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }
}
