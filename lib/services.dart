import 'dart:convert';
import 'package:http/http.dart' as http;

class NoteService {
  static const String baseUrl = "http://192.168.16.113/noteapp";

  static Future<List> getNotes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_notes.php'));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          List notes = responseBody['notes'];

          return notes.map((note) {
            note['id'] = int.parse(note['id'].toString());
            return note;
          }).toList();
        } else {
          print("Failed to load notes: ${responseBody['error']}");
          return [];
        }
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching notes: $e");
      return [];
    }
  }


  static Future<bool> addNote(String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add_note.php'),
        body: {
          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success']) {
          print("Note added successfully");
          return true;
        } else {
          print("Error adding note: ${responseBody['error']}");
          return false;
        }
      } else {
        print("Failed to add note: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error adding note: $e");
      return false;
    }
  }


  static Future<bool> editNote(int id, String title, String content) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/edit_note.php'),
        body: {
          'id': id.toString(),

          'title': title,
          'content': content,
        },
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Edit response: ${responseBody}");
        return responseBody['success'] ?? false;
      } else {
        print("Failed to edit note: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error editing note: $e");
      return false;
    }
  }
  static Future<bool> deleteNoteById(int id) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_note.php'),
        body: {
          'id': id.toString(),

        },
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Delete response: ${responseBody}");
        return responseBody['success'] ?? false;
      } else {
        print("Failed to delete note: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting note: $e");
      return false;
    }
  }
}