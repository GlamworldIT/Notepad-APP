import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:note_pad/models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper; //Singleton DatabaseHelper
  static Database _database; //Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance();   //Named Constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance();   //This executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> initializeDatabase() async {
    //Get the directory path for both android and ios store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    //Once create the database at a given path
    var noteDatabase = await openDatabase(path, version: 1, onCreate: _createDB);
    return noteDatabase;
  }

  Future<Database> get database async{
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  void _createDB(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }


  //Fetch Operation
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    //Alternative Query...
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }


  //Insert Operation
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }


  //Update Operation
  Future<int> updateNote(Note note) async{
    //var db = await this.database;
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }


  //Delete Operation
  Future<int> deleteNote(int id) async{
    //var db = await this.database;
    Database db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }


  //Get number of note object in database
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  //get the "Map List' [List<Map>] and convert it to 'Note List' [List<Note>]
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for(int i=0; i<count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
