import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:quran_app/theme/app_color.dart';
import 'package:quran_app/theme/font.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/png/bg-palestine.png'),
                    colorFilter: ColorFilter.mode(
                      Color.fromARGB(100, 0, 0, 0),
                      BlendMode.srcOver,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  'Pesan',
                  style: pSemiBold16.copyWith(color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'يٰٓاَيُّهَا الَّذِيْنَ اٰمَنُوا اذْكُرُوا اللّٰهَ ذِكْرًا كَثِيْرًاۙ',
                          style: pSemiBold18.copyWith(
                            color: AppColor.backgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Wahai orang-orang yang beriman, ingatlah Allah dengan zikir sebanyak-banyaknya.',
                        style: pRegular12.copyWith(
                          color: AppColor.backgroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColor.backgroundColor],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _listMessage(),
        ],
      ),
    );
  }

  Widget _listMessage() {
    final dataMessage = [];
    return Expanded(
      child: dataMessage.isEmpty
          ? Center(child: Text('Tidak ada pesan', style: pRegular12))
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemCount: dataMessage.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconlyBold.calendar,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataMessage[index]['name'],
                            style: pSemiBold14.copyWith(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dataMessage[index]['message'],
                            style: pRegular12,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                IconlyBold.time_circle,
                                color: Colors.grey.shade800,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text('2 Jam yang lalu', style: pRegular10),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
