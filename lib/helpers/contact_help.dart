// ignore_for_file: unnecessary_null_comparison

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Declarar tabela para armazenamento dos dados do contato com Sqflite

const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";

// Classe com apenas 1 objeto
class ContactHelper {
  // Declarando o objeto com apenas uma instancia de
  // Construtor interno
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // Declarando o BD

  Database? _db;

  // Inicializando o BD
  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      {
        return _db!;
      }
    }
  }

  // Função initDb
  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

// Função para salvar o contato
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  // Função para obter os dados do contato, pelo id por ser único
  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //Função para deletar um contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //Função para atualizar um contato
  Future<int?> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //Função para obter todos os contatos
  getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //Função para obter um número de contatos de uma lista
  Future<int?> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //Função para fechar o BD
  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

// Classe para armazenamento dos dados do contato Objeto Contact
class Contact {
  // atributos do objeto contact
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

// Contrutor do contact que recebe um Map
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

// Transformando os dados em um Map
// id gerado pelo BD
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    // O Id precisa ser diferente de nulo para ser armazenado
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  // Retornando os dados como String
  @override
  String toString() {
    // Retornando os dados do contato de forma simplificada
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
