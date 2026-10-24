import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../data/shop_repository.dart';

class ShopSetupScreen extends StatefulWidget {
  const ShopSetupScreen({super.key});

  @override
  State<ShopSetupScreen> createState() => _ShopSetupScreenState();
}

class _ShopSetupScreenState extends State<ShopSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedBusinessType;
  String _selectedCountry = 'Indonesia';
  String? _selectedProvince;
  String? _selectedCity;
  bool _isDataLainnyaExpanded = false;

  // Dropdown option lists
  final List<String> _businessTypes = [
    'Kuliner (Makanan & Minuman)',
    'Toko Kelontong / Minimarket',
    'Pakaian & Aksesoris (Fashion)',
    'Jasa (Salon, Laundry, dll)',
    'Elektronik & Gadget',
    'Otomotif & Bengkel',
    'Lainnya',
  ];

  final List<String> _countries = ['Indonesia'];

  final List<String> _provinces = [
    'DKI Jakarta',
    'Banten',
    'Jawa Barat',
    'Jawa Tengah',
    'DI Yogyakarta',
    'Jawa Timur',
    'Bali',
    'Sumatera Utara',
    'Sulawesi Selatan',
    'Kalimantan Timur',
  ];

  // Mapping province to cities/regencies
  final Map<String, List<String>> _provinceCities = const {
    'DKI Jakarta': [
      'Jakarta Pusat',
      'Jakarta Selatan',
      'Jakarta Barat',
      'Jakarta Utara',
      'Jakarta Timur',
      'Kepulauan Seribu',
    ],
    'Banten': [
      'Tangerang',
      'Tangerang Selatan',
      'Serang',
      'Cilegon',
      'Pandeglang',
      'Lebak',
    ],
    'Jawa Barat': [
      'Bandung',
      'Bekasi',
      'Depok',
      'Bogor',
      'Tasikmalaya',
      'Cimahi',
      'Sukabumi',
      'Cirebon',
    ],
    'Jawa Tengah': [
      'Semarang',
      'Surakarta (Solo)',
      'Magelang',
      'Pekalongan',
      'Salatiga',
      'Tegal',
    ],
    'DI Yogyakarta': [
      'Yogyakarta',
      'Sleman',
      'Bantul',
      'Kulon Progo',
      'Gunungkidul',
    ],
    'Jawa Timur': [
      'Surabaya',
      'Malang',
      'Sidoarjo',
      'Gresik',
      'Kediri',
      'Madiun',
      'Probolinggo',
      'Pasuruan',
      'Batu',
    ],
    'Bali': [
      'Denpasar',
      'Badung',
      'Gianyar',
      'Tabanan',
      'Buleleng',
      'Klungkung',
      'Karangasem',
      'Bangli',
      'Jembrana',
    ],
    'Sumatera Utara': [
      'Medan',
      'Binjai',
      'Pematangsiantar',
      'Tanjungbalai',
      'Tebing Tinggi',
    ],
    'Sulawesi Selatan': [
      'Makassar',
      'Parepare',
      'Palopo',
      'Gowa',
      'Maros',
    ],
    'Kalimantan Timur': [
      'Samarinda',
      'Balikpapan',
      'Bontang',
      'Kutai Kartanegara',
    ],
  };

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSaveShop() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBusinessType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih jenis usaha terlebih dahulu.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedProvince == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih provinsi toko Anda.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if (_selectedCity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih kota/kabupaten toko Anda.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final success = await ShopRepository.saveShop(
        businessType: _selectedBusinessType!,
        name: _shopNameController.text.trim(),
        country: _selectedCountry,
        province: _selectedProvince!,
        city: _selectedCity!,
        address: _addressController.text.trim(),
      );

      if (success && mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Data Toko',
          style: TextStyle(
            color: Color(0xFF0F5B67),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Business Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedBusinessType,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('pilih jenis usaha ...'),
                  items: _businessTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBusinessType = value;
                    });
                  },
                ),
                const Gap(20),

                // 2. Shop Name Input
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    hintText: 'Nama Toko',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama Toko tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const Gap(16),

                // Country Label
                Text(
                  'Negara',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(6),

                // 3. Country Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    }
                  },
                ),
                const Gap(16),

                // 4. Province Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedProvince,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  hint: const Text('Pilih Provinsi'),
                  items: _provinces.map((prov) {
                    return DropdownMenuItem<String>(
                      value: prov,
                      child: Text(prov),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = value;
                      _selectedCity = null; // Reset selected city when province changes
                    });
                  },
                ),
                const Gap(16),

                // 5. City/Regency Dropdown (Conditional)
                if (_selectedProvince != null) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text('Pilih Kota / Kabupaten'),
                    items: (_provinceCities[_selectedProvince] ?? []).map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                    },
                  ),
                  const Gap(16),
                ],

                // 6. Address Textarea
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Alamat',
                          contentPadding: EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Gap(10),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on,
                          color: Color(0xFF0F5B67),
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),

                // Location Pin Alert Text
                Text(
                  'Pin lokasi toko belum diatur',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Membantu Pembeli menemukan Tokomu di olshopin.com',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                  ),
                ),
                const Gap(24),

                // 7. Optional Details Accordion
                InkWell(
                  onTap: () {
                    setState(() {
                      _isDataLainnyaExpanded = !_isDataLainnyaExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Data Lainnya (Opsional)',
                          style: TextStyle(
                            color: Color(0xFF0F5B67),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const Gap(6),
                        Icon(
                          _isDataLainnyaExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF0F5B67),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isDataLainnyaExpanded) ...[
                  const Gap(10),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Nomor Izin Usaha / NIB',
                    ),
                  ),
                  const Gap(12),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Catatan Khusus Toko',
                    ),
                  ),
                ],
                const Gap(32),

                // 8. Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleSaveShop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5B67),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SIMPAN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
