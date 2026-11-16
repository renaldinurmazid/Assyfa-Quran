import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/models/event_model.dart';

Map<String, dynamic> json({
  required DateTime end,
  String? videoUrl,
  Map<String, dynamic> extra = const {},
}) => {
  'id': 1,
  'title': 'Kajian',
  'slug': 'kajian',
  'start_date': end
      .subtract(const Duration(hours: 2))
      .toUtc()
      .toIso8601String(),
  'end_date': end.toUtc().toIso8601String(),
  'video_url': videoUrl,
  'is_published': true,
  ...extra,
};

void main() {
  test('an event whose end time has passed has ended', () {
    final past = EventModel.fromJson(
      json(end: DateTime.now().subtract(const Duration(minutes: 1))),
    );
    final future = EventModel.fromJson(
      json(end: DateTime.now().add(const Duration(hours: 1))),
    );

    expect(past.hasEnded, true);
    expect(future.hasEnded, false);
  });

  test('an event without an end time never counts as ended', () {
    final event = EventModel.fromJson({
      'id': 2,
      'title': 'Tanpa akhir',
      'slug': 'x',
      'start_date': DateTime(2020).toUtc().toIso8601String(),
      'is_published': true,
    });

    expect(event.hasEnded, false);
  });

  test('video_url is parsed and blank links count as no video', () {
    final end = DateTime.now().subtract(const Duration(days: 1));

    final withVideo = EventModel.fromJson(
      json(end: end, videoUrl: 'https://youtube.com/watch?v=abc'),
    );
    final none = EventModel.fromJson(json(end: end));
    final blank = EventModel.fromJson(json(end: end, videoUrl: '   '));

    expect(withVideo.videoUrl, 'https://youtube.com/watch?v=abc');
    expect(withVideo.hasVideo, true);
    expect(none.hasVideo, false);
    expect(blank.hasVideo, false);
  });

  test(
    'the slim row from /api/events/finished parses (no content, no group link)',
    () {
      final event = EventModel.fromJson({
        'id': 9,
        'title': 'Selesai',
        'slug': 'selesai',
        'thumbnail': null,
        'excerpt': 'Ringkas',
        'location': 'Masjid',
        'start_date': '2026-10-10T03:00:00.000000Z',
        'end_date': '2026-10-10T05:00:00.000000Z',
        'price': '0.00',
        'formatted_price': 'Gratis',
        'video_url': null,
        'is_published': true,
      });

      expect(event.content, isNull);
      expect(event.groupLink, isNull);
      expect(event.price, 0);
      expect(event.hasEnded, true);
    },
  );
}
