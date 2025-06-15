import 'package:firebase_auth/firebase_auth.dart';  
import 'package:google_sign_in/google_sign_in.dart';  
import 'package:flutter/material.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
  
class AuthProvider extends ChangeNotifier {  
  final FirebaseAuth _auth = FirebaseAuth.instance;  
  final GoogleSignIn _googleSignIn = GoogleSignIn();  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  

  bool _isLoading = false;  
  bool _isGoogleLoading = false;  
  String? _errorMessage;  
    
  // Getters para el estado de registro  
  bool get isLoading => _isLoading;  
  bool get isGoogleLoading => _isGoogleLoading;  
  String? get errorMessage => _errorMessage;  
  
  User? get currentUser => _auth.currentUser;  
  bool get isAuthenticated => currentUser != null;  
  
  // Registro con email/contraseña y guardado en Firestore  
  Future<UserCredential?> signUpWithEmail(        
    String email,         
    String password,         
    String fullName,      
    String username,      
  ) async {        
    try {        
      // Crear usuario PRIMERO  
      final userCredential = await _auth.createUserWithEmailAndPassword(        
        email: email,        
        password: password,        
      );        
        
      if (userCredential.user != null) {        
        try {  
          // AHORA verificar duplicados (usuario ya autenticado)  
          final usernameQuery = await _firestore      
              .collection('ClienteNativo')      
              .where('username', isEqualTo: username)      
              .get();      
                
          if (usernameQuery.docs.isNotEmpty) {      
            await userCredential.user!.delete();  
            throw Exception('El nombre de usuario ya está en uso');      
          }  
            
          // Continuar con el guardado...  
          await userCredential.user!.updateDisplayName(fullName);        
            
          await _firestore.collection('ClienteNativo').doc(userCredential.user!.uid).set({        
            'uid': userCredential.user!.uid,        
            'nombreCompleto': fullName,      
            'username': username,      
            'email': email,        
            'fechaCreacion': FieldValue.serverTimestamp(),        
            'tipoAuth': 'email',        
          });        
            
          print('Usuario guardado en Firestore exitosamente');    
        } catch (firestoreError) {      
          print('Error guardando en Firestore: $firestoreError');      
          await userCredential.user!.delete();      
          throw Exception('Error al guardar datos del usuario: $firestoreError');      
        }      
      }        
        
      return userCredential;        
    } catch (e) {        
      print('Error en signUpWithEmail: $e');    
      rethrow;        
    }        
  }
  // Login con email/contraseña    
  Future<UserCredential?> signInWithEmail(String email, String password) async {    
    try {    
      final userCredential = await _auth.signInWithEmailAndPassword(    
        email: email,    
        password: password,    
      );    
      if (userCredential.user == null) {    
        throw Exception('Usuario no encontrado');    
      }
      return userCredential;    
    } on FirebaseAuthException catch (e) {    
      rethrow;    
    } catch (e) {    
      throw Exception('Error de conexión: $e');    
    }    
  }
  // Login con email(Username)/contraseña  
  Future<UserCredential?> signInWithUsername(String username, String password) async {  
    try {  
      // Buscar el email asociado al username en Firestore  
      final querySnapshot = await _firestore  
          .collection('ClienteNativo')  
          .where('username', isEqualTo: username)  
          .limit(1)  
          .get();  
    
      if (querySnapshot.docs.isEmpty) {  
        throw Exception('Usuario no encontrado');  
      }  
    
      final userDoc = querySnapshot.docs.first;  
      final email = userDoc.data()['email'] as String;  
    
      // Usar el email encontrado para hacer login  
      return await signInWithEmail(email, password);  
    } catch (e) {  
      rethrow;  
    }  
  }
  
  // Login con Google y guardado en Firestore  
  Future<UserCredential?> signInWithGoogle() async {  
    try {  
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();  
      if (googleUser == null) return null;  
  
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;  
      final credential = GoogleAuthProvider.credential(  
        accessToken: googleAuth.accessToken,  
        idToken: googleAuth.idToken,  
      );  
  
      final userCredential = await _auth.signInWithCredential(credential);  
  
      if (userCredential.user != null) {  
        // Verificar si es la primera vez que se loguea con Google  
        final docSnapshot = await _firestore  
            .collection('ClienteGoogle')  
            .doc(userCredential.user!.uid)  
            .get();  
  
        if (!docSnapshot.exists) {  
          // Primera vez - guardar en Firestore  
          await _firestore.collection('ClienteGoogle').doc(userCredential.user!.uid).set({  
            'uid': userCredential.user!.uid,  
            'nombreCompleto': userCredential.user!.displayName ?? 'Usuario Google',  
            'email': userCredential.user!.email ?? '',   
            'fechaCreacion': FieldValue.serverTimestamp(),  
            'tipoAuth': 'google',  
          });  
        }  
      }  
  
      return userCredential;  
    } catch (e) {  
      rethrow;  
    }  
  }  
  
