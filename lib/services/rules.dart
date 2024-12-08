class FirestoreRules {
  static const String rules = r'''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAdmin() {
      return request.auth != null && 
        exists(/databases/$(database)/documents/Admin/Admin123);
    }

    function isUser() {
      return request.auth != null;
    }

    // Allow reading admin document
    match /Admin/Admin123 {
      allow read: if true;
    }

    // Mail collection rules
    match /mail/{messageId} {
      // Helper functions for mail
      function isMessageParticipant() {
        return isUser() && (
          resource.data.recipientId == request.auth.uid ||
          resource.data.senderId == request.auth.uid
        );
      }

      // Read rules
      allow read: if isMessageParticipant();

      // Create rules
      allow create: if isUser();

      // Update rules - simplified to allow recipients to update read status
      allow update: if isUser() && 
        resource.data.recipientId == request.auth.uid;

      // Delete rules
      allow delete: if isMessageParticipant();
    }

    // All other collections
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
''';
} 