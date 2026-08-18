import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> _historyItems = [
    {
      'text': "Going to gym for workout",
      'emoji': "💪",
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'type': "text",
    },
    {
      'text': "Having breakfast with coffee",
      'emoji': "☕🍳",
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'type': "text",
    },
    {
      'text': "Watching movie with friends",
      'emoji': "🎬🍿",
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'type': "audio",
    },
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    print('Toast: $message');
  }

  void _clearHistory() {
    setState(() {
      _historyItems.clear();
    });
    _showToast('History cleared');
  }

  void _addSampleData() {
    setState(() {
      _historyItems.addAll([
        {
          'text': "Reading a book before bed",
          'emoji': "📚🌙",
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'type': "text",
        },
        {
          'text': "Cooking dinner at home",
          'emoji': "🍳🍽️",
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'type': "audio",
        },
      ]);
    });
    _showToast('Sample data added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear History',
            ),
          IconButton(
            onPressed: _addSampleData,
            icon: const Icon(Icons.add),
            tooltip: 'Add Sample Data',
          ),
        ],
      ),
      body: _historyItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'No history yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your predictions will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addSampleData,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Sample Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _historyItems.length,
              itemBuilder: (context, index) {
                final item = _historyItems[index];
                final text = item['text'] as String;
                final emoji = item['emoji'] as String;
                final timestamp = item['timestamp'] as DateTime;
                final type = item['type'] as String;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    title: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              type == "audio" 
                                  ? Icons.mic 
                                  : Icons.text_fields,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type == "audio" ? "Audio" : "Text",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeAgo(timestamp),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.content_copy, size: 20),
                      onPressed: () {
                        _showToast('Copied: $text');
                      },
                      tooltip: 'Copy text',
                    ),
                    onTap: () {
                      _showToast('Text: $text\nEmoji: $emoji');
                    },
                  ),
                );
              },
            ),
      floatingActionButton: _historyItems.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _addSampleData,
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}