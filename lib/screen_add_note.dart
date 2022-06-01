import 'package:flutter/material.dart';
import 'package:note_app_/data/data.dart';
import 'package:note_app_/data/note_model/note_model.dart';

enum ActionType {
  addNote,
  editNote,
}

class ScreenAddNote extends StatelessWidget {
  final ActionType type;
  String? id;
  ScreenAddNote({
    Key? key,
    required this.type,
    this.id,
  }) : super(key: key);

  Widget get saveButton => TextButton.icon(
        onPressed: () {
          switch (type) {
            case ActionType.addNote:
/////////////////////Add Note
              saveNote();

              break;
            case ActionType.editNote:
              saveEditedNote();
              //////////Edit Note
              break;
          }
        },
        icon: const Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: const Text(
          "Save",
          style: TextStyle(color: Colors.white),
        ),
      );

  final _titleController = TextEditingController();
  final _contantController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (type == ActionType.editNote) {
      if (id == null) {
        Navigator.of(context).pop();
      }

      final note = NoteDB.instance.getNoteByID(id!);
      if (note == null) {
        Navigator.of(context).pop();
      }

      _titleController.text = note!.title ?? "No Title";
      _contantController.text = note.content ?? "No Content";
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(type.name.toUpperCase()),
        actions: [
          saveButton,
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextFormField(
              controller: _contantController,
              maxLines: 4,
              maxLength: 100,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Content"),
            ),
          ],
        ),
      )),
    );
  }

  Future<void> saveNote() async {
    final title = _titleController.text;
    final content = _contantController.text;

    final _newNote = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
    );

    final newNote = await NoteDB.instance.createNote(_newNote);
    if (newNote != null) {
      print('Note Saved');
      Navigator.of(_scaffoldKey.currentContext!).pop();
    } else {
      print('Error While Saving Note');
    }
  }

  Future<void> saveEditedNote() async {
    final _title = _titleController.text;
    final _content = _contantController.text;

    final editedNote = NoteModel.create(
      id: id,
      title: _title,
      content: _content,
    );
    final _note = await NoteDB.instance.updateNote(editedNote);
    if (_note == null) {
      print("Unable to Update note");
    } else {
      Navigator.of(_scaffoldKey.currentContext!).pop();
    }
  }
}
