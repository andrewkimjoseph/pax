import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDBHelper {
  static final LocalDBHelper _instance = LocalDBHelper._internal();
  factory LocalDBHelper() => _instance;
  LocalDBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pax_balances.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE balances (
            participantId TEXT NOT NULL,
            tokenId INTEGER NOT NULL,
            amount REAL NOT NULL,
            updatedAt INTEGER NOT NULL,
            PRIMARY KEY (participantId, tokenId)
          )
        ''');
      },
    );
  }

  Future<void> upsertBalance(
    String participantId,
    int tokenId,
    num amount,
  ) async {
    final dbClient = await db;
    await dbClient.insert('balances', {
      'participantId': participantId,
      'tokenId': tokenId,
      'amount': amount,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<int, num>> getBalances(String participantId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'balances',
      where: 'participantId = ?',
      whereArgs: [participantId],
    );
    final Map<int, num> balances = {};
    for (final map in maps) {
      balances[map['tokenId'] as int] = map['amount'] as num;
    }
    return balances;
  }

  Future<void> clearBalances(String participantId) async {
    final dbClient = await db;
    await dbClient.delete(
      'balances',
      where: 'participantId = ?',
      whereArgs: [participantId],
    );
  }
}
