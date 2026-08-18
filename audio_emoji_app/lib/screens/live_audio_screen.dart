import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'dart:async';
import '../api_service.dart';
import 'text_prediction_screen.dart';

class LiveAudioScreen extends StatefulWidget {
  const LiveAudioScreen({super.key});

  @override
  State<LiveAudioScreen> createState() => _LiveAudioScreenState();
}

class _LiveAudioScreenState extends State<LiveAudioScreen> {
  bool _isRecording = false;
  String _recognizedText = '';
  String _predictedEmoji = '';
  bool _isProcessing = false;
  String _selectedLanguage = 'en-US';
  final AudioRecorder _audioRecord = AudioRecorder();
  String? _currentRecordingPath;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  final Map<String, String> languages = {
    'en-US': 'English',
    'hi-IN': 'Hindi',
    'mr-IN': 'Marathi',
  };

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    print('Toast: $message');
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _startRecording() async {
    // Check and request microphone permission
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showToast('Microphone permission denied');
      return;
    }

    try {
      setState(() {
        _isRecording = true;
        _recognizedText = '';
        _predictedEmoji = '';
        _recordingDuration = 0;
      });

      // Create temporary file path for recording
      final tempDir = Directory.systemTemp;
      _currentRecordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // OPTIMIZED AUDIO SETTINGS FOR SPEECH RECOGNITION
      final config = RecordConfig(
        encoder: AudioEncoder.wav,           // WAV format - most compatible
        bitRate: 128000,                     // 128 kbps - optimal for speech
        sampleRate: 16000,                   // 16kHz - STANDARD for speech recognition
        numChannels: 1,                      // Mono - better for speech
      );
      
      print('🎙️ Starting recording with settings: 16kHz, 128kbps, Mono, WAV');
      await _audioRecord.start(config, path: _currentRecordingPath!);
      
      // Start timer to show recording duration
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration++;
        });
        
        // Auto-stop after 10 seconds (optimal for sentences)
        if (_recordingDuration >= 10) {
          _stopRecording();
          timer.cancel();
        }
      });
      
      _showToast('Recording started - Speak clearly for 3-5 seconds');
    } catch (e) {
      print('Recording error: $e');
      _showToast('Failed to start recording: $e');
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    
    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      // Wait for recording to properly stop
      await Future.delayed(const Duration(milliseconds: 500));
      
      final String? path = await _audioRecord.stop();
      final String? audioPath = path ?? _currentRecordingPath;
      
      if (audioPath != null && File(audioPath).existsSync()) {
        final file = File(audioPath);
        final stat = await file.stat();
        print('📁 Recorded file size: ${stat.size} bytes');
        print('⏱️ Recording duration: $_recordingDuration seconds');
        print('🗣️ Language: $_selectedLanguage');
        
        // Check if recording is adequate
        if (stat.size > 10000 && _recordingDuration >= 2) {
          await _processRealAudio(audioPath);
        } else {
          _showToast('Recording too short. Speak for 3-5 seconds clearly.');
          setState(() {
            _isProcessing = false;
          });
        }
      } else {
        _showToast('Recording failed - file not found');
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print('Stop recording error: $e');
      _showToast('Error stopping recording: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processRealAudio(String audioPath) async {
    try {
      print('🎵 Processing audio file: $audioPath');
      
      final audioFile = File(audioPath);
      final fileSize = await audioFile.length();
      print('📊 File size: $fileSize bytes');
      
      if (fileSize < 10000) {
        throw Exception('Recorded file is too small');
      }

      print('🚀 Sending to backend with language: $_selectedLanguage');
      
      // Add timeout to prevent hanging
      final result = await ApiService.uploadAudio(audioFile, _selectedLanguage)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw TimeoutException('Backend processing timeout');
      });
      
      setState(() {
        _recognizedText = result['text']?.trim() ?? '';
        _predictedEmoji = result['emoji'] ?? '';
      });

      // Analyze the result
      if (_recognizedText.isEmpty) {
        _showToast('No speech detected. Try speaking louder and clearer.');
      } else {
        final wordCount = _recognizedText.split(' ').length;
        if (wordCount == 1) {
          _showToast('Single word detected: "$_recognizedText"');
        } else {
          _showToast('Success! Recognized ${wordCount} words');
        }
      }
      
    } on TimeoutException catch (e) {
      print('⏰ Timeout error: $e');
      _showToast('Processing timeout. Try speaking shorter sentences.');
    } catch (e) {
      print('💥 Error processing audio: $e');
      
      // Specific error handling
      if (e.toString().contains('400') || e.toString().contains('understand')) {
        _showToast('Audio not understood. Check microphone and speak clearly.');
      } else if (e.toString().contains('timeout')) {
        _showToast('Processing took too long. Try again.');
      } else {
        _showToast('Error: ${e.toString().split(':').last}');
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
      
      _cleanupTempFile();
    }
  }

  Future<void> _cleanupTempFile() async {
    try {
      if (_currentRecordingPath != null && File(_currentRecordingPath!).existsSync()) {
        await File(_currentRecordingPath!).delete();
        print('🧹 Temporary file cleaned up');
      }
    } catch (e) {
      print('Error deleting temp file: $e');
    }
  }

  void _resetRecording() {
    setState(() {
      _recognizedText = '';
      _predictedEmoji = '';
      _isProcessing = false;
      _recordingDuration = 0;
    });
  }

  void _navigateToTextPrediction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextPredictionScreen(
          initialText: _recognizedText,
        ),
      ),
    );
  }

  // Test audio quality by recording a short sample
  Future<void> _testAudioQuality() async {
    _showToast('Testing audio quality...');
    
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showToast('Microphone permission needed for test');
      return;
    }

    try {
      final tempDir = Directory.systemTemp;
      final testPath = '${tempDir.path}/test_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      final config = RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      await _audioRecord.start(config, path: testPath);
      _showToast('Recording test sample...');
      
      await Future.delayed(const Duration(seconds: 2));
      await _audioRecord.stop();
      
      final testFile = File(testPath);
      if (await testFile.exists()) {
        final size = await testFile.length();
        _showToast('Test successful! File size: ${size ~/ 1024}KB');
        await testFile.delete();
      }
    } catch (e) {
      _showToast('Audio test failed: $e');
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecord.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Microphone'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _testAudioQuality,
            icon: const Icon(Icons.audiotrack),
            tooltip: 'Test Audio Quality',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Language:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      items: languages.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: _isRecording ? null : (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '💡 Tip: Speak clearly for 3-5 seconds',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Recording Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          size: 60,
                          color: _isRecording ? Colors.red : Colors.grey,
                        ),
                        if (_isRecording)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _formatDuration(_recordingDuration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isRecording 
                          ? 'Recording... Speak clearly for 3-5 seconds'
                          : _isProcessing 
                              ? 'Processing your speech...' 
                              : 'Tap to start recording',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isRecording ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_isRecording) ...[
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: _recordingDuration / 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Auto-stops in ${10 - _recordingDuration} seconds',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 15),
                    if (!_isRecording && !_isProcessing && _recognizedText.isEmpty)
                      ElevatedButton.icon(
                        onPressed: _startRecording,
                        icon: const Icon(Icons.mic),
                        label: const Text('Start Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    if (_isRecording)
                      ElevatedButton.icon(
                        onPressed: _stopRecording,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Recording'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    if (_isProcessing)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Converting speech to text...'),
                        ],
                      ),
                    if (_recognizedText.isNotEmpty && !_isProcessing)
                      ElevatedButton.icon(
                        onPressed: _resetRecording,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Record Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Audio Tips
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '🎤 Audio Recording Tips:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Speak clearly and at normal pace\n• Hold phone 6-12 inches from mouth\n• Avoid background noise\n• Record for 3-5 seconds\n• Use complete sentences',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Results Section
            if (_recognizedText.isNotEmpty) ...[
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Live Recognition Result:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _predictedEmoji,
                        style: const TextStyle(
                          fontSize: 50,
                          fontFamily: 'Segoe UI Emoji',
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Recognized Text:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: SelectableText(
                          _recognizedText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Language: ${languages[_selectedLanguage]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'Words: ${_recognizedText.split(' ').length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _navigateToTextPrediction,
                        icon: const Icon(Icons.emoji_emotions),
                        label: const Text('Convert to Emoji'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!_isRecording && !_isProcessing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.mic_none, size: 40, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'Start recording to see results here',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Speak clearly for 3-5 seconds',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: _recognizedText.isNotEmpty && !_isProcessing
          ? FloatingActionButton(
              onPressed: _navigateToTextPrediction,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.emoji_emotions),
            )
          : null,
    );
  }
}