import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_pad/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:note_pad/models/note.dart';
import 'dart:async';


class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note ,this.appBarTitle);

  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, this.appBarTitle);
}

class _NoteDetailState extends State<NoteDetail> {

  var _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  _NoteDetailState(this.note, this.appBarTitle);

  static var _priority = ['High', 'Low'];

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.subtitle1;
    TextStyle titleStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      onWillPop: (){
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle, style: TextStyle(color: Colors.white),),
          leading: IconButton(
            icon: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 35.0,),
            onPressed: (){
              moveToLastScreen();
            }),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(
              children: [
                ListTile(
                  title: DropdownButton(
                    items: _priority.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem, style: textStyle),
                      );
                    }).toList(),

                    style: textStyle,

                    value: getPriorityAsString(note.priority),

                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    },
                  ),
                ),

                //Second Element...
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: TextFormField(
                    controller: titleController,
                    validator: (String value){
                      if(value.isEmpty){
                        return "Please write title";
                      }
                    },
                    style: titleStyle,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    enableSuggestions: true,
                    cursorColor: Theme.of(context).primaryColorDark,
                    decoration: InputDecoration(
                      labelText: "Title",
                      alignLabelWithHint: true,
                      labelStyle: titleStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (value) {
                      updateTitle();
                    },
                  ),
                ),

                //Third Element...
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: TextFormField(
                    controller: descriptionController,
                    style: textStyle,
                    keyboardType: TextInputType.multiline,
                    maxLines: 15,
                    cursorColor: Theme.of(context).primaryColorDark,
                    validator: (String value){
                      if(value.isEmpty){
                        return "Please write description";
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: textStyle,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (value) {
                      updateDescription();
                    },
                  ),
                ),

                //Fourth element...
                Padding(
                  padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          //Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.4,
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),

                      SizedBox(width: 5.0,),

                      Expanded(
                        child: RaisedButton(
                          color: Theme
                              .of(context)
                              .primaryColorDark,
                          textColor: Colors.white,
                          //Theme.of(context).primaryColorLight,
                          child: Text(
                            'Save',
                            textScaleFactor: 1.4,
                          ),
                          onPressed: () {
                            setState(() {
                              if(_formKey.currentState.validate()){
                                _save();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void moveToLastScreen(){
    Navigator.pop(context, true);
  }

  //Convert the string priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert the int priority to String priority and display it to user in Dropdown
  String getPriorityAsString(int value){
    String priority;
    switch(value){
      case 1:
        priority = _priority[0]; //High
        break;
      case 2:
        priority = _priority[1]; //Low
        break;
    }
    return priority;
  }

  //Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  //Update the description of Note object
  void updateDescription(){
    note.description = descriptionController.text;
  }

  //Save data to database
  void _save() async{

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if(note.id != null){ //Case 1: Update operation
      result = await helper.updateNote(note);
    }
    else{ //Case 2: Insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){ //Success
      _showAlertDialogue('Status', 'Note Saved Successfully');
    }
    else{ //Failure
      _showAlertDialogue('Status', 'Problem Saving Note');
    }

  }

  void _delete()async{

    moveToLastScreen();

    //Case 1: If user is trying to delete the New Note i.e. he has come to
    // the detail page by passing the FAB of NoteList page.
    if(note.id == null){
      _showAlertDialogue("Status", "No Note was Deleted");
      return;
    }
    //Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if(result != 0){
      _showAlertDialogue('Status', 'Note Deleted Successfully');
    }
    else{
      _showAlertDialogue('Status', 'Error Occurred while Deleting Note');
    }

  }

  void _showAlertDialogue(String title, String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

}
