import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../api_service.dart';

class AudioUploadScreen extends StatefulWidget {
  const AudioUploadScreen({super.key});

  @override
  State<AudioUploadScreen> createState() => _AudioUploadScreenState();
}

class _AudioUploadScreenState extends State<AudioUploadScreen> {
  File? _selectedFile;
  String _recognizedText = '';
  String _predictedEmoji = '';
  bool _isProcessing = false;
  String _selectedLanguage = 'en-US';

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

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _recognizedText = '';
          _predictedEmoji = '';
        });
        _showToast('Audio file selected: ${result.files.single.name}');
      }
    } catch (e) {
      _showToast('Error selecting file: $e');
    }
  }

  Future<void> _uploadAudio() async {
    if (_selectedFile == null) {
      _showToast('Please select an audio file first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _recognizedText = '';
      _predictedEmoji = '';
    });

    try {
      final result = await ApiService.uploadAudio(_selectedFile!, _selectedLanguage);
      
      setState(() {
        _recognizedText = result['text'] ?? '';
        _predictedEmoji = result['emoji'] ?? '';
      });
      
      _showToast('Audio processed successfully!');
    } catch (e) {
      _showToast('Error processing audio: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedFile = null;
      _recognizedText = '';
      _predictedEmoji = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Audio File'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                      onChanged: (value) {
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
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // File Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.audio_file,
                      size: 60,
                      color: _selectedFile != null ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFile != null 
                          ? 'Selected: ${_selectedFile!.path.split('/').last}'
                          : 'No file selected',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedFile != null ? Colors.blue : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickAudioFile,
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Select Audio File'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_selectedFile != null)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _resetSelection,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Upload Button
            if (_selectedFile != null && !_isProcessing)
              ElevatedButton.icon(
                onPressed: _uploadAudio,
                icon: const Icon(Icons.upload),
                label: const Text('Process Audio File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            
            if (_isProcessing) ...[
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Processing audio file...'),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Results
            if (_recognizedText.isNotEmpty) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Recognition Result:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _predictedEmoji,
                        style: const TextStyle(
                          fontSize: 60,
                          fontFamily: 'Segoe UI Emoji',
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Recognized Text:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          _recognizedText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Language: ${languages[_selectedLanguage]}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (!_isProcessing && _selectedFile == null) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.audio_file_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Select an audio file to see results',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Supported formats: WAV, MP3, M4A',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
    );
  }
}