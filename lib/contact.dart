import 'dart:convert';
import 'package:xml/xml.dart';

class Contact {
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool friend;

  const Contact({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.friend,
  });
}

abstract class IContactsAdapter {
  List<Contact> getContacts();
}

abstract class AdapterFactory {
  static IContactsAdapter getContactsAdapter({required int adapterType}) {
    switch (adapterType) {
      case 0:
        return XmlContactsAdapter();
      case 1:
        return JsonContactsAdapter();
      case 2:
        return CSVContactsAdapter();
      default:
        throw Exception('Invalid adapter type');
    }
  }
}

class XmlContactsAdapter implements IContactsAdapter {
  final XmlContactsReader _reader = XmlContactsReader();

  @override
  List<Contact> getContacts() {
    final contactsXml = _reader.getContactsXml();
    final contactsList = _parseContactsXml(contactsXml);

    return contactsList;
  }

  List<Contact> _parseContactsXml(String contactsXml) {
    final xmlDocument = XmlDocument.parse(contactsXml);
    final contactsList = <Contact>[];

    for (final xmlElement in xmlDocument.findAllElements('contact')) {
      final fullName = xmlElement.findElements('fullname').single.text;
      final email = xmlElement.findElements('email').single.text;
      final favouriteString = xmlElement.findElements('friend').single.text;
      final friend = favouriteString.toLowerCase() == 'true';
      final phoneNumber = xmlElement.findElements('phoneNumber').single.text;

      contactsList.add(
        Contact(
          fullName: fullName,
          email: email,
          friend: friend,
          phoneNumber: phoneNumber,
        ),
      );
    }

    return contactsList;
  }
}

class CSVContactsAdapter implements IContactsAdapter {
  final CsvContactsReader _reader = CsvContactsReader();

  @override
  List<Contact> getContacts() {
    final contactsCsv = _reader.getContactsCsv();
    final contactsList = _parseContactsCsv(contactsCsv);
    return contactsList;
  }

  List<Contact> _parseContactsCsv(String contactsCsv) {
    final lines = LineSplitter.split(contactsCsv).toList();
    final contactsList = <Contact>[];

    // Skip the header line
    for (var i = 1; i < lines.length; i++) {
      final fields = lines[i].split(',');

      final fullName = fields[0].replaceAll('"', ''); // Remove quotes
      final email = fields[1].replaceAll('"', ''); // Remove quotes
      final friend = fields[2].toLowerCase() == 'true';
      final phoneNumber = fields[3];

      contactsList.add(
        Contact(
          fullName: fullName,
          email: email,
          friend: friend,
          phoneNumber: phoneNumber,
        ),
      );
    }

    return contactsList;
  }
}

class JsonContactsAdapter implements IContactsAdapter {
  final JsonContactsReader _reader = JsonContactsReader();

  @override
  List<Contact> getContacts() {
    final contactsJson = _reader.getContactsJson();
    final contactsList = _parseContactsJson(contactsJson);

    return contactsList;
  }

  List<Contact> _parseContactsJson(String contactsJson) {
    final contactsMap = json.decode(contactsJson) as Map<String, dynamic>;
    final contactsJsonList = contactsMap['contacts'] as List;
    final contactsList = contactsJsonList.map((json) {
      final contactJson = json as Map<String, dynamic>;

      return Contact(
        fullName: contactJson['fullName'] as String,
        email: contactJson['email'] as String,
        friend: contactJson['friend'] as bool,
        phoneNumber: contactJson['phoneNumber'] as String,
      );
    }).toList();

    return contactsList;
  }
}

class XmlContactsReader {
  final String _contactsXml = '''
  <?xml version="1.0"?>
  <contacts>
    <contact>
      <fullname>John Smith (XML)</fullname>
      <email>johns@xml.com</email>
      <friend>false</friend>
      <phoneNumber>999-999-9999</phoneNumber>
    </contact>
    <contact>
      <fullname>Elizabeth Smith (XML)</fullname>
      <email>elisabeths@xml.com</email>
      <friend>true</friend>
      <phoneNumber>999-999-9990</phoneNumber>
    </contact>
    <contact>
      <fullname>Sebastian Smith (XML)</fullname>
      <email>sebastians@xml.com</email>
      <friend>true</friend>
      <phoneNumber>999-999-8880</phoneNumber>
    </contact>
  </contacts>
  ''';

  String getContactsXml() {
    return _contactsXml;
  }
}

class CsvContactsReader {
  final String _contactsCsv = '''
  fullname,email,friend,phoneNumber
  "John Smith (CSV)","johns@csv.com",false,999-999-9999
  "Elizabeth Smith (CSV)","elisabeths@csv.com",true,999-999-9990
  "Sebastian Smith (CSV)","sebastians@csv.com",true,999-999-8880
''';

  String getContactsCsv() {
    return _contactsCsv;
  }
}

class JsonContactsReader {
  final String _contactsJson = '''
  {
    "contacts": [
      {
        "fullName": "John Smith (JSON)",
        "email": "johns@json.com",
        "friend": false,
        "phoneNumber": "999-999-9999"
      },
      {
        "fullName": "Elizabeth Smith (JSON)",
        "email": "elizabeths@json.com",
        "friend": true,
        "phoneNumber": "999-999-9990"
      },
      {
        "fullName": "Sebastian Smith (JSON)",
        "email": "sebastians@json.com",
        "friend": true,
        "phoneNumber": "999-999-8880"
      }
    ]
  }
  ''';

  String getContactsJson() {
    return _contactsJson;
  }
}
