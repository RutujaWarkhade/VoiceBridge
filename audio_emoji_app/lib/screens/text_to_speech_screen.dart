import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../api_service.dart'; // ✅ Correct relative import

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _loading = false;
  AudioPlayer? _audioPlayer;
  File? _audioFile;
  String _lang = 'en'; // Default language

  @override
  void dispose() {
    _textController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _convertTextToSpeech() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text or emoji')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/tts');
      final request = http.MultipartRequest('POST', uri)
        ..fields['text'] = text
        ..fields['lang'] = _lang
        ..headers['api-key'] = ApiService.apiKey;

      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        // Save audio to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/tts_output.mp3');
        await file.writeAsBytes(bytes);
        _audioFile = file;

        // Reuse AudioPlayer
        _audioPlayer ??= AudioPlayer();
        await _audioPlayer!.play(DeviceFileSource(file.path));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate speech: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _stopAudio() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Speech'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter text or emojis...',
              ),
            ),
            const SizedBox(height: 20),
            
            // Language selector
            Row(
              children: [
                const Text('Language: '),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _lang,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                    DropdownMenuItem(value: 'mr', child: Text('Marathi')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _lang = v);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _convertTextToSpeech,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Speak'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _stopAudio,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
