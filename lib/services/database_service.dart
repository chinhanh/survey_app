import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/survey.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'surveys.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE surveys (
          id TEXT PRIMARY KEY,
          area TEXT,
          sunDirection TEXT,
          plantType TEXT,
          need TEXT,
          budget TEXT,
          imagePath TEXT
        )
      ''');
    });
  }

  Future<void> saveSurvey(Survey survey) async {
    final db = await database;
    await db.insert('surveys', survey.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    try {
      await FirebaseFirestore.instance
          .collection('surveys')
          .doc(survey.id)
          .set(survey.toMap());
    } catch (e) {
      print('Error syncing to Firestore: $e');
    }
  }

  Future<List<Survey>> getSurveys() async {
    final db = await database;
    final maps = await db.query('surveys');
    return maps.map((map) => Survey(
          id: map['id'] as String,
          area: map['area'] as String,
          sunDirection: map['sunDirection'] as String,
          plantType: map['plantType'] as String,
          need: map['need'] as String,
          budget: map['budget'] as String,
          imagePath: map['imagePath'] as String?,
        )).toList();
  }
}

