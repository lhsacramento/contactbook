import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String contactTableName = 'contactTable';
const String idColumn = 'idColumn';
const String nameColumn = 'nameColumn';
const String emailColumn = 'emailColumn';
const String phoneColumn = 'phoneColumn';
const String imgColumn = 'imgColumn';

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database? _db;
  Future<Database> get db async {
    if(_db == null){
      _db = await initDb();
      return _db!;
    }else{
      return _db!;
    }
  }

  Future<Database> initDb() async{
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "contacts.db");

    return await openDatabase(path,version:1,onCreate:(Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTableName($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTableName, Map<String,dynamic>.from(contact.toMap()));
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTableName,
        columns: [idColumn,nameColumn,emailColumn,phoneColumn,imgColumn],
    where: "$idColumn = ?",whereArgs: [id]);

    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteContact(int id)  async{
    Database dbContact = await db;
    return await dbContact.delete(contactTableName,where: "$idColumn = ?",whereArgs: [id]);
  }

  Future<int> deleteAllContact()  async{
    Database dbContact = await db;
    return await dbContact.delete(contactTableName);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTableName,
                                  Map<String,dynamic>.from(contact.toMap()),
                                  where: "$idColumn = ?",
                                  whereArgs: [contact.id]);
  }
  
  Future<List<Contact>> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTableName");
    List<Contact> listContact = [];

    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int?> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTableName"));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  ContactHelper helper = ContactHelper();

  Contact(this.name,this.email,this.phone,this.img);

  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Future<int?> setId() async {
    int? quant =  await helper.getNumber();
    id = quant;
    id ??= 0;
    return id;
  }

  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      idColumn : id,
      nameColumn : name,
      emailColumn : email,
      phoneColumn : phone,
      imgColumn : img
    };
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }
}