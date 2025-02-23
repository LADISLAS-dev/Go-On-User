import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Instances de Firestore et FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Méthode pour s'inscrire
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "An error occurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Création de l'utilisateur
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Ajout des données utilisateur dans Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'uid': credential.user!.uid,
          'createdAt': Timestamp.now(),
        });

        res = 'Successfully registered';
      } else {
        res = "Please fill in all fields";
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase spécifiques
      switch (e.code) {
        case 'weak-password':
          res = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          res = "The account already exists for that email.";
          break;
        default:
          res = e.message ?? "An unknown error occurred";
      }
    } catch (e) {
      res = "An error occurred: ${e.toString()}";
    }

    return res;
  }

  // Méthode pour se connecter (login)
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "An error occurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Connexion utilisateur
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          res = "Success"; // Modifier ici pour correspondre à la vérification
        } else {
          res = "Authentication failed";
        }
      } else {
        res = "Please fill in all fields";
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase spécifiques
      switch (e.code) {
        case 'user-not-found':
          res = "No user found for that email.";
          break;
        case 'wrong-password':
          res = "Incorrect password provided.";
          break;
        case 'invalid-email':
          res = "The email address is badly formatted.";
          break;
        default:
          res = e.message ?? "An unknown error occurred";
      }
    } catch (e) {
      res = "An error occurred: ${e.toString()}";
    }

    return res;
  }

  // Méthode pour déconnecter l'utilisateur
  Future<String> signOut() async {
    String res = "An error occurred";

    try {
      await _auth.signOut();
      res = "Successfully logged out";
    } catch (e) {
      res = "An error occurred while logging out: ${e.toString()}";
    }

    return res;
  }

  // Méthode pour récupérer l'utilisateur actuellement connecté
  User? get currentUser {
    return _auth.currentUser;
  }

  // Méthode pour réinitialiser le mot de passe
  Future<String> resetPassword(String email) async {
    String res = "An error occurred";

    try {
      if (email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        res = "Password reset email sent";
      } else {
        res = "Please provide an email address";
      }
    } catch (e) {
      res = "An error occurred: ${e.toString()}";
    }

    return res;
  }
}
