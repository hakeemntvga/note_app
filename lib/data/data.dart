import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_app_/data/get_all_notes_resp/get_all_notes_resp.dart';
import 'package:note_app_/data/url.dart';

import 'note_model/note_model.dart';

abstract class ApiCalls {
  Future<NoteModel?> createNote(NoteModel value);
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel?> updateNote(NoteModel value);
  Future<void> deleteNote(String id);
}

class NoteDB extends ApiCalls {
  final dio = Dio();
  final url = Url();

  ////////////////////////   Singlton
  NoteDB._internal() {
    dio.options = BaseOptions(
      baseUrl: url.baseUrl,
      responseType: ResponseType.plain,
    );
  }
  static NoteDB instance = NoteDB._internal();

  NoteDB factory() {
    return instance;
  }
  //////////////////////    Singletone End

  ValueNotifier<List<NoteModel>> noteListNotifier = ValueNotifier([]);

  @override
  Future<NoteModel?> createNote(NoteModel value) async {
    try {
      final _result = await dio.post(
        url.createNote,
        data: value.toJson(),
      );
      final _resultAsJson = jsonDecode(_result.data);
      final note = NoteModel.fromJson(_resultAsJson as Map<String, dynamic>);
      noteListNotifier.value.insert(0, note);
      noteListNotifier.notifyListeners();
      return note;
    } on DioError catch (e) {
      print(e.response?.data);
      print(e);
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
   final _result = await dio.delete(url.deleteNote.replaceFirst('{id}', id));
   if(_result.data == null){
     return;
   }
   final _index = noteListNotifier.value.indexWhere((note) => note.id == id);
   if(_index == -1){
     return ;
   }

   noteListNotifier.value.removeAt(_index);
   noteListNotifier.notifyListeners();
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final _result = await dio.get(url.getAllNote);
    if (_result.data != null) {
      final _resultAsJson = jsonDecode(_result.data);
      final getNoteRes = GetAllNotesResp.fromJson(_resultAsJson);

      noteListNotifier.value.clear();
      noteListNotifier.value.addAll(getNoteRes.data.reversed);
      return getNoteRes.data;
    } else {
      noteListNotifier.value.clear();
      return [];
    }
  }

  @override
  Future<NoteModel?> updateNote(NoteModel value) async {
    final _result = await dio.put(url.updateNote,data: value.toJson());
    if(_result.data == null){
      return null;
    }

    ////find index
    
    final index = noteListNotifier.value.indexWhere((note) => note.id == value.id);
    if(index == -1){
      return null;
    }


    /////Remove from index
    
noteListNotifier.value.removeAt(index);

    /////add note in that index
    

    noteListNotifier.value.insert(index, value);
    noteListNotifier.notifyListeners();
    return value;
  }

  NoteModel? getNoteByID(String id){
    try{
      return noteListNotifier.value.firstWhere((note) => note.id == id);
    }catch (_){
      return null;
    }
  }
}