  // Obtener datos del usuario desde Firestore  
  Future<Map<String, dynamic>?> getUserData() async {  
    if (currentUser == null) return null;  
  
    try {  
      // Primero buscar en ClienteNativo  
      var docSnapshot = await _firestore  
          .collection('ClienteNativo')  
          .doc(currentUser!.uid)  
          .get();  
  
      if (docSnapshot.exists) {  
        return {  
          ...docSnapshot.data()!,  
          'tipoCliente': 'ClienteNativo',  
        };  
      }  
  
      // Si no está, buscar en ClienteGoogle  
      docSnapshot = await _firestore  
          .collection('ClienteGoogle')  
          .doc(currentUser!.uid)  
          .get();  
  
      if (docSnapshot.exists) {  
        return {  
          ...docSnapshot.data()!,  
          'tipoCliente': 'ClienteGoogle',  
        };  
      }  
  
      return null;  
    } catch (e) {  
      print('Error obteniendo datos del usuario: $e');  
      return null;  
    }  
  }  


// Métodos privados para manejar el estado  
  void _setLoading(bool value) {  
    _isLoading = value;  
    notifyListeners();  
  }  
    
  void _setGoogleLoading(bool value) {  
    _isGoogleLoading = value;  
    notifyListeners();  
  }  
    
  void _setError(String? error) {  
    _errorMessage = error;  
    notifyListeners();  
  }  
    
  void clearError() {  
    _errorMessage = null;  
    notifyListeners();  
  }  
  // Método para registrar usuario con email (con manejo de estado)  
  Future<UserCredential?> registerWithEmail({  
    required String email,  
    required String password,  
    required String fullName,  
    required String username,  
  }) async {  
    _setLoading(true);  
    _setError(null);  

    try {  
      final result = await signUpWithEmail(  
        email,  
        password,  
        fullName,  
        username,  
      );  
      return result;  
    } on FirebaseAuthException catch (e) {  
      String errorMessage;  
      switch (e.code) {  
        case 'email-already-in-use':  
          errorMessage = 'Este correo ya está registrado';  
          break;  
        case 'weak-password':  
          errorMessage = 'La contraseña es muy débil';  
          break;  
        case 'invalid-email':  
          errorMessage = 'El correo no es válido';  
          break;  
        case 'operation-not-allowed':  
          errorMessage = 'Operación no permitida';  
          break;  
        default:  
          errorMessage = 'Error de autenticación: ${e.message}';  
      }  
      _setError(errorMessage);  
      return null;  
    } catch (e) {  
      _setError('Error: ${e.toString()}');  
      return null;  
    } finally {  
      _setLoading(false);  
    }  
  }  

  // Método para registrar con Google (con manejo de estado)  
  Future<UserCredential?> registerWithGoogle() async {  
    _setGoogleLoading(true);  
    _setError(null);  

    try {  
      final result = await signInWithGoogle();  
      return result;  
    } catch (e) {  
      _setError('Error: ${e.toString()}');  
      return null;  
    } finally {  
      _setGoogleLoading(false);  
    }  
  }
  // Logout  
  Future<void> signOut() async {  
    await _auth.signOut();  
    await _googleSignIn.signOut();  
    notifyListeners();  
  }  

  // Eliminar cuenta del usuario  
  Future<void> deleteAccount() async {  
    if (currentUser == null) {  
      throw Exception('No hay usuario autenticado');  
    }  
    
    try {  
      final userData = await getUserData();  
      final tipoCliente = userData?['tipoCliente'];  
      final uid = currentUser!.uid;  
    
      // Eliminar datos de Firestore según el tipo de cliente  
      if (tipoCliente == 'ClienteNativo') {  
        await _firestore.collection('ClienteNativo').doc(uid).delete();  
      } else if (tipoCliente == 'ClienteGoogle') {  
        await _firestore.collection('ClienteGoogle').doc(uid).delete();  
        // Desconectar de Google Sign-In  
        await _googleSignIn.signOut();  
      }  
    
      // Eliminar cuenta de Firebase Authentication  
      await currentUser!.delete();  
        
      // Limpiar estado local  
      notifyListeners();  
        
      print('Cuenta eliminada exitosamente');  
    } on FirebaseAuthException catch (e) {  
      if (e.code == 'requires-recent-login') {  
        throw Exception('Por seguridad, necesitas volver a iniciar sesión antes de eliminar tu cuenta');  
      }  
      throw Exception('Error de autenticación: ${e.message}');  
    } catch (e) {  
      print('Error eliminando cuenta: $e');  
      throw Exception('Error al eliminar la cuenta: $e');  
    }  
  }  
    
  // Método con manejo de estado para la UI  
  Future<bool> deleteUserAccount() async {  
    _setLoading(true);  
    _setError(null);  
    
    try {  
      await deleteAccount();  
      return true;  
    } catch (e) {  
      _setError(e.toString());  
      return false;  
    } finally {  
      _setLoading(false);  
    }  
  }
}