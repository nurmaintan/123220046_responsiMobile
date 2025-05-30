import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:responsi_046/models/user.dart';
import 'package:responsi_046/models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movie_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Create users table
    await db.execute('''
    CREATE TABLE users (
      id $idType,
      username $textType,
      password $textType
    )
    ''');

    // Create favorites table
    await db.execute('''
    CREATE TABLE favorites (
      id $textType,
      title $textType,
      releaseDate $textType,
      posterUrl $textType,
      rating $realType,
      genre $textType,
      description $textType,
      director $textType,
      cast $textType,
      isFavorite $intType
    )
    ''');
  }

  // User CRUD operations
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Favorites CRUD operations
  Future<int> toggleFavorite(Movie movie) async {
    final db = await instance.database;

    // Check if the movie is already a favorite
    final existingMovie = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [movie.id],
    );

    if (existingMovie.isNotEmpty) {
      // Delete if it exists
      return await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [movie.id],
      );
    } else {
      // Insert if it doesn't exist
      movie.isFavorite = true;
      return await db.insert('favorites', movie.toMap());
    }
  }

  Future<List<Movie>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query('favorites');
    return result.map((json) => Movie.fromMap(json)).toList();
  }

  Future<bool> isFavorite(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
