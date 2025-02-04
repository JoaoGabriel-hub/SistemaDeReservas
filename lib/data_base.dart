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
      String cep,
      List<String> images) async {
    final db = await initializedDataBase();
    int? userId = LoggedUser().id;
    //Consumir API do cep para obter o endereço completo
    var adressId = await createAdress(cep);
    var propertyId = await db.insert(
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

    for (var image in images) {
      await db.insert(
        'images',
        {
          'property_id': propertyId,
          'path': image,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> createAdress(String cep) async {
    final db = await initializedDataBase();

    final response =
        await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['erro'] != null) {
        throw Exception('CEP não encontrado');
      }

      var isCepInDatabase = await db.query('address',
          where: 'cep = ?', whereArgs: [data['cep']], limit: 1);

      if (isCepInDatabase.isNotEmpty) {
        return isCepInDatabase.first['id'] as int;
      }

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

  Future<List<Map<String, dynamic>>> getUserProperties() async {
    final db = await initializedDataBase();
    int? userId = LoggedUser().id;

    final List<Map<String, dynamic>> properties = await db.query(
      'property',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (properties.isNotEmpty) {
      print('Properties found');
      return properties;
    } else {
      print('No properties found for this user');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllProperties() async {
    final db = await initializedDataBase();
    final List<Map<String, dynamic>> properties = await db.rawQuery('''
    SELECT 
      property.*, 
      address.uf, 
      address.localidade,
      address.bairro
    FROM property
    JOIN address ON property.address_id = address.id
  ''');

    if (properties.isNotEmpty) {
      print('Properties found');
      return properties;
    } else {
      print('No properties found');
      return [];
    }
  }

  Future<void> deleteProperty(int propertyId) async {
    final db = await initializedDataBase();
    await db.delete(
      'property',
      where: 'id = ?',
      whereArgs: [propertyId],
    );
    print('Property deleted');
  }

  Future<void> updateProperty(
      int propertyId,
      String title,
      String description,
      int number,
      String? complement,
      double price,
      int maxGuest,
      String thumbnail) async {
    final db = await initializedDataBase();
    await db.update(
      'property',
      {
        'title': title,
        'description': description,
        'number': number,
        'complement': complement,
        'price': price,
        'max_guest': maxGuest,
        'thumbnail': thumbnail,
      },
      where: 'id = ?',
      whereArgs: [propertyId],
    );
    print('Property updated');
  }


  Future<bool> insertBooking(int propertyId, String checkinDate, String checkoutDate, int guests) async {
    final db = await initializedDataBase();
    int? userId = LoggedUser().id;

    // Verifica se há conflitos de reserva para as datas selecionadas
    final List<Map<String, dynamic>> conflicts = await db.rawQuery(
      '''
      SELECT * FROM booking 
      WHERE property_id = ? 
      AND (
        (checkin_date BETWEEN ? AND ?) OR 
        (checkout_date BETWEEN ? AND ?) OR
        (? BETWEEN checkin_date AND checkout_date) OR
        (? BETWEEN checkin_date AND checkout_date)
      )
      ''',
      [propertyId, checkinDate, checkoutDate, checkinDate, checkoutDate, checkinDate, checkoutDate],
    );

    if (conflicts.isNotEmpty) {
      print('Conflito de reserva encontrado! Escolha outras datas.');
      return false;
    }

    // Obtém o preço da propriedade
    final List<Map<String, dynamic>> property = await db.query(
      'property',
      columns: ['price'],
      where: 'id = ?',
      whereArgs: [propertyId],
      limit: 1,
    );

    if (property.isEmpty) {
      print('Propriedade não encontrada!');
      return false;
    }

    double pricePerNight = property.first['price'] as double;
    int totalDays = DateTime.parse(checkoutDate).difference(DateTime.parse(checkinDate)).inDays;
    double totalPrice = totalDays * pricePerNight;

    // Insere a reserva na tabela
    await db.insert(
      'booking',
      {
        'user_id': userId,
        'property_id': propertyId,
        'checkin_date': checkinDate,
        'checkout_date': checkoutDate,
        'total_days': totalDays,
        'total_price': totalPrice,
        'amount_guest': guests,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Reserva criada com sucesso!');
    return true;
  }

  Future<bool> checkUserBookingConflict(int userId, String checkinDate, String checkoutDate) async {
    final db = await initializedDataBase();

    final List<Map<String, dynamic>> conflicts = await db.rawQuery(
      '''
      SELECT * FROM booking 
      WHERE user_id = ? 
      AND (
        (checkin_date BETWEEN ? AND ?) OR 
        (checkout_date BETWEEN ? AND ?) OR
        (? BETWEEN checkin_date AND checkout_date) OR
        (? BETWEEN checkin_date AND checkout_date)
      )
      ''',
      [userId, checkinDate, checkoutDate, checkinDate, checkoutDate, checkinDate, checkoutDate],
    );

    if (conflicts.isNotEmpty) {
      print('User has booking conflicts for the selected dates.');
      return true;
    } else {
      print('No booking conflicts for the user.');
      return false;
    }
  }

  Future<List<dynamic>> getAvailableProperties(String checkin, String checkout, List<dynamic> properties) async {
    final db = await initializedDataBase();
    List<int> unavailableIds = [];

    for (var property in properties) {
      int propertyId = property['id'];
      final List<Map<String, dynamic>> conflicts = await db.rawQuery(
        '''
        SELECT * FROM booking 
        WHERE property_id = ?
        AND (
          (checkin_date BETWEEN ? AND ?) OR 
          (checkout_date BETWEEN ? AND ?) OR
          (? BETWEEN checkin_date AND checkout_date) OR
          (? BETWEEN checkin_date AND checkout_date)
        )
        ''',
        [propertyId, checkin, checkout, checkin, checkout, checkin, checkout],
      );

      if (conflicts.isNotEmpty) {
        unavailableIds.add(propertyId);
      }
    }

    return properties.where((p) => !unavailableIds.contains(p['id'])).toList();
  }

  Future<List<Map<String, dynamic>>> getBookingsByUser() async {
    final db = await initializedDataBase();
    int? userId = LoggedUser().id;

    final List<Map<String, dynamic>> bookings = await db.rawQuery('''
    SELECT 
      property.title, 
      property.thumbnail,
      booking.checkin_date, 
      booking.checkout_date, 
      booking.total_price
    FROM booking
    JOIN property ON booking.property_id = property.id
    WHERE booking.user_id = ?
    ''', [userId]);

    if (bookings.isNotEmpty) {
      print('Bookings found for user');
      return bookings;
    } else {
      print('No bookings found for this user');
      return [];
    }
  }
}
