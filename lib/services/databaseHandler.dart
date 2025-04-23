// import 'package:comsicon/services/cloudinaryServices.dart';
// import 'package:comsicon/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase Auth instance

  // ------------------- AUTH METHODS (unchanged) -------------------
  Future<bool> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logged in successfully!')));
        Navigator.pushNamed(context, '/home');
        return true; // Indicate success
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.message}')));
      return false; // Indicate failure
    }
    return false;
  }

  // Future<bool> signUp({
  //   required String email,
  //   required String password,
  //   required BuildContext context,
  // }) async {
  //   try {
  //     final UserCredential credential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);

  //     if (credential.user != null) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('User created successfully!')));
  //       Navigator.pushNamed(context, '/profileSetup');
  //       return true; // Indicate success
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Sign up failed: ${e.message}')));
  //     return false; // Indicate failure
  //   }
  //   return false;
  // }
  Future<bool> signUp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user != null) {
        // Get the newly created user's UID
        final String uid = credential.user!.uid;

        // Create user document in Firestore with UID as document ID
        await _firestore
            .collection('users')
            .doc(uid)
            .set({
              'email': email,
              'uid': uid,
              'createdAt': FieldValue.serverTimestamp(),
            })
            .then((_) {
              print('User document created successfully for UID: $uid');
              print('User data: {"email": "$email", "uid": "$uid"}');
            })
            .catchError((error) {
              print('Error creating user document: $error');
              throw error;
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User created and data added successfully!'),
          ),
        );
        return true;
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up failed: ${e.message}')));
      print('Sign up error: ${e.message}');
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
      print('General error: $e');
      return false;
    }
    return false;
  }

  // Future<UserCredential?> logInWithGoogle(BuildContext context) async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return null; // User canceled sign-in

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     final User? user = userCredential.user;

  //     if (user != null) {
  //       // Store user information in Firebase Realtime Database
  //       await _database.child('users').child(user.uid).set({
  //         'displayName': user.displayName,
  //         'email': user.email,
  //         'photoURL': user.photoURL,
  //       });
  //     }

  //     return userCredential;
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Google sign-in failed: ${e.message}')),
  //     );
  //   }
  //   return null;
  // }

  // If you upload images to Cloudinary
  // Future<String?> uploadChallengeImage(String filePath) async {
  //   try {
  //     final CloudinaryService cloudinaryService = CloudinaryService();
  //     final String? imageUrl = await cloudinaryService.uploadImage(
  //       filePath,
  //       AppConstants.cloudinaryUploadPreset,
  //       fileName: 'challenge_image_${DateTime.now().millisecondsSinceEpoch}',
  //     );
  //     return imageUrl;
  //   } catch (e) {
  //     throw Exception("Failed to upload challenge image: $e");
  //   }
  // }
}
