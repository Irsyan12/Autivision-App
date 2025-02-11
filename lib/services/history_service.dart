import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image, String userId) async {
    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef =
          _storage.ref().child('history_images/$userId/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> addToHistory(String imageUrl, String classification,
      double confidence, String userId) async {
    try {
      await _firestore.collection('history').add({
        'imageUrl': imageUrl,
        'classification': classification,
        'confidence': confidence,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to history: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadHistory(
      {required String userId}) async {
    try {
      Query query =
          _firestore.collection('history').where('userId', isEqualTo: userId);
      query = query.orderBy('timestamp', descending: true);

      QuerySnapshot querySnapshot = await query.get();
      final data = querySnapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      return data;
    } catch (e) {
      print('Error loading history: $e');
      rethrow;
    }
  }

  Future<void> deleteHistoryItem(
      String id, String userId, String imageUrl) async {
    try {
      await _firestore.collection('history').doc(id).delete();
      Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print('Error deleting history item: $e');
      rethrow;
    }
  }
}
