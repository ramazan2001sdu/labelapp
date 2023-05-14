import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:label_app/models/ra_user.dart';

import '../../models/localization.dart';
import '../../service/api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final gg = GoogleSignIn();
  Localization localize = Localization();

  AuthService();

  //Create user based on Firebase User
  RaUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? RaUser(
            uid: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "")
        : null;
  }

  //auth change user stream
  Stream<RaUser?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  Future signOut() async {
    try {
      await gg.signOut();
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  Future signInWithEmail(String email, String pass) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);
      User? firebaseUser = result.user;
      await APIService().registerUser(firebaseUser!, "Email", "");
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      return null;
    }
  }

  Future forgotPassword(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      var snackBar = SnackBar(content: Text(localize.authResetEmail));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      var snackBar = SnackBar(content: Text(localize.authEmailNotFound));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future registerWithEmail(
      String email, String pass, String displayName, File image) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User? firebaseUser = result.user;
      await firebaseUser?.updateDisplayName(displayName);
      String imageUrl = await uploadImage(image, firebaseUser!.uid);
      await firebaseUser?.updatePhotoURL(imageUrl);
      await APIService().registerUser(firebaseUser!, "Email", displayName);
      Purchases.logIn(firebaseUser.uid);
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadImage(File image, String userID) async {
    String fileName = userID;
    final _firebaseStorage = FirebaseStorage.instance;
    if (image != null) {
      //Upload to Firebase
      var snapshot =
          await _firebaseStorage.ref().child('images/$fileName').putFile(image);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } else {
      return "";
    }
  }

  Future<UserCredential> signInWithCredentials(AuthCredential credential) =>
      _auth.signInWithCredential(credential);

  Future signInGoogle(BuildContext context) async {
    try {
      final user = await gg.signIn();
      if (user == null) {
        return null;
      } else {
        final googleAuth = await user.authentication;

        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final result = await _auth.signInWithCredential(credential);

        //Update photo and display name of Firebase User
        User? firebaseUser = result.user;

        firebaseUser?.updateDisplayName(user.displayName);
        //Return the new user of type ViUser
        await APIService().registerUser(firebaseUser!, "Google", "");
        Purchases.logIn(firebaseUser.uid);
        return _userFromFirebaseUser(firebaseUser);
      }
    } catch (e) {
      var snackBar = SnackBar(content: Text(localize.authAccountExist));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }
  }
}
