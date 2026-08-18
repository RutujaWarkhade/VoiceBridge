import 'package:flutter/material.dart';
import 'text_prediction_screen.dart';
import 'audio_upload_screen.dart';
import 'history_screen.dart';
import 'live_audio_screen.dart';
import 'text_to_speech_screen.dart'; // <-- Added for TTS

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio to Emoji App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.emoji_emotions, size: 50, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      'Audio to Emoji Converter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Convert your speech to emojis instantly',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Feature Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.text_fields,
                    'Text to Emoji',
                    'Convert text to emoji',
                    Colors.green,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TextPredictionScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.upload_file,
                    'Upload Audio',
                    'Upload audio file',
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AudioUploadScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.mic,
                    'Live Microphone',
                    'Real-time speech to emoji',
                    Colors.red,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LiveAudioScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.record_voice_over,
                    'Text to Speech',
                    'Convert text/emojis to voice',
                    Colors.indigo,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TextToSpeechScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.history,
                    'History',
                    'View prediction history',
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HistoryScreen()),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.info,
                    'About',
                    'About this app',
                    Colors.teal,
                    () {
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Audio to Emoji App\n\n'
          'Convert your speech or text to emojis using AI. '
          'Supports multiple languages and audio formats.\n\n'
          'Features:\n'
          '• Text to Emoji\n'
          '• Audio File Upload\n'
          '• Live Microphone Recording\n'
          '• Text to Speech (TTS)\n'
          '• Prediction History',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
