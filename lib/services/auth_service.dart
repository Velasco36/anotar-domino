// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login con Email y Password
  Future<UserCredential?> loginEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // Registro con Email y Password
  Future<UserCredential?> registerEmail(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Guarda el perfil en Firestore
      await _guardarPerfil(cred.user!, nombre);
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  // Login con Google
  Future<UserCredential?> loginGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final cred = await _auth.signInWithCredential(credential);
      // Si es nuevo usuario, guarda perfil
      if (cred.additionalUserInfo?.isNewUser ?? false) {
        await _guardarPerfil(cred.user!, cred.user!.displayName ?? 'Usuario');
      }
      return cred;
    } catch (e) {
      throw 'Error al iniciar con Google: $e';
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Guardar perfil en Firestore
  Future<void> _guardarPerfil(User user, String nombre) async {
    await _db.collection('users').doc(user.uid).set({
      'nombre': nombre,
      'email': user.email,
      'foto': user.photoURL ?? '',
      'creadoEn': FieldValue.serverTimestamp(),
    });
  }

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil';
      default:
        return 'Error: ${e.message}';
    }
  }
}
