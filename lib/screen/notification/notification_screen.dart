import 'package:flutter/material.dart';
import 'package:quran_app/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifikasi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationService.showGeneralNotification(
                  id: 1,
                  title: 'Buka Google',
                  body: 'Klik notifikasi ini untuk membuka google.com',
                  url: 'https://www.google.com',
                );
              },
              child: Text('general notif (with URL)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NotificationService.showBigPictureNotification(
                  id: 2,
                  title: 'Promo Spesial!',
                  body: 'Dapatkan diskon menarik di website kami.',
                  assetPath: 'assets/images/png/quran.png',
                  url: 'https://flutter.dev',
                );
              },
              child: Text('notif with image (with URL)'),
            ),
          ],
        ),
      ),
    );
  }
}
