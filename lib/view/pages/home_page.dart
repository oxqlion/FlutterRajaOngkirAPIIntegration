part of 'pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeViewmodel homeViewModel = HomeViewmodel();

  @override
  void initState() {
    super.initState();
    homeViewModel.getProvinceList();
  }

  String? selectedProvider;
  Province? selectedOriginProvince;
  var selectedOriginCity;
  Province? selectedDestinationProvince;
  var selectedDestinationCity;
  TextEditingController weightController = TextEditingController();

  void _calculateShippingCost() {
    // Validate inputs
    if (selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih provider terlebih dahulu')),
      );
      return;
    }

    if (weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan berat paket')),
      );
      return;
    }

    if (selectedOriginProvince == null || selectedOriginCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kota asal')),
      );
      return;
    }

    if (selectedDestinationProvince == null ||
        selectedDestinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kota tujuan')),
      );
      return;
    }

    // Call ViewModel method to calculate shipping cost
    homeViewModel.calculateShippingCost(
      originCityId: selectedOriginCity!.cityId,
      destinationCityId: selectedDestinationCity!.cityId,
      weight: int.parse(weightController.text),
      courier: selectedProvider!,
    );
  }

  // Add a button to trigger cost calculation
  Widget _buildCalculateCostButton() {
    return ElevatedButton(
      onPressed: _calculateShippingCost,
      child: const Text('Hitung Biaya Kirim'),
    );
  }

  // Method to show shipping cost results
  void _showShippingCostResults() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<HomeViewmodel>(
          builder: (context, viewModel, child) {
            switch (viewModel.shippingCosts.status) {
              case Status.loading:
                return const Center(child: CircularProgressIndicator());
              case Status.error:
                return Center(
                  child: Text('Error: ${viewModel.shippingCosts.message}'),
                );
              case Status.completed:
                final costs = viewModel.shippingCosts.data!;
                return ListView.builder(
                  itemCount: costs.length,
                  itemBuilder: (context, index) {
                    final cost = costs[index];
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cost.costs.length,
                      itemBuilder: (context, serviceIndex) {
                        final service = cost.costs[serviceIndex];
                        return ListTile(
                          title: Text(service.service),
                          subtitle: Text(service.description),
                          trailing: Text('Rp ${service.cost[0].value}'),
                        );
                      },
                    );
                  },
                );
              default:
                return const Center(child: Text('Belum ada data'));
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<HomeViewmodel>(
      create: (context) => homeViewModel,
      child: SafeArea(
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // First Part: Select Provider and Input Weight
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedProvider,
                            items: ['jne', 'pos', 'tiki']
                                .map((provider) => DropdownMenuItem(
                                      value: provider,
                                      child: Text(provider),
                                    ))
                                .toList(),
                            hint: const Text("Pilih Provider"),
                            onChanged: (newValue) {
                              setState(() {
                                selectedProvider = newValue;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Berat (gram)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Second Part: Origin Selection
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Asal"),
                        Consumer<HomeViewmodel>(
                          builder: (context, value, _) {
                            switch (value.provinceList.status) {
                              case Status.loading:
                                return const Center(
                                    child: CircularProgressIndicator());
                              case Status.error:
                                return Text(
                                    "Error: ${value.provinceList.message ?? 'Unknown error'}");
                              case Status.completed:
                                return DropdownButton<Province>(
                                  isExpanded: true,
                                  value: selectedOriginProvince,
                                  items: value.provinceList.data!
                                      .map<DropdownMenuItem<Province>>(
                                          (Province province) {
                                    return DropdownMenuItem(
                                      value: province,
                                      child: Text(province.province.toString()),
                                    );
                                  }).toList(),
                                  hint: const Text("Pilih Provinsi"),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedOriginProvince = newValue;
                                      selectedOriginCity = null;
                                      homeViewModel.getCityList(
                                          provId: newValue!.provinceId,
                                          isOrigin: true);
                                    });
                                  },
                                );
                              default:
                                return const Text('Default Case Error');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<HomeViewmodel>(
                          builder: (context, value, _) {
                            switch (value.originCityList.status) {
                              case Status.loading:
                                return const Text(
                                    "Pilih provinsi terlebih dahulu");
                              case Status.error:
                                return Text(
                                    "Error: ${value.originCityList.message ?? 'Unknown error'}");
                              case Status.completed:
                                return DropdownButton<City>(
                                  isExpanded: true,
                                  value: selectedOriginCity,
                                  items: value.originCityList.data!
                                      .map<DropdownMenuItem<City>>((City city) {
                                    return DropdownMenuItem(
                                      value: city,
                                      child: Text(city.cityName.toString()),
                                    );
                                  }).toList(),
                                  hint: const Text("Pilih Kota"),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedOriginCity = newValue;
                                    });
                                  },
                                );
                              default:
                                return const Text('Default Case Error');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Third Part: Destination Selection
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Tujuan"),
                        Consumer<HomeViewmodel>(
                          builder: (context, value, _) {
                            switch (value.provinceList.status) {
                              case Status.loading:
                                return const Center(
                                    child: CircularProgressIndicator());
                              case Status.error:
                                return Text(
                                    "Error: ${value.provinceList.message ?? 'Unknown error'}");
                              case Status.completed:
                                return DropdownButton<Province>(
                                  isExpanded: true,
                                  value: selectedDestinationProvince,
                                  items: value.provinceList.data!
                                      .map<DropdownMenuItem<Province>>(
                                          (Province province) {
                                    return DropdownMenuItem(
                                      value: province,
                                      child: Text(province.province.toString()),
                                    );
                                  }).toList(),
                                  hint: const Text("Pilih Provinsi"),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDestinationProvince = newValue;
                                      selectedDestinationCity = null;
                                      homeViewModel.getCityList(
                                          provId: newValue!.provinceId,
                                          isOrigin: false);
                                    });
                                  },
                                );
                              default:
                                return const Text('Default Case Error');
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<HomeViewmodel>(
                          builder: (context, value, _) {
                            switch (value.destinationCityList.status) {
                              case Status.loading:
                                return const Text(
                                    "Pilih provinsi terlebih dahulu");
                              case Status.error:
                                return Text(
                                    "Error: ${value.destinationCityList.message ?? 'Unknown error'}");
                              case Status.completed:
                                return DropdownButton<City>(
                                  isExpanded: true,
                                  value: selectedDestinationCity,
                                  items: value.destinationCityList.data!
                                      .map<DropdownMenuItem<City>>((City city) {
                                    return DropdownMenuItem(
                                      value: city,
                                      child: Text(city.cityName.toString()),
                                    );
                                  }).toList(),
                                  hint: const Text("Pilih Kota"),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedDestinationCity = newValue;
                                    });
                                  },
                                );
                              default:
                                return const Text('Default Case Error');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                _buildCalculateCostButton(),
                const SizedBox(height: 20.0),
                Consumer<HomeViewmodel>(
                  builder: (context, viewModel, child) {
                    // Automatically show results when costs are loaded
                    if (viewModel.shippingCosts.status == Status.completed) {
                      return const Text("Ada bang");
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   _showShippingCostResults();
                      // });
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
