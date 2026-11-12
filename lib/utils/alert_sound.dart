import 'alert_sound_stub.dart'
    if (dart.library.js_interop) 'alert_sound_web.dart' as impl;

/// Phát âm thanh cảnh báo khi hẹn giờ kết thúc trên các nền tảng hỗ trợ (Web).
void playWebAlertSound() => impl.playWebAlertSound();

