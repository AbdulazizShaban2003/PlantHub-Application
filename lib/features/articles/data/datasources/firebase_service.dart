import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/plant_repo.dart';

class FirebaseService{
  final CollectionReference<Map<String, dynamic>> _plantsCollection;

  FirebaseService({
    FirebaseFirestore? firestore,
  })  : _plantsCollection = (firestore ?? FirebaseFirestore.instance).collection('Plants');
  Future<String> addPlant(Map<String, dynamic> plantData) async {
    try {
      final docRef = await _plantsCollection.add(plantData);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to add plant',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<void> updatePlant(String id, Map<String, dynamic> updates) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }
      await _plantsCollection.doc(id).update(updates);
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to update plant with ID: $id',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }

  Future<void> deletePlant(String id) async {
    try {
      if (id.isEmpty) {
        throw RepositoryException('Plant ID cannot be empty');
      }
      await _plantsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw RepositoryException(
        'Failed to delete plant with ID: $id',
        code: e.code,
        stackTrace: e.stackTrace,
      );
    }
  }
}