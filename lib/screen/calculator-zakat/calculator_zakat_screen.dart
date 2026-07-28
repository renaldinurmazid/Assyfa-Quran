import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';
import 'package:quran_app/routes/app_routes.dart';
import 'package:quran_app/screen/calculator-zakat/calculator_zakat_controller.dart';

class CalculatorZakatScreen extends StatefulWidget {
  const CalculatorZakatScreen({super.key});

  @override
  State<CalculatorZakatScreen> createState() => _CalculatorZakatScreenState();
}

class _CalculatorZakatScreenState extends State<CalculatorZakatScreen> {
  String selectedZakatSlug = 'zakat-maal';

  // Controllers for Fitrah
  final TextEditingController _jumlahOrangController = TextEditingController();
  final TextEditingController _hargaBerasController = TextEditingController();

  // Controllers for Maal
  final TextEditingController _totalHartaController = TextEditingController();
  final TextEditingController _hargaEmasMaalController =
      TextEditingController();

  // Controllers for Penghasilan
  final TextEditingController _gajiBulananController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _hargaEmasPenghasilanController =
      TextEditingController();

  // Controllers for Emas
  final TextEditingController _beratEmasController = TextEditingController();
  final TextEditingController _hargaEmasController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _jumlahOrangController.dispose();
    _hargaBerasController.dispose();
    _totalHartaController.dispose();
    _hargaEmasMaalController.dispose();
    _gajiBulananController.dispose();
    _bonusController.dispose();
    _hargaEmasPenghasilanController.dispose();
    _beratEmasController.dispose();
    _hargaEmasController.dispose();
    super.dispose();
  }

  double _parseValue(String text) {
    return double.tryParse(text.replaceAll('.', '')) ?? 0;
  }

  void _calculateZakat() {
    double totalZakat = 0;
    String breakdown = "";

    if (selectedZakatSlug == 'zakat-fitrah') {
      int orang = int.tryParse(_jumlahOrangController.text) ?? 0;
      double hargaBeras = _parseValue(_hargaBerasController.text);
      totalZakat = orang * 2.5 * hargaBeras;
      breakdown =
          "Jumlah Orang: $orang\nHarga Beras: ${currencyFormatter.format(hargaBeras)}/kg\nKadar Zakat: 2.5kg per orang";
    } else if (selectedZakatSlug == 'zakat-maal') {
      double totalHarta = _parseValue(_totalHartaController.text);
      double hargaEmas = _parseValue(_hargaEmasMaalController.text);
      double nisab = 85 * hargaEmas;

      if (totalHarta >= nisab) {
        totalZakat = totalHarta * 0.025;
        breakdown =
            "Total Harta: ${currencyFormatter.format(totalHarta)}\nNisab (85g Emas): ${currencyFormatter.format(nisab)}\nKadar Zakat: 2.5%";
      } else {
        totalZakat = 0;
        breakdown =
            "Total Harta belum mencapai Nisab (${currencyFormatter.format(nisab)})";
      }
    } else if (selectedZakatSlug == 'zakat-penghasilan') {
      double gaji = _parseValue(_gajiBulananController.text);
      double bonus = _parseValue(_bonusController.text);
      double hargaEmas = _parseValue(_hargaEmasPenghasilanController.text);
      double totalPenghasilan = gaji + bonus;
      double nisabPerBulan = (85 * hargaEmas) / 12;

      if (totalPenghasilan >= nisabPerBulan) {
        totalZakat = totalPenghasilan * 0.025;
        breakdown =
            "Total Penghasilan: ${currencyFormatter.format(totalPenghasilan)}\nNisab Bulanan: ${currencyFormatter.format(nisabPerBulan)}\nKadar Zakat: 2.5%";
      } else {
        totalZakat = 0;
        breakdown =
            "Penghasilan belum mencapai Nisab (${currencyFormatter.format(nisabPerBulan)})";
      }
    } else if (selectedZakatSlug == 'zakat-emas') {
      double berat = double.tryParse(_beratEmasController.text) ?? 0;
      double harga = _parseValue(_hargaEmasController.text);

      if (berat >= 85) {
        totalZakat = (berat * harga) * 0.025;
        breakdown =
            "Berat Emas: $berat gr\nHarga Emas: ${currencyFormatter.format(harga)}/gr\nKadar Zakat: 2.5%";
      } else {
        totalZakat = 0;
        breakdown = "Berat emas belum mencapai Nisab (85 gram)";
      }
    }

    _showResultBottomSheet(totalZakat, breakdown);
  }

  void _showResultBottomSheet(double total, String breakdown) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text('Hasil Perhitungan', style: pSemiBold16),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rincian:', style: pMedium12),
                    const SizedBox(height: 8),
                    Text(breakdown, style: pRegular12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Total Zakat yang Harus Dibayar:', style: pRegular12),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(total),
                style: pSemiBold20.copyWith(
                  color: total > 0
                      ? context.isDarkMode
                            ? Colors.white
                            : Colors.black
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Obx(() {
                final calcController = Get.put(CalculatorZakatController());
                return ElevatedButton(
                  onPressed: calcController.isLoading.value
                      ? null
                      : () async {
                          final listData = [
                            {
                              'title': 'Zakat Maal',
                              'slug': 'zakat-maal',
                              'slug-campaign':
                                  'mari-tunaikan-kewajiban-zakat-maal',
                            },
                            {
                              'title': 'Zakat Fitrah',
                              'slug': 'zakat-fitrah',
                              'slug-campaign': 'zakat-fitrah',
                            },
                            {
                              'title': 'Zakat Penghasilan',
                              'slug': 'zakat-penghasilan',
                              'slug-campaign': 'zakat-penghasilan',
                            },
                            {
                              'title': 'Zakat Emas',
                              'slug': 'zakat-emas',
                              'slug-campaign': 'zakat-emas',
                            },
                          ];

                          final selectedItem = listData.firstWhere(
                            (item) => item['slug'] == selectedZakatSlug,
                            orElse: () => listData[0],
                          );

                          final campaignSlug = selectedItem['slug-campaign']!;

                          final campaignData = await calcController
                              .getCampaignDetail(campaignSlug);
                          if (campaignData != null) {
                            Navigator.pop(context); // Tutup bottom sheet
                            Get.toNamed(
                              Routes.charityPayment,
                              arguments: {
                                'id': campaignData.id,
                                'title': campaignData.title,
                                'slug': campaignSlug,
                                'formType': campaignData.formType,
                                'qurbanPrice': total.toInt(),
                                'withOption': campaignData.withOption,
                                'campaignOptions': campaignData.campaignOptions,
                              },
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.isDarkMode
                        ? AppColor.primaryColorDark
                        : AppColor.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: calcController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Bayar Sekarang',
                          style: pMedium14.copyWith(color: Colors.white),
                        ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // void _resetForm() {
  //   _jumlahOrangController.clear();
  //   _hargaBerasController.clear();
  //   _totalHartaController.clear();
  //   _hargaEmasMaalController.clear();
  //   _gajiBulananController.clear();
  //   _bonusController.clear();
  //   _hargaEmasPenghasilanController.clear();
  //   _beratEmasController.clear();
  //   _hargaEmasController.clear();
  //   setState(() {
  //     selectedZakatSlug = 'zakat-maal';
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Kalkulator Zakat', style: pSemiBold16),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              _buildTypeZakat(context),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(child: _buildDynamicForm(context)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.isDarkMode
                      ? AppColor.primaryColorDark
                      : AppColor.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hitung Zakat',
                  style: pMedium14.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicForm(BuildContext context) {
    switch (selectedZakatSlug) {
      case 'zakat-fitrah':
        return _formZakatFitrah(context);
      case 'zakat-maal':
        return _formZakatMaal(context);
      case 'zakat-penghasilan':
        return _formZakatPenghasilan(context);
      case 'zakat-emas':
        return _formZakatEmas(context);
      default:
        return _formZakatFitrah(context);
    }
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isCurrency = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: pMedium12),
        const SizedBox(height: 8),
        Row(
          children: [
            if (isCurrency)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 52,
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: context.isDarkMode
                        ? Colors.grey.shade800
                        : Colors.grey.shade300,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                alignment: Alignment.center,
                child: Text('Rp', style: pSemiBold14),
              ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: isCurrency ? [_CurrencyInputFormatter()] : [],
                style: pMedium14,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: hint,
                  hintStyle: pRegular12.copyWith(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: isCurrency
                        ? const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: isCurrency
                        ? const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                        : BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColor.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _formZakatFitrah(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Zakat Fitrah',
          'Wajib bagi setiap Muslim di bulan Ramadhan (setara 2.5 kg atau 3.5 liter beras).',
        ),
        _buildInputField(
          context: context,
          label: 'Jumlah Orang',
          hint: 'Contoh: 5',
          controller: _jumlahOrangController,
        ),
        _buildInputField(
          context: context,
          label: 'Harga Beras saat ini (per kg)',
          hint: 'Contoh: 15000',
          controller: _hargaBerasController,
          isCurrency: true,
        ),
      ],
    );
  }

  Widget _formZakatMaal(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Zakat Maal (Harta)',
          'Zakat atas harta yang telah mencapai nisab (setara 85g emas) dan dimiliki selama 1 tahun.',
        ),
        _buildInputField(
          context: context,
          label: 'Total Nilai Harta (Tabungan/Saham/Emas/Lainnya)',
          hint: 'Contoh: 100000000',
          controller: _totalHartaController,
          isCurrency: true,
        ),
        _buildInputField(
          context: context,
          label: 'Harga Emas saat ini (per gram)',
          hint: 'Contoh: 1200000',
          controller: _hargaEmasMaalController,
          isCurrency: true,
        ),
      ],
    );
  }

  Widget _formZakatPenghasilan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Zakat Penghasilan',
          'Zakat yang dikeluarkan dari penghasilan bulanan jika telah mencapai nisab.',
        ),
        _buildInputField(
          context: context,
          label: 'Gaji Bulanan',
          hint: 'Contoh: 10000000',
          controller: _gajiBulananController,
          isCurrency: true,
        ),
        _buildInputField(
          context: context,
          label: 'Penghasilan Lain / Bonus',
          hint: 'Contoh: 2000000',
          controller: _bonusController,
          isCurrency: true,
        ),
        _buildInputField(
          context: context,
          label: 'Harga Emas saat ini (per gram)',
          hint: 'Contoh: 1200000',
          controller: _hargaEmasPenghasilanController,
          isCurrency: true,
        ),
      ],
    );
  }

  Widget _formZakatEmas(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Zakat Emas',
          'Wajib dikeluarkan jika emas yang dimiliki mencapai nisab 85 gram.',
        ),
        _buildInputField(
          context: context,
          label: 'Berat Emas (gram)',
          hint: 'Contoh: 90',
          controller: _beratEmasController,
        ),
        _buildInputField(
          context: context,
          label: 'Harga Emas saat ini (per gram)',
          hint: 'Contoh: 1200000',
          controller: _hargaEmasController,
          isCurrency: true,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: pSemiBold14),
        const SizedBox(height: 4),
        Text(desc, style: pRegular12),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTypeZakat(BuildContext context) {
    final listData = [
      {
        'title': 'Zakat Maal',
        'slug': 'zakat-maal',
        'slug-campaign': 'mari-tunaikan-kewajiban-zakat-maal',
      },
      {
        'title': 'Zakat Fitrah',
        'slug': 'zakat-fitrah',
        'slug-campaign': 'zakat-fitrah',
      },
      {
        'title': 'Zakat Penghasilan',
        'slug': 'zakat-penghasilan',
        'slug-campaign': 'zakat-penghasilan',
      },
      {
        'title': 'Zakat Emas',
        'slug': 'zakat-emas',
        'slug-campaign': 'zakat-emas',
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Jenis Zakat', style: pMedium14),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedZakatSlug,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.isDarkMode
                    ? Colors.grey.shade800
                    : Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          items: listData.map((item) {
            return DropdownMenuItem<String>(
              value: item['slug'],
              child: Text(item['title']!, style: pRegular12),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedZakatSlug = value!;
            });
          },
        ),
      ],
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (newValue.text.compareTo(oldValue.text) == 0) {
      return newValue;
    }

    // Remove all non-digits
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final double value = double.parse(newText);
    final formatter = NumberFormat.decimalPattern('id');
    String formattedText = formatter.format(value);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
