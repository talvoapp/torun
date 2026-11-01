import 'dart:math' as math;
import 'dart:typed_data';

class SoundGenerator {
  static const int sampleRate = 48000;
  static const int numChannels = 1;
  static const int sampleWidth = 2;

  // =============================================
  // ✅ دوال مساعدة
  // =============================================

  static double _sine(double freq, double t, [double phase = 0]) {
    return math.sin(2 * math.pi * freq * t + phase);
  }

  static double _square(double freq, double t) {
    return math.sin(2 * math.pi * freq * t) >= 0 ? 1.0 : -1.0;
  }


  static double _sawtooth(double freq, double t) {
    return 2 * ((freq * t) % 1.0) - 1;
  }

  static double _fmSynth(double carrierFreq, double modFreq, double modIndex, double t) {
    final modulator = math.sin(2 * math.pi * modFreq * t) * modIndex;
    return math.sin(2 * math.pi * carrierFreq * t + modulator);
  }


  static double _addHarmonics(double freq, double t, int harmonics, [double detune = 0]) {
    double value = 0;
    double totalAmp = 0;
    for (int i = 1; i <= harmonics; i++) {
      final amplitude = 1.0 / math.pow(i, 1.3);
      final detuneFactor = 1 + (detune * i);
      value += amplitude * math.sin(2 * math.pi * freq * i * detuneFactor * t);
      totalAmp += amplitude;
    }
    return totalAmp > 0 ? value / totalAmp : 0;
  }

  static double _adsr(double t, double duration, double attack, double decay, double sustain, double release) {
    if (t < attack) {
      return math.pow(t / attack, 1.5).toDouble();
    } else if (t < attack + decay) {
      final progress = (t - attack) / decay;
      return 1.0 - (1.0 - sustain) * math.pow(progress, 0.8);
    } else if (t < duration - release) {
      return sustain;
    } else {
      final remaining = (duration - t) / release;
      return sustain * math.pow(remaining, 1.5);
    }
  }

  static List<double> _lowpassFilter(List<double> samples, double cutoff) {
    final filtered = <double>[];
    double prev = 0;
    for (final s in samples) {
      prev = cutoff * s + (1 - cutoff) * prev;
      filtered.add(prev);
    }
    return filtered;
  }

  static List<double> _highpassFilter(List<double> samples, double alpha) {
    final filtered = <double>[];
    double prevIn = 0;
    double prevOut = 0;
    for (final s in samples) {
      prevOut = alpha * (prevOut + s - prevIn);
      prevIn = s;
      filtered.add(prevOut);
    }
    return filtered;
  }


  static List<double> _reverb(List<double> samples, double decay, int delayMs) {
    final delaySamples = (sampleRate * delayMs / 1000).round();
    final result = List<double>.from(samples);
    for (int layer = 0; layer < 3; layer++) {
      final layerDelay = delaySamples * (layer + 1);
      final layerDecay = decay * math.pow(0.7, layer);
      for (int i = layerDelay; i < result.length; i++) {
        result[i] += result[i - layerDelay] * layerDecay;
      }
    }
    return result;
  }

  static List<double> _softClip(List<double> samples, double threshold) {
    return samples.map((s) {
      final clamped = s.clamp(-threshold, threshold);
      return clamped;
    }).toList();
  }

  static double _noise() {
    return math.Random().nextDouble() * 2 - 1;
  }

  static double _pinkNoise() {
    return (_noise() + _noise() + _noise()) / 3;
  }

  // =============================================
  // ✅ توليد WAV
  // =============================================

  static Uint8List _generateWavBytes(List<double> samples) {
    final maxVal = samples.isEmpty ? 1.0 : samples.map((s) => s.abs()).reduce(math.max);
    final scale = maxVal > 0 ? 0.98 / maxVal : 1.0;

    final dataSize = samples.length * 2;
    final fileSize = 36 + dataSize;

    final bytes = BytesBuilder();

    bytes.add('RIFF'.codeUnits);
    bytes.add(_int32LE(fileSize));
    bytes.add('WAVE'.codeUnits);

    bytes.add('fmt '.codeUnits);
    bytes.add(_int32LE(16));
    bytes.add(_int16LE(1));
    bytes.add(_int16LE(numChannels));
    bytes.add(_int32LE(sampleRate));
    bytes.add(_int32LE(sampleRate * numChannels * sampleWidth));
    bytes.add(_int16LE(numChannels * sampleWidth));
    bytes.add(_int16LE(16));

    bytes.add('data'.codeUnits);
    bytes.add(_int32LE(dataSize));

    for (final s in samples) {
      final clamped = (s * scale).clamp(-1.0, 1.0);
      final intVal = (clamped * 32767).round().clamp(-32768, 32767);
      bytes.add(_int16LE(intVal));
    }

    return bytes.toBytes();
  }

