import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ListEntriesScreen extends StatefulWidget {
  final String listId;
  final String title;
  final List<Map<String, dynamic>> initialEntries;

  const ListEntriesScreen({
    super.key,
    required this.listId,
    required this.title,
    required this.initialEntries,
  });

  @override
  State<ListEntriesScreen> createState() => _ListEntriesScreenState();
}

class _ListEntriesScreenState extends State<ListEntriesScreen> {
  late List<Map<String, dynamic>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List<Map<String, dynamic>>.from(widget.initialEntries);
  }

  void _saveEntries() {
    Navigator.pop(context, _entries);
  }

  void _syncToServer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Entry changes will sync from home')),
    );
  }

  void _addEntry() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Item name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _entries.add({
                  'id': DateTime.now().toIso8601String(),
                  'text': controller.text.trim(),
                  'checked': false,
                });
              });
              _saveEntries();
              _syncToServer();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editEntry(int index) {
    final controller = TextEditingController(text: _entries[index]['text']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Entry'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Updated item'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _entries[index]['text'] = controller.text.trim();
              });
              _saveEntries();
              _syncToServer();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _entries.removeAt(index);
              });
              _saveEntries();
              _syncToServer();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleCheck(int index) {
    setState(() {
      _entries[index]['checked'] = !_entries[index]['checked'];
    });
    _saveEntries();
    _syncToServer();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, item);
    });
    _saveEntries();
    _syncToServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ReorderableListView.builder(
        itemCount: _entries.length,
        onReorder: _onReorder,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) {
          final item = _entries[index];
          return ListTile(
            key: ValueKey(item['id']),
            leading: Checkbox(
              value: item['checked'],
              onChanged: (_) => _toggleCheck(index),
            ),
            title: Text(
              item['text'],
              style: TextStyle(
                decoration:
                    item['checked'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _editEntry(index);
                if (value == 'delete') _deleteEntry(index);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }
}