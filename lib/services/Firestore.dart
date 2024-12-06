import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Adds a new user to Firestore.
  /// The document ID is the Gmail username (email without "@gmail.com").
  Future<void> addUser(String email, String password) async {
    try {
      // Extract Gmail username (email without "@gmail.com")
      final username = email.split('@')[0];

      // Hash the password for secure storage
      final hashedPassword = hashPassword(password);

      // Save user data to Firestore
      await _db.collection('users').doc(username).set({
        'email': email,
        'password': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'fullname': null, // Placeholder for Fullname
        'description': null,
        'points': null,
        'trophy': null,
        'gender': null,   // Placeholder for Gender
        'birthday': null, // Placeholder for Birthday
      });
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  /// Hashes the password using SHA-256.
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> createGameRoom(String userId) async {
    try {
      final roomRef = await _db.collection('game_rooms').add({
        'hostId': userId,
        'players': [userId],
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
        'gameType': 'versus',
      });
      return roomRef.id;
    } catch (e) {
      print('Error creating game room: $e');
      throw e;
    }
  }

  Future<void> joinGameRoom(String roomId, String userId) async {
    try {
      await _db.collection('game_rooms').doc(roomId)
          .update({
        'players': FieldValue.arrayUnion([userId]),
        'status': 'ready',
      });
    } catch (e) {
      print('Error joining game room: $e');
      throw e;
    }
  }
}
