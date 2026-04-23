import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //  GET CURRENT USER
  User? get currentUser => _auth.currentUser;

  //  AUTH STATE (important for auto login)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //  LOGIN
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw getErrorMessage(e);
    }
  }

  //  SIGNUP
  Future<User?> signup(String email, String password, String occupation, String experience) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Save profile to Firestore
      if (result.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
          'email': email,
          'occupation': occupation,
          'experience': experience,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      throw getErrorMessage(e);
    }
  }

  //  LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // CLEAN ERROR HANDLING
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'email-already-in-use':
        return "Email already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'weak-password':
        return "Password should be at least 6 characters";
      default:
        return "Authentication failed";
    }
  }
}