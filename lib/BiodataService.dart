import 'package:cloud_firestore/cloud_firestore.dart';

class Biodataservice {
  final FirebaseFirestore db;

  const Biodataservice({required this.db});

  // Create Data
  Future<String> add(Map<String, dynamic> data) async {
    final document = await db.collection('biodata').add(data);
    return document.id;
  }

  // Read Data
  Stream<QuerySnapshot<Map<String, dynamic>>> getBiodata() {
    return db.collection('biodata').snapshots();
  }

  //Delete Data By ID
  Future<void> delete(String documentId) async {
    await db.collection('biodata').doc(documentId).delete();
  }

  //Update Data By ID
  Future<void> update(String documentId, Map<String, dynamic> data) async {
    await db.collection('biodata').doc(documentId).update(data);
  }
}
