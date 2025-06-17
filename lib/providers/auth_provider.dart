import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? get userId => _user?.uid;
  Map<String, dynamic>? _userData;

  AuthProvider() {
    _user = _auth.currentUser;
    if (_user != null) {
      _fetchUserData(_user!.uid);
    }
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        _fetchUserData(_user!.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;

  Future<void> _fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      _userData = userDoc.data() as Map<String, dynamic>?;
      notifyListeners();
    } catch (e) {
      // print(e);
      _userData = null;
    }
  }

  Future<void> _saveLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<void> signUpWithEmail(String email, String password, String username,
      [String? profileImageUrl]) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Save user data to Firestore
      if (_user != null) {
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': email,
          'username': username,
          'profileImageUrl': profileImageUrl ?? '',
          'createdAt': Timestamp.now(),
        });
        _userData = {
          'uid': _user!.uid,
          'email': email,
          'username': username,
          'profileImageUrl': profileImageUrl ?? '',
        };
      }
      await _saveLoginStatus();
      notifyListeners();
    } catch (e) {
      // print(e);
      rethrow; // Throw error to be caught in the UI
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      if (_user != null) {
        await _fetchUserData(_user!.uid);
      }
      await _saveLoginStatus();
      notifyListeners();
    } catch (e) {
      // print(e);
      rethrow; // Throw error to be caught in the UI
    }
  }

  
  Future<void> updateProfileImage(File imageFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();

      await user!.updatePhotoURL(url);
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'profileImageUrl': url});
      _userData?['profileImageUrl'] = url;

      notifyListeners();
    } catch (error) {
      // print('Failed to update profile image: $error');
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${user!.uid}.jpg');

      await ref.delete();
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'profileImageUrl': ''});
      _userData?['profileImageUrl'] = '';

      notifyListeners();
    } catch (error) {
      // print('Failed to delete profile image: $error');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          throw 'Email tidak ditemukan';
        } else {
          throw 'Gagal mengirim tautan reset kata sandi';
        }
      } else {
        // print('Failed to send password reset email: $e');
        throw 'Gagal mengirim tautan reset kata sandi';
      }
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _userData = null;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      notifyListeners();
    } catch (e) {
      // print(e);
      rethrow;
    }
  }
}
