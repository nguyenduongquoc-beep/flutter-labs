import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? note;
  final DateTime createdAt;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.note,
    required this.createdAt,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class CrudServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _contactsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Chua dang nhap');
    return _db.collection('users').doc(uid).collection('contacts');
  }

  Future<void> addContact({
    required String name,
    required String phone,
    required String email,
    String? note,
  }) async {
    await _contactsRef.add({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'note': note?.trim(),
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Stream<List<Contact>> getContactsStream() {
    return _contactsRef
        .orderBy('name')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Contact.fromFirestore(doc)).toList());
  }

  Future<void> updateContact({
    required String id,
    required String name,
    required String phone,
    required String email,
    String? note,
  }) async {
    await _contactsRef.doc(id).update({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'note': note?.trim(),
    });
  }

  Future<void> deleteContact(String id) async {
    await _contactsRef.doc(id).delete();
  }

  Stream<List<Contact>> searchContacts(String query) {
    return getContactsStream().map((contacts) => contacts
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.phone.contains(query) ||
            c.email.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }
}