import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'gorjetas.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gorjetas(
            id INTEGER PRIMARY KEY,
            nomeGarcom TEXT,
            valorGorjeta REAL
          )
        ''');
      },
    );
  }

  Future<void> inserirGorjeta(String nomeGarcom, double valorGorjeta) async {
    final db = await database;
    await db.insert(
      'gorjetas',
      {'nomeGarcom': nomeGarcom, 'valorGorjeta': valorGorjeta},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizarGorjeta(String nomeGarcom, double valorGorjeta) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE gorjetas
      SET valorGorjeta = valorGorjeta + ?
      WHERE nomeGarcom = ?
    ''', [valorGorjeta, nomeGarcom]);
  }

  Future<List<Map<String, dynamic>>> listarGorjetas() async {
    final db = await database;
    return await db.query('gorjetas');
  }

  Future<Map<String, dynamic>?> obterGorjetaPorNome(String nomeGarcom) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'gorjetas',
      where: 'nomeGarcom = ?',
      whereArgs: [nomeGarcom],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<void> limparBancoDeDados() async {
    final db = await database;
    await db.delete('gorjetas');
  }
}