  static Uint8List _int32LE(int value) {
    return Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);
  }

  static Uint8List _int16LE(int value) {
    return Uint8List(2)..buffer.asByteData().setInt16(0, value, Endian.little);
  }

  // =============================================
  // ✅ Pack: Default
  // =============================================

  static Uint8List makeJump() {
    const duration = 0.25;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      double freq = 250 + (1400 - 250) * math.pow(progress, 0.5).toDouble();
      freq += math.sin(2 * math.pi * 28 * t) * 20;

      final fmVal = _fmSynth(freq, freq * 2, 1.2, t);
      final harmonics = _addHarmonics(freq, t, 4, 0.002);
      double value = fmVal * 0.7 + harmonics * 0.3;

      final env = _adsr(t, duration, 0.004, 0.06, 0.5, 0.1);
      samples.add(value * env * 0.4);
    }

    return _generateWavBytes(_lowpassFilter(_reverb(samples, 0.2, 25), 0.7));
  }

  static Uint8List makeDuck() {
    const duration = 0.15;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 400 - 250 * progress;

      double tone = math.sin(2 * math.pi * freq * t);
      tone += _addHarmonics(freq, t, 2) * 0.3;
      final noise = _pinkNoise() * 0.5;
      final value = tone * 0.6 + noise * 0.4;

      final env = _adsr(t, duration, 0.008, 0.04, 0.4, 0.07);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_lowpassFilter(samples, 0.6));
  }

  static Uint8List makeScore() {
    const duration = 0.25;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();
    const freq1 = 1318.0;
    const freq2 = 1976.0;
    const freq3 = 2637.0;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double value = _sine(freq1, t) * 0.5 + _sine(freq2, t) * 0.3 + _sine(freq3, t) * 0.2;
      value += _addHarmonics(freq1, t, 3) * 0.2;
      final env = _adsr(t, duration, 0.002, 0.1, 0.3, 0.12);
      samples.add(value * env * 0.28);
    }

    return _generateWavBytes(_reverb(samples, 0.35, 40));
  }

  static Uint8List makeGameOver() {
    const duration = 1.0;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();
    final notes = [(523.0, 0.0, 0.3), (440.0, 0.3, 0.3), (349.0, 0.6, 0.4)];

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _sawtooth(freq, localT) * 0.5 + _square(freq, localT) * 0.3 + _sine(freq, localT) * 0.4;
      final env = _adsr(localT, noteLen, 0.01, 0.1, 0.6, 0.15);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(_reverb(_softClip(samples, 0.8), 0.4, 50));
  }

  static Uint8List makeNewHighScore() {
    const duration = 1.5;
    final samples = <double>[];
    final notes = [
      (523.0, 0.0, 0.15),
      (659.0, 0.15, 0.15),
      (784.0, 0.30, 0.15),
      (1047.0, 0.45, 0.15),
      (1318.0, 0.60, 0.15),
      (1568.0, 0.75, 0.7),
    ];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final vibrato = math.sin(2 * math.pi * 7 * localT) * 5;
      final f = freq + vibrato;
      final value = _fmSynth(f, f * 2, 0.7, localT) * 0.6 + _addHarmonics(f, localT, 4) * 0.4;
      final env = _adsr(localT, noteLen, 0.02, 0.05, 0.65, 0.1);
      samples.add(value * env * 0.4);
    }

    return _generateWavBytes(_reverb(samples, 0.4, 60));
  }

  static Uint8List makeMilestone() {
    const duration = 0.5;
    final samples = <double>[];
    final notes = [(784.0, 0.0, 0.1), (1047.0, 0.1, 0.1), (1318.0, 0.2, 0.3)];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = math.sin(2 * math.pi * freq * localT) * 0.6 + _addHarmonics(freq, localT, 3) * 0.4;
      final env = _adsr(localT, noteLen, 0.005, 0.04, 0.5, 0.06);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_reverb(samples, 0.25, 30));
  }

  static Uint8List makePause() {
    const duration = 0.18;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 700 - 350 * progress;
      double value = math.sin(2 * math.pi * freq * t);
      value += _addHarmonics(freq, t, 3) * 0.3;
      final env = _adsr(t, duration, 0.004, 0.05, 0.5, 0.08);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeResume() {
    const duration = 0.18;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 350 + 350 * progress;
      double value = math.sin(2 * math.pi * freq * t);
      value += _addHarmonics(freq, t, 3) * 0.3;
      final env = _adsr(t, duration, 0.004, 0.05, 0.5, 0.08);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeClick() {
    const duration = 0.07;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double value = _sine(2000, t) * 0.5 + _sine(3000, t) * 0.3 + _sine(4500, t) * 0.2;
      value += _noise() * 0.15;
      final env = _adsr(t, duration, 0.001, 0.02, 0.15, 0.04);
      samples.add(value * env * 0.25);
    }

    return _generateWavBytes(_highpassFilter(samples, 0.5));
  }

  // =============================================
  // ✅ Pack: Classical
  // =============================================

  static Uint8List makeClassicalJump() {
    const duration = 0.3;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 300 + (900 - 300) * math.pow(progress, 0.7).toDouble();
      double value = _addHarmonics(freq, t, 6, 0.001);
      value += math.sin(2 * math.pi * freq * t) * 0.5;
      final env = _adsr(t, duration, 0.05, 0.05, 0.7, 0.15);
      samples.add(value * env * 0.4);
    }

    return _generateWavBytes(_reverb(samples, 0.35, 50));
  }

  static Uint8List makeClassicalDuck() {
    const duration = 0.15;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      const freq = 200.0;
      final value = _addHarmonics(freq, t, 5);
      final env = _adsr(t, duration, 0.01, 0.04, 0.6, 0.08);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeClassicalScore() {
    const duration = 0.4;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();
    const freq = 1047.0;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double value = math.sin(2 * math.pi * freq * t) * 0.7;
      value += _addHarmonics(freq, t, 4) * 0.3;
      final env = _adsr(t, duration, 0.005, 0.15, 0.4, 0.2);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(_reverb(samples, 0.4, 60));
  }

  static Uint8List makeClassicalGameOver() {
    const duration = 1.2;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();
    final notes = [(392.0, 0.0, 0.5), (349.0, 0.5, 0.7)];

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      double value = _addHarmonics(freq, localT, 8);
      value += math.sin(2 * math.pi * freq * localT) * 0.3;
      final env = _adsr(localT, noteLen, 0.05, 0.1, 0.8, 0.3);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_reverb(samples, 0.5, 80));
  }

  static Uint8List makeClassicalHighScore() {
    const duration = 1.5;
    final samples = <double>[];
    final notes = [
      (523.0, 0.0, 0.2),
      (587.0, 0.2, 0.2),
      (659.0, 0.4, 0.2),
      (784.0, 0.6, 0.2),
      (880.0, 0.8, 0.2),
      (1047.0, 1.0, 0.5),
    ];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _addHarmonics(freq, localT, 5);
      final env = _adsr(localT, noteLen, 0.03, 0.05, 0.7, 0.1);
      samples.add(value * env * 0.4);
    }

    return _generateWavBytes(_reverb(samples, 0.45, 70));
  }

  static Uint8List makeClassicalMilestone() {
    const duration = 0.6;
    final samples = <double>[];
    final notes = [(784.0, 0.0, 0.15), (988.0, 0.15, 0.15), (1175.0, 0.3, 0.3)];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _addHarmonics(freq, localT, 4);
      final env = _adsr(localT, noteLen, 0.01, 0.04, 0.6, 0.08);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_reverb(samples, 0.35, 50));
  }

  static Uint8List makeClassicalPause() => makePause();
  static Uint8List makeClassicalResume() => makeResume();

  static Uint8List makeClassicalClick() {
    const duration = 0.12;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();
    const freq = 1318.0;

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final value = _addHarmonics(freq, t, 4);
      final env = _adsr(t, duration, 0.002, 0.04, 0.2, 0.06);
      samples.add(value * env * 0.25);
    }

    return _generateWavBytes(samples);
  }

  // =============================================
  // ✅ Pack: Arcade
  // =============================================

  static Uint8List makeArcadeJump() {
    const duration = 0.18;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = (200 + 600 * progress).toDouble();
      final value = _square(freq, t);
      final env = _adsr(t, duration, 0.001, 0.03, 0.5, 0.05);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadeDuck() {
    const duration = 0.1;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = (400 - 200 * progress).toDouble();
      final value = _square(freq, t);
      final env = _adsr(t, duration, 0.001, 0.02, 0.4, 0.04);
      samples.add(value * env * 0.28);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadeScore() {
    const duration = 0.2;
    final samples = <double>[];
    final notes = [(988.0, 0.0, 0.05), (1319.0, 0.05, 0.15)];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _square(freq, localT);
      final env = _adsr(localT, noteLen, 0.001, 0.02, 0.6, 0.03);
      samples.add(value * env * 0.25);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadeGameOver() {
    const duration = 0.8;
    final samples = <double>[];
    final notes = [
      (392.0, 0.0, 0.15),
      (330.0, 0.15, 0.15),
      (262.0, 0.3, 0.15),
      (196.0, 0.45, 0.35),
    ];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _square(freq, localT);
      final env = _adsr(localT, noteLen, 0.001, 0.03, 0.7, 0.1);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadeHighScore() {
    const duration = 1.0;
    final samples = <double>[];
    final notes = [
      (523.0, 0.0, 0.08),
      (659.0, 0.08, 0.08),
      (784.0, 0.16, 0.08),
      (1047.0, 0.24, 0.08),
      (1319.0, 0.32, 0.08),
      (1568.0, 0.4, 0.4),
    ];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _square(freq, localT);
      final env = _adsr(localT, noteLen, 0.001, 0.02, 0.7, 0.06);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadeMilestone() {
    const duration = 0.3;
    final samples = <double>[];
    final notes = [(784.0, 0.0, 0.08), (1047.0, 0.1, 0.15)];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _square(freq, localT);
      final env = _adsr(localT, noteLen, 0.001, 0.02, 0.6, 0.04);
      samples.add(value * env * 0.28);
    }

    return _generateWavBytes(samples);
  }

  static Uint8List makeArcadePause() => makePause();
  static Uint8List makeArcadeResume() => makeResume();

  static Uint8List makeArcadeClick() {
    const duration = 0.05;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final value = _square(1500, t);
      final env = _adsr(t, duration, 0.001, 0.01, 0.2, 0.02);
      samples.add(value * env * 0.2);
    }

    return _generateWavBytes(samples);
  }

  // =============================================
  // ✅ Pack: Synth
  // =============================================

  static Uint8List makeSynthJump() {
    const duration = 0.3;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 200 + 800 * progress;
      double value = _sawtooth(freq, t) * 0.7;
      value += _fmSynth(freq, freq * 0.5, 0.5, t) * 0.3;
      final env = _adsr(t, duration, 0.01, 0.08, 0.6, 0.1);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_reverb(_lowpassFilter(samples, 0.7), 0.3, 40));
  }

  static Uint8List makeSynthDuck() {
    const duration = 0.12;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final progress = t / duration;
      final freq = 300 - 150 * progress;
      final value = _sawtooth(freq, t);
      final env = _adsr(t, duration, 0.005, 0.03, 0.5, 0.05);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(_lowpassFilter(samples, 0.6));
  }

  static Uint8List makeSynthScore() {
    const duration = 0.25;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      const freq = 1047.0;
      final value = _sawtooth(freq * 1.01, t) * 0.5 + _sawtooth(freq * 0.99, t) * 0.5;
      final env = _adsr(t, duration, 0.005, 0.1, 0.3, 0.12);
      samples.add(value * env * 0.28);
    }

    return _generateWavBytes(_reverb(samples, 0.35, 50));
  }

  static Uint8List makeSynthGameOver() {
    const duration = 1.0;
    final samples = <double>[];
    final notes = [(440.0, 0.0, 0.4), (349.0, 0.4, 0.3), (262.0, 0.7, 0.3)];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _sawtooth(freq, localT) * 0.5 + _sawtooth(freq * 1.005, localT) * 0.5;
      final env = _adsr(localT, noteLen, 0.02, 0.1, 0.6, 0.15);
      samples.add(value * env * 0.3);
    }

    return _generateWavBytes(_reverb(_lowpassFilter(samples, 0.7), 0.4, 60));
  }

  static Uint8List makeSynthHighScore() {
    const duration = 1.2;
    final samples = <double>[];
    final notes = [
      (523.0, 0.0, 0.15),
      (659.0, 0.15, 0.15),
      (784.0, 0.3, 0.15),
      (1047.0, 0.45, 0.15),
      (1319.0, 0.6, 0.5),
    ];

    final numSamples = (sampleRate * duration).round();
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      (double, double, double)? current;
      for (final note in notes) {
        if (t >= note.$2 && t < note.$2 + note.$3) {
          current = (note.$1, t - note.$2, note.$3);
          break;
        }
      }
      if (current == null) {
        samples.add(0);
        continue;
      }
      final (freq, localT, noteLen) = current;
      final value = _sawtooth(freq, localT) * 0.6 + _sawtooth(freq * 1.01, localT) * 0.4;
      final env = _adsr(localT, noteLen, 0.01, 0.05, 0.6, 0.1);
      samples.add(value * env * 0.35);
    }

    return _generateWavBytes(_reverb(samples, 0.4, 70));
  }

  static Uint8List makeSynthMilestone() => makeArcadeMilestone();
  static Uint8List makeSynthPause() => makePause();
  static Uint8List makeSynthResume() => makeResume();

  static Uint8List makeSynthClick() {
    const duration = 0.06;
    final samples = <double>[];
    final numSamples = (sampleRate * duration).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final value = _sawtooth(2000, t);
      final env = _adsr(t, duration, 0.001, 0.02, 0.15, 0.03);
      samples.add(value * env * 0.22);
    }

    return _generateWavBytes(_highpassFilter(samples, 0.5));
  }

  // =============================================
  // ✅ مولّد عام حسب اسم الـ pack والصوت
  // =============================================

  static Uint8List generate(String pack, String sound) {
    final prefix = pack.replaceFirst('sounds_', '');

    if (prefix == 'classical') {
      switch (sound) {
        case 'jump': return makeClassicalJump();
        case 'duck': return makeClassicalDuck();
        case 'score': return makeClassicalScore();
        case 'game_over': return makeClassicalGameOver();
        case 'new_high_score': return makeClassicalHighScore();
        case 'milestone': return makeClassicalMilestone();
        case 'pause': return makeClassicalPause();
        case 'resume': return makeClassicalResume();
        case 'click': return makeClassicalClick();
      }
    } else if (prefix == 'arcade') {
      switch (sound) {
        case 'jump': return makeArcadeJump();
        case 'duck': return makeArcadeDuck();
        case 'score': return makeArcadeScore();
        case 'game_over': return makeArcadeGameOver();
        case 'new_high_score': return makeArcadeHighScore();
        case 'milestone': return makeArcadeMilestone();
        case 'pause': return makeArcadePause();
        case 'resume': return makeArcadeResume();
        case 'click': return makeArcadeClick();
      }
    } else if (prefix == 'synth') {
      switch (sound) {
        case 'jump': return makeSynthJump();
        case 'duck': return makeSynthDuck();
        case 'score': return makeSynthScore();
        case 'game_over': return makeSynthGameOver();
        case 'new_high_score': return makeSynthHighScore();
        case 'milestone': return makeSynthMilestone();
        case 'pause': return makeSynthPause();
        case 'resume': return makeSynthResume();
        case 'click': return makeSynthClick();
      }
    }

    // ✅ default
    switch (sound) {
      case 'jump': return makeJump();
      case 'duck': return makeDuck();
      case 'score': return makeScore();
      case 'game_over': return makeGameOver();
      case 'new_high_score': return makeNewHighScore();
      case 'milestone': return makeMilestone();
      case 'pause': return makePause();
      case 'resume': return makeResume();
      case 'click': return makeClick();
    }

    return Uint8List(0);
  }
}