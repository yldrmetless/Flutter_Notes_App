import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/components/drawer.dart';
import 'package:notes_app/components/note_tile.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/models/notes_database.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageWidget();
}

class _NotesPageWidget extends State<NotesPage> {
  //text controller to access what the user typed
  final textController = TextEditingController();

  //create a note

  @override
  void initState() {
    setState(() {
      super.initState();

      //on app startup, fetch existing notes
      readNotes();
    });
  }

  void createNote() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              //create button
              actions: [
                MaterialButton(
                  onPressed: () {
                    //add to db
                    context.read<NoteDatabase>().addNote(textController.text);

                    //clear controller
                    textController.clear();

                    //pop dialog box
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                )
              ],
            ));
  }

  //read a note
  void readNotes() {
    context.read<NoteDatabase>().fetchNotes();
  }

  //update a note
  void updateNote(Note note) {
    //pre-fill the current note text
    textController.text = note.text;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              content: TextField(controller: textController),
              actions: [
                //update button
                MaterialButton(
                  onPressed: () {
                    //update note in db
                    context
                        .read<NoteDatabase>()
                        .updateNote(note.id, textController.text);
                    //clear controller
                    textController.clear();
                    //pop dialog box
                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                )
              ],
            ));
  }

  //delete a note
  void deleteNote(int id) {
    context.read<NoteDatabase>().deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    //note database
    final noteDatabase = context.watch<NoteDatabase>();

    //current notes
    List<Note> currentNotes = noteDatabase.currentNotes;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        floatingActionButton: FloatingActionButton(
          onPressed: createNote,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        drawer: const MyDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //heading
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 5),
              child: Text(
                "Notes",
                style: GoogleFonts.dmSerifText(
                    fontSize: 36,
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),

            //List of notes
            Expanded(
              child: ListView.builder(
                  itemCount: currentNotes.length - 1,
                  itemBuilder: (context, index) {
                    //get individual note
                    final note = currentNotes[index];

                    //list tile UI
                    return NoteTile(
                      text: note.text,
                      onEditPressed: () => updateNote(note),
                      onDeletePressed: () => deleteNote(note.id),
                    );
                  }),
            ),
          ],
        ));
  }
}
