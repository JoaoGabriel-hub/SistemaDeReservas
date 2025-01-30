import 'dart:io';
import 'package:projetofinal/logged_user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class DataBaseHelper {
  Future<Database> initializedDataBase() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    var path = '${Directory.current.path}/sistema_reservas.db';
    var database = await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(
                '''CREATE TABLE user (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                              name VARCHAR NOT NULL,
                                              email VARCHAR NOT NULL,
                                              password VARCHAR NOT NULL)''');

            await db.execute(
                '''CREATE TABLE address (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                  cep VARCHAR NOT NULL UNIQUE,
                                                  logradouro VARCHAR NOT NULL,
                                                  bairro VARCHAR NOT NULL,
                                                  localidade VARCHAR NOT NULL,
                                                  uf VARCHAR NOT NULL,
                                                  estado VARCHAR NOT NULL)''');

            await db.execute(
                '''CREATE TABLE property (id INTEGER PRIMARY KEY AUTOINCREMENT,
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

            await db.execute(
                '''CREATE TABLE images (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                                property_id INTEGER NOT NULL,
                                                path VARCHAR NOT NULL,    
                                              FOREIGN KEY(property_id) REFERENCES property(id))''');

            await db.execute(
                '''CREATE TABLE booking (id INTEGER PRIMARY KEY AUTOINCREMENT,
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

  Future<bool> insertUser(String name, String email, String password) async {
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
    return true;
  }

  Future<Map<String, dynamic>?> checkCredentials(
      String name, String password) async {
    final db = await initializedDataBase();
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );

    if (maps.isNotEmpty) {
      print('User found');
      return maps.first;
    } else {
      print('User not found');
      return null;
    }
  }

  Future<void> insertProperty(
      String title,
      String description,
      int number,
      String? complement,
      double price,
      int maxGuest,
      String thumbnail,
      String cep) async {
    final db = await initializedDataBase();
    int? userId = LoggedUser().id;
    //Consumir API do cep para obter o endereço completo
    var adressId = await createAdress(cep);
    await db.insert(
      'property',
      {
        'user_id': userId,
        'address_id': adressId,
        'title': title,
        'description': description,
        'number': number,
        'complement': complement,
        'price': price,
        'max_guest': maxGuest,
        'thumbnail': thumbnail,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Property inserted');
  }



  Future<int> createAdress(String cep) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['erro'] != null) {
        throw Exception('CEP não encontrado');
      }

      final db = await initializedDataBase();
      final addressId = await db.insert(
        'address',
        {
          'cep': data['cep'],
          'logradouro': data['logradouro'],
          'bairro': data['bairro'],
          'localidade': data['localidade'],
          'uf': data['uf'],
          'estado': data['estado'], // Assuming 'estado' is the same as 'uf'
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return addressId;
    } else {
      throw Exception('Erro ao buscar o CEP');
    }
    }
  }

