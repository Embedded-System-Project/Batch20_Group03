import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  void init() {
    Firebase.initializeApp();
  }

  create(collectionName, data, docId) {
    try {
      _firestore.collection(collectionName).doc(docId).set(data);
    } catch (e) {
      log("Error occured in creating data: $e");
    }
  }

  update(collectionName, docId, data) {
    try {
      _firestore.collection(collectionName).doc(docId).update(data);
    } catch (e) {
      log("Error occured in updating data: $e");
    }
  }

  delete(collectionName, docId) {
    try {
      _firestore.collection(collectionName).doc(docId).delete();
    } catch (e) {
      log("Error occured in deleting data: $e");
    }
  }

  read(collectionName, docId) async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      final docs = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      for (var doc in docs) {
      }
      return docs.firstWhere((doc) => doc['id'] == docId);
    } catch (e) {
      log("Error occured in reading data: $e");
    }
  }
}
