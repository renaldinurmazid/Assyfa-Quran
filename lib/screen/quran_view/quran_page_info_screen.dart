import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class QuranPageInfoScreen extends StatelessWidget {
  const QuranPageInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve slug from navigation arguments
    final args = Get.arguments;
    final String slug = (args is Map && args['slug'] != null)
        ? args['slug']
        : 'mushaf_standard';

    final info = _getMushafInfo(slug);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text('Info Mushaf', style: pBold18),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(IconlyLight.arrow_left, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header Card
            _buildHeader(info),
            const SizedBox(height: 32),

            // Description Section
            Text('Tentang Mushaf', style: pBold18),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                info['description'],
                style: pRegular14.copyWith(
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 24),
            // Features Section
            // Text('Fitur Utama', style: pBold18),
            // const SizedBox(height: 16),
            // ...List.generate(
            //   (info['features'] as List).length,
            //   (index) => _buildFeatureItem(info['features'][index]),
            // ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.primaryColor,
            const Color(0xFF0D47A1), // Deep Blue mix
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              IconlyBold.document,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            info['title'],
            style: pBold24.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              info['subtitle'],
              style: pMedium14.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconlyBold.tick_square,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              feature,
              style: pMedium14.copyWith(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: pMedium14.copyWith(color: Colors.grey[600])),
        Text(value, style: pSemiBold14.copyWith(color: AppColor.primaryColor)),
      ],
    );
  }

  Map<String, dynamic> _getMushafInfo(String slug) {
    switch (slug) {
      case 'id':
        return {
          'title': 'Mushaf Indonesia',
          'subtitle': 'Standar Kementerian Agama RI',
          'description':
              'Mushaf Standar Indonesia adalah mushaf yang dibakukan oleh Kementerian Agama Republik Indonesia. Penulisan dan tanda bacanya disesuaikan dengan kebiasaan masyarakat Muslim di Indonesia untuk memudahkan pembacaan bagi masyarakat umum, terutama bagi yang belum terbiasa dengan Rasm Utsmani murni.',
          'features': [
            'Rasm Utsmani Standar Indonesia',
            'Tanda waqaf khas Indonesia',
            'Harakat yang mudah dibaca',
            'Penomoran ayat di akhir',
            'Cocok untuk pemula',
          ],
          'publisher': 'Kementerian Agama RI',
          'pages': '604 Halaman',
          'script_type': 'Rasm Indo',
        };
      case 'id-tajwid':
        return {
          'title': 'Tajwid Indonesia',
          'subtitle': 'Panduan Tajwid Warna Standar Indo',
          'description':
              'Merupakan varian dari Mushaf Standar Indonesia yang dilengkapi dengan kode warna tajwid. Sangat membantu bagi pembaca yang ingin memperbaiki kualitas bacaan (tahsin) dengan panduan visual warna pada setiap hukum bacaan.',
          'features': [
            'Kode Warna Tajwid Lengkap',
            'Standar Kemenag RI',
            'Panduan Hukum Bacaan di Margin',
            'Memudahkan belajar tajwid',
            'Nyaman di mata',
          ],
          'publisher': 'Penerbit Lokal',
          'pages': '604 Halaman',
          'script_type': 'Tajwid Warna',
        };
      case 'kata-tajwid':
        return {
          'title': 'Al-Quran Per-Kata',
          'subtitle': 'Terjemah Per Kata & Tajwid',
          'description':
              'Mushaf ini sangat ideal untuk mentadaburi makna Al-Quran secara mendalam. Dilengkapi dengan terjemahan per kata di bawah setiap lafadz, serta kode tajwid warna, memudahkan Anda memahami arti setiap kosakata sekaligus membaca dengan benar.',
          'features': [
            'Terjemahan Per Kata',
            'Kode Tajwid Warna',
            'Terjemah Kemenag Lengkap',
            'Membantu belajar Bahasa Arab',
            'Layout informatif',
          ],
          'publisher': 'Assyfa Project',
          'pages': '604 Halaman',
          'script_type': 'Per-Kata',
        };
      case 'latin-tajwid':
        return {
          'title': 'Al-Quran Latin',
          'subtitle': 'Transliterasi Latin & Tajwid',
          'description':
              'Dikhususkan bagi yang sedang belajar membaca Al-Quran. Menyediakan transliterasi latin untuk membantu pengucapan, bersanding dengan teks Arab ber-tajwid. Solusi tepat untuk memperlancar bacaan sebelum beralih ke mushaf tanpa latin.',
          'features': [
            'Transliterasi Latin',
            'Kode Tajwid Warna',
            'Teks Arab Jelas',
            'Bantuan cara baca',
            'Cocok untuk mualaf/pemula',
          ],
          'publisher': 'Berbagai Penerbit',
          'pages': '604 Halaman',
          'script_type': 'Latin + Tajwid',
        };
      case 'md':
        return {
          'title': 'Mushaf Madinah',
          'subtitle': 'Rasm Utsmani Standar Internasional',
          'description':
              'Mushaf Madinah adalah standar emas penulisan Al-Quran internasional. Menggunakan Rasm Utsmani murni dengan kaidah penulisan yang merujuk pada cetakan Kompleks Raja Fahd. Menjadi rujukan utama para penghafal Al-Quran (Hafiz) di seluruh dunia.',
          'features': [
            'Rasm Utsmani Murni',
            '15 Baris per Halaman (Pojok)',
            'Akhir ayat selalu di akhir halaman',
            'Khat Naskhi yang indah',
            'Standar Internasional',
          ],
          'publisher': 'King Fahd Complex',
          'pages': '604 Halaman',
          'script_type': 'Rasm Utsmani',
        };
      case 'md-tajwid':
        return {
          'title': 'Tajwid Madinah',
          'subtitle': 'Rasm Utsmani dengan Warna Tajwid',
          'description':
              'Menggabungkan keindahan dan standarisasi Mushaf Madinah dengan kemudahan kode warna tajwid. Membantu para penghafal Al-Quran untuk tetap menjaga ketepatan hukum bacaan saat murajaah atau menghafal.',
          'features': [
            'Layout Madinah (Pojok)',
            'Kode Warna Tajwid',
            'Rasm Utsmani Murni',
            'Memudahkan Tahsin & Tahfidz',
            'Visual yang menarik',
          ],
          'publisher': 'Darussalam / Lainnya',
          'pages': '604 Halaman',
          'script_type': 'Madinah Tajwid',
        };
      default:
        return {
          'title': 'Mushaf Standar',
          'subtitle': 'Mushaf Al-Quran Digital',
          'description':
              'Versi digital dari Al-Quran Al-Karim yang memudahkan Anda membaca, menghafal, dan mentadaburi ayat-ayat suci di mana saja dan kapan saja. Dilengkapi dengan fitur audio murottal dari berbagai Qari ternama dan terjemahan lengkap.',
          'features': [
            'Teks Al-Quran Digital Jernih',
            'Audio Murottal Qari Internasional',
            'Mode Malam dan Siang',
            'Bookmark Otomatis',
            'Pencarian Cepat',
          ],
          'publisher': 'Assyfa Project',
          'pages': '604 Halaman',
          'script_type': 'Digital',
        };
    }
  }
}
