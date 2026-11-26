/// Format durasi menjadi `mm:ss`, atau `--:--` bila belum diketahui (docs/05 §2).
String formatDuration(Duration? duration) {
  if (duration == null) return '--:--';
  final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:$mm:$ss';
  }
  return '$mm:$ss';
}

/// Format sisa waktu `-mm:ss`, atau `--:--` bila durasi total belum diketahui.
String formatRemaining(Duration position, Duration? total) {
  if (total == null) return '--:--';
  final rem = total - position;
  return '-${formatDuration(rem.isNegative ? Duration.zero : rem)}';
}

/// Format kalimat ramah untuk pembaca layar, mis. "4 menit 15 detik".
String formatDurationSemantic(Duration? duration) {
  if (duration == null) return 'durasi belum diketahui';
  final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes == 0) return '$seconds detik';
  if (seconds == 0) return '$minutes menit';
  return '$minutes menit $seconds detik';
}
