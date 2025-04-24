import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user getter
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cloudinary configuration
  final String cloudinaryUrl ='https://api.cloudinary.com/v1_1/dmgkxsjky/image/upload';
  final String uploadPreset = 'Images'; // Unsigned upload preset

  // Get user data by uid
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      throw 'Failed to load user data';
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'No user found with this email';
          case 'wrong-password':
            throw 'Incorrect password';
          case 'invalid-email':
            throw 'Invalid email format';
          case 'user-disabled':
            throw 'This account has been disabled';
          default:
            throw 'Authentication failed: ${e.message}';
        }
      }
      throw 'Login failed. Please try again';
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign in aborted';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save user to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'profileImageUrl': userCredential.user!.photoURL ?? '',
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw 'Google sign in failed: ${e.message}';
      }
      throw e.toString();
    }
  }

  // Sign in with Facebook
  Future<UserCredential> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        throw 'Facebook login was cancelled or failed';
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Sign in to Firebase with the Facebook credential
      final userCredential = await _auth.signInWithCredential(facebookAuthCredential);
      
      // Get user profile data
      final userData = await FacebookAuth.instance.getUserData();

      // Save user to Firestore if it's a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? '',
          'email': userCredential.user!.email ?? '',
          'profileImageUrl': userCredential.user!.photoURL ?? '',
          'provider': 'facebook',
          'facebookId': userData['id'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw 'Facebook sign in failed: ${e.message}';
      }
      throw e.toString();
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String contactNumber,
    File? profileImage,
    File? backgroundImage,
    String? instagramUrl,
    String? facebookUrl,
    String? youtubeUrl,
  }) async {
    try {
      // Create user with email and password
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Check if user was created successfully
      if (result.user == null) {
        throw 'User creation failed - no user returned';
      }

      // Upload images if they exist
      String profileImageUrl = '';
      String backgroundImageUrl = '';

      if (profileImage != null) {
        try {
          profileImageUrl = await uploadImageToCloudinary(profileImage);
          print('Profile image uploaded: $profileImageUrl');
        } catch (e) {
          print('Profile image upload error: $e');
          // Continue with registration even if image upload fails
        }
      }

      if (backgroundImage != null) {
        try {
          backgroundImageUrl = await uploadImageToCloudinary(backgroundImage);
          print('Background image uploaded: $backgroundImageUrl');
        } catch (e) {
          print('Background image upload error: $e');
          // Continue with registration even if image upload fails
        }
      }

      // Create user data map
      final Map<String, dynamic> userData = {
        'uid': result.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'contactNumber': contactNumber.trim(),
        'profileImageUrl': profileImageUrl,
        'backgroundImageUrl': backgroundImageUrl,
        'instagramUrl': instagramUrl ?? '',
        'facebookUrl': facebookUrl ?? '',
        'youtubeUrl': youtubeUrl ?? '',
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Store user data
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userData);

      return result;
    } catch (e) {
      // Handle exceptions
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw 'Email is already in use by another account';
          case 'weak-password':
            throw 'Password is too weak. Please use at least 6 characters';
          case 'invalid-email':
            throw 'Invalid email format';
          default:
            throw 'Registration error: ${e.message}';
        }
      }
      throw 'Registration failed: ${e.toString()}';
    }
  }

  // Pick image from gallery
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Upload image to Cloudinary
  Future<String> uploadImageToCloudinary(File imageFile) async {
    try {
      // Prepare upload request
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;

      // Add the file to upload
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Execute upload
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final jsonData = json.decode(respStr);

      // Check response
      if (response.statusCode == 200) {
        return jsonData['secure_url'];
      } else {
        throw 'Image upload failed: ${jsonData['error']['message']}';
      }
    } catch (e) {
      throw 'Image upload error: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
  try {
    // First try Google sign out
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out error: $e');
    }
    
    // Then try Facebook sign out
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print('Facebook sign out error: $e');
    }
    
    // Always sign out from Firebase
    return await _auth.signOut();
  } catch (e) {
    print('Error signing out: $e');
    throw 'Sign out failed';
  }
}

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw 'No user found with this email';
          case 'invalid-email':
            throw 'Invalid email format';
          default:
            throw 'Password reset failed: ${e.message}';
        }
      }
      throw 'Password reset failed: ${e.toString()}';
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (currentUser == null) return null;
      
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? contactNumber,
    File? profileImage,
    File? backgroundImage,
    String? instagramUrl,
    String? facebookUrl,
    String? youtubeUrl,
  }) async {
    try {
      if (currentUser == null) throw 'No user is signed in';
      
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Add fields that need to be updated
      if (name != null) updateData['name'] = name.trim();
      if (contactNumber != null) updateData['contactNumber'] = contactNumber.trim();
      if (instagramUrl != null) updateData['instagramUrl'] = instagramUrl.trim();
      if (facebookUrl != null) updateData['facebookUrl'] = facebookUrl.trim();
      if (youtubeUrl != null) updateData['youtubeUrl'] = youtubeUrl.trim();
      
      // Upload new profile image if provided
      if (profileImage != null) {
        final profileImageUrl = await uploadImageToCloudinary(profileImage);
        updateData['profileImageUrl'] = profileImageUrl;
      }
      
      // Upload new background image if provided
      if (backgroundImage != null) {
        final backgroundImageUrl = await uploadImageToCloudinary(backgroundImage);
        updateData['backgroundImageUrl'] = backgroundImageUrl;
      }
      
      // Update user document
      await _firestore.collection('users').doc(currentUser!.uid).update(updateData);
    } catch (e) {
      throw 'Profile update failed: ${e.toString()}';
    }
  }
}