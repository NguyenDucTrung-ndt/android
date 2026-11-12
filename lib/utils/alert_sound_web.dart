import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('AudioContext')
external JSFunction? get _audioContextCtor;

@JS('webkitAudioContext')
external JSFunction? get _webkitAudioContextCtor;

/// Phát 2 tiếng bíp ngắn bằng Web Audio API khi đồng hồ đếm ngược về 0 trên Chrome.
void playWebAlertSound() {
  try {
    final ctor = _audioContextCtor ?? _webkitAudioContextCtor;
    if (ctor == null) return;
    final ctx = ctor.callAsConstructor<JSObject>();
    final now = (ctx.getProperty<JSNumber>('currentTime'.toJS)).toDartDouble;

    void beep(double startOffset, double freq, double duration) {
      final osc = ctx.callMethod<JSObject>('createOscillator'.toJS);
      final gain = ctx.callMethod<JSObject>('createGain'.toJS);
      osc.setProperty('type'.toJS, 'sine'.toJS);
      final freqParam = osc.getProperty<JSObject>('frequency'.toJS);
      freqParam.callMethod('setValueAtTime'.toJS, freq.toJS, (now + startOffset).toJS);

      final gainParam = gain.getProperty<JSObject>('gain'.toJS);
      gainParam.callMethod('setValueAtTime'.toJS, 0.2.toJS, (now + startOffset).toJS);
      gainParam.callMethod(
        'exponentialRampToValueAtTime'.toJS,
        0.001.toJS,
        (now + startOffset + duration).toJS,
      );

      osc.callMethod('connect'.toJS, gain);
      gain.callMethod('connect'.toJS, ctx.getProperty<JSObject>('destination'.toJS));
      osc.callMethod('start'.toJS, (now + startOffset).toJS);
      osc.callMethod('stop'.toJS, (now + startOffset + duration).toJS);
    }

    beep(0.0, 880, 0.18);
    beep(0.24, 1046.5, 0.25);
  } catch (_) {
    // Bỏ qua an toàn nếu trình duyệt chặn audio tự động.
  }
}

