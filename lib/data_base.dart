import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class DataBaseHelper {
  
  Future<Database> initializedDataBase() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var path = '${Directory.current.path}/sistema_reservas.db';
    var database = await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE user (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                              name VARCHAR NOT NULL,
                                              email VARCHAR NOT NULL,
                                              password VARCHAR NOT NULL)''');

        await db.execute('''CREATE TABLE address (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                  cep VARCHAR NOT NULL UNIQUE,
                                                  logradouro VARCHAR NOT NULL,
                                                  bairro VARCHAR NOT NULL,
                                                  localidade VARCHAR NOT NULL,
                                                  uf VARCHAR NOT NULL,
                                                  estado VARCHAR NOT NULL)''');

        await db.execute('''CREATE TABLE property (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                  user_id INTEGER NOT NULL,
                                                address_id INTEGER NOT NULL,
                                                  title VARCHAR NOT NULL,
                                                  description VARCHAR NOT NULL,
                                                number INTEGER NOT NULL,
                                                  complement VARCHAR,
                                                  price REAL NOT NULL,
                                                  max_guest INTEGER NOT NULL,
                                                  thumbnail VARCHAR NOT NULL,
                                                  FOREIGN KEY(user_id) REFERENCES user(id),
                                                FOREIGN KEY(address_id) REFERENCES address(id))''');

        await db.execute('''CREATE TABLE images (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                property_id INTEGER NOT NULL,
                                                path VARCHAR NOT NULL,    
                                              FOREIGN KEY(property_id) REFERENCES property(id))''');
                                              
        await db.execute('''CREATE TABLE booking (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                user_id INTEGER NOT NULL,
                                                property_id INTEGER NOT NULL,
                                                  checkin_date VARCHAR NOT NULL,
                                                checkout_date VARCHAR NOT NULL,
                                                  total_days INTEGER NOT NULL,
                                                  total_price REAL NOT NULL,
                                                  amount_guest INTEGER NOT NULL,
                                                  rating REAL,
                                                FOREIGN KEY(user_id) REFERENCES user(id),
                                                FOREIGN KEY(property_id) REFERENCES property(id))''');
      },
    ));

    print('Database initialized');
    return database;
  }

  Future<void> insertUser(String name, String email, String password) async {
    final db = await initializedDataBase();
    await db.insert(
      'user',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('User inserted');
  }


}
