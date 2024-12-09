import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static bool _initialized = false;

  static Future<void> initializeFirestore() async {
    if (_initialized) return;
    
    try {
      // Set Firestore settings before any other Firestore operations
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      _initialized = true;
    } catch (e) {
      print('Error initializing Firestore: $e');
      // Handle initialization error
    }
  }

  static Future<bool> checkUserPermissions(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).get();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return false;
      }
      throw e;
    }
  }
} 