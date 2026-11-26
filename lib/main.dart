import 'package:flutter/widgets.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.quranapp.audio.playback',
      androidNotificationChannelName: 'Pemutaran Audio Al-Qur\'an',
      androidNotificationOngoing: true,
    );
  } catch (_) {
    // Platform tanpa dukungan notifikasi latar belakang (mis. desktop/test).
  }
  runApp(const QuranApp());
}
