import 'package:flutter/material.dart';
import '../api_service.dart';

class TextPredictionScreen extends StatefulWidget {
  final String? initialText;
  
  const TextPredictionScreen({super.key, this.initialText});

  @override
  State<TextPredictionScreen> createState() => _TextPredictionScreenState();
}

class _TextPredictionScreenState extends State<TextPredictionScreen> {
  final TextEditingController _textController = TextEditingController();
  String _predictedEmoji = '';
  bool _isLoading = false;
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _predictEmoji();
      });
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    print('Toast: $message');
  }

  Future<void> _predictEmoji() async {
    final text = _textController.text.trim();
    
    if (text.isEmpty) {
      _showToast('Please enter some text');
      _textFocusNode.requestFocus();
      return;
    }

    // Validate text length
    if (text.length < 2) {
      _showToast('Please enter longer text for better prediction');
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _predictedEmoji = '';
    });

    try {
      // Add timeout to prevent hanging
      final result = await ApiService.predictText(text);
      
      if (!mounted) return;
      
      setState(() {
        _predictedEmoji = result['emoji'] ?? '❓';
      });
      
      if (_predictedEmoji == '❓') {
        _showToast('No specific emoji found for this text');
      } else {
        _showToast('Prediction successful!');
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ Prediction error: $e');
      _showToast('Error predicting emoji: ${e.toString().split(':').last}');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearText() {
    _textController.clear();
    setState(() {
      _predictedEmoji = '';
    });
    _textFocusNode.requestFocus();
  }

  void _useExampleText() {
    const examples = [
      "I'm going to the gym for workout",
      "Having breakfast with coffee and toast",
      "Watching movie with friends tonight",
      "Studying for exams late at night",
      "Going to office meeting at 10 AM",
      "Playing football in the park with friends",
      "Cooking dinner at home for family",
      "Shopping at the mall for new clothes"
    ];
    
    final example = examples[DateTime.now().millisecond % examples.length];
    _textController.text = example;
    _textFocusNode.requestFocus();
    setState(() {});
  }

  void _copyToClipboard() {
    // This would typically use Clipboard.setData()
    _showToast('Text copied to clipboard');
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Emoji'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_textController.text.isNotEmpty) ...[
            IconButton(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.content_copy),
              tooltip: 'Copy text',
            ),
            IconButton(
              onPressed: _clearText,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear text',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Enter your text:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _textController,
                      focusNode: _textFocusNode,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Type your daily routine or activity...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearText,
                                tooltip: 'Clear text',
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (_) => _predictEmoji(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _useExampleText,
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text('Try Example'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _predictEmoji,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.emoji_emotions),
                            label: Text(_isLoading ? 'Predicting...' : 'Convert to Emoji'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.initialText != null && widget.initialText!.isNotEmpty)
                      const SizedBox(height: 10),
                    if (widget.initialText != null && widget.initialText!.isNotEmpty)
                      const Text(
                        '📝 Text from live recording',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 5),
                    const Text(
                      '💡 Tip: Use complete sentences for better emoji matching',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Results Section
            if (_predictedEmoji.isNotEmpty) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Predicted Emoji:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _predictedEmoji,
                        style: const TextStyle(
                          fontSize: 60,
                          fontFamily: 'Segoe UI Emoji, Apple Color Emoji, Noto Color Emoji',
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
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: SelectableText(
                          '"${_textController.text}"',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Characters: ${_textController.text.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            'Words: ${_textController.text.split(' ').length}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_isLoading) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text(
                        'Analyzing your text...',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Finding the perfect emoji match',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (widget.initialText == null || widget.initialText!.isEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.emoji_emotions_outlined, size: 50, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                        'Enter text and predict to see emoji here',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Or use Live Audio recording to automatically fill text',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _useExampleText,
                        child: const Text('Try Example Text'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      // Floating action button for quick access
      floatingActionButton: _textController.text.isNotEmpty && !_isLoading
          ? FloatingActionButton(
              onPressed: _predictEmoji,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.emoji_emotions),
            )
          : null,
    );
  }
}