import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StudentDbManager {
  Database _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(
        join(await getDatabasesPath(), "student.db"),
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE student(id INTEGER PRIMARY KEY, name TEXT, course TEXT)",
          );
        },
      );
    }
  }

  Future<int> insertStudent(Student student) async {
    await openDb();
    return await _database.insert('student', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    await openDb();

    final List<Map<String, dynamic>> studentMaps =
        await _database.query('student');
    return List.generate(
      studentMaps.length,
      (i) {
        return Student(
          name: studentMaps[i]['name'],
          course: studentMaps[i]['course'],
          id: studentMaps[i]['id'],
        );
      },
    );
  }

  Future<int> updateStudent(Student student) async {
    await openDb();
    return _database.update('student', student.toMap(),
        where: "id = ?", whereArgs: [student.id]);
  }

  Future<void> deleteStudent(int id) async {
    await openDb();
    _database.delete(
      'student',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

class Student {
  int id;
  String name;
  String course;

  Student({
    @required this.name,
    @required this.course,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
    };
  }
}
