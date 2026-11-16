import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../utils/language_manager.dart';
import '../main.dart';

class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  FlutterTts? _ttsInstance;
  FlutterTts get _tts => _ttsInstance ??= FlutterTts();

  bool isMuted = false;
  bool _initialized = false;

  void _showDebugToast(String message) {
    final ctx = rootScaffoldMessengerKey.currentContext;
    if (ctx != null) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 12)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _initTts() async {
    if (_initialized) return;
    try {
      _initialized = true;
    } catch (e) {
      _showDebugToast("TTS Init Error: $e");
    }
  }

  void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      stop();
    }
  }

  Future<void> speak(String textInEnglish, String textInTelugu) async {
    if (isMuted) return;
    await _initTts();

    final isTelugu = LanguageManager.instance.isTelugu;
    final primaryText = isTelugu ? textInTelugu : textInEnglish;

    try {
      final result = await _tts.speak(primaryText);
      _showDebugToast("TTS Speak Success? ResultCode=$result");
    } catch (e) {
      _showDebugToast("TTS Speak CRASH: $e");
    }
  }

  Future<void> announceCardFound(String headName) async {
    await speak(
      'Rice card found for $headName.',
      'లబ్ధిదారుడు $headName రైస్ కార్డ్ కనుగొనబడింది.',
    );
  }

  Future<void> announceAttendanceMarked(String headName, int riceQuota) async {
    await speak(
      'Attendance marked for $headName. Rice quota $riceQuota kg.',
      '$headName గారి హాజరు విజయవంతంగా నమోదైంది. బియ్యం కోటా $riceQuota కిలోలు.',
    );
  }

  Future<void> announceAlreadyReceived() async {
    await speak(
      'Ration already received for this month.',
      'ఈ నెల రేషన్ ఇప్పటికే పంపిణీ చేయబడింది.',
    );
  }

  Future<void> announceCardNotFound() async {
    await speak(
      'Rice card not found.',
      'రైస్ కార్డ్ కనుగొనబడలేదు.',
    );
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
