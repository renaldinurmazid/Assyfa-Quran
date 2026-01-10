import 'package:flutter/material.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class TilawahkuScreen extends StatelessWidget {
  const TilawahkuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Text('Aktivitas Tilawah', style: pSemiBold16),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: [_listDataTilawah()]),
      ),
    );
  }

  Widget _listDataTilawah() {
    final dataTilawah = [
      {
        'nama': 'Pembatas 1',
        'halaman': 'Hlm.302',
        'surah': '2.AlBaqarah:198',
        'bahasa': 'Indonesia',
        'status': 'Baru Saja',
      },
      {
        'nama': 'Pembatas 2',
        'halaman': 'Hlm.302',
        'surah': '2.AlBaqarah:198',
        'bahasa': 'Indonesia',
        'status': 'Baru Saja',
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tilawahku', style: pRegular12),
          const SizedBox(height: 12),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pembatas 1', style: pSemiBold14),
                          Row(
                            children: [
                              Text('Hlm.302', style: pMedium12),
                              Container(
                                height: 12,
                                width: 1,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                color: Colors.grey.shade300,
                              ),
                              Text('2.AlBaqarah:198', style: pMedium12),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Indonesia', style: pRegular12),
                              Container(
                                height: 4,
                                width: 4,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColor.primaryColor,
                                ),
                              ),
                              Text('Baru Saja', style: pRegular12),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      child: Text(
                        'Edit',
                        style: pMedium12.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 12);
            },
            itemCount: dataTilawah.length,
          ),
        ],
      ),
    );
  }
}
