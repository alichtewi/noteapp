import 'package:flutter/material.dart';
import 'services.dart';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  List<dynamic> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await NoteService.getNotes();
    setState(() {
      notes = fetchedNotes;
    });
  }

  void showNoteDialog({Map<String, dynamic>? note}) {
    final titleController = TextEditingController(text: note?['title'] ?? '');
    final contentController = TextEditingController(text: note?['content'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (note == null) {

                  final success = await addNote(titleController.text, contentController.text);
                  if (success) {
                    Navigator.pop(context);
                    fetchNotes();
                  }
                } else {

                  final success = await editNote(note['id'], titleController.text, contentController.text);
                  if (success) {
                    Navigator.pop(context);
                    fetchNotes();
                  }
                }
              },
              child: Text(note == null ? 'Add' : 'Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> addNote(String title, String content) async {
    final success = await NoteService.addNote(title, content);
    if (success) {
      setState(() {

        fetchNotes();
      });
      return true;
    }
    return false;
  }

  Future<bool> editNote(int id, String title, String content) async {
    print("Editing note with ID: $id, Title: $title, Content: $content");  // Debugging
    final success = await NoteService.editNote(id, title, content);
    if (success) {
      setState(() {

        fetchNotes();
      });
      return true;
    } else {
      print("Failed to edit note with ID: $id");
      return false;
    }
  }


  Future<void> deleteNoteConfirmation(int id) async {
    print("Deleting note with ID: $id");
    final success = await NoteService.deleteNoteById(id);
    if (success) {
      setState(() {

        fetchNotes();
      });
    } else {
      print("Failed to delete note with ID: $id");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: notes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title']),
            subtitle: Text(note['content']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => showNoteDialog(note: note),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteNoteConfirmation(note['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
