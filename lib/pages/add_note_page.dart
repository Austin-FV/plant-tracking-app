import 'package:flutter/material.dart';
import 'package:plant_tracker/plant_db.dart';

class AddNotePage extends StatefulWidget {
  final Function() onSaveNote;
  final plant_db database;
  final Plant plant;

  const AddNotePage({Key? key, required this.onSaveNote, required this.database, required this.plant}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _noteTextController = TextEditingController();

  @override
  void dispose() {
    _noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _noteTextController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your note here',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String noteText = _noteTextController.text;
                if (noteText.isNotEmpty) {
                  await widget.database.addNote(widget.plant.plant_name, noteText);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
