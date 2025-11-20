import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService() {
    // Initialize EmailOTP globally
    EmailOTP.config(
      appEmail: 'noreply@blueleafguide.com',
      appName: 'Blue Leaf Guide',
      otpType: OTPType.numeric,
      otpLength: 4, // 4-digit OTP
      emailTheme: EmailTheme.v6,
      expiry: 5 * 60 * 1000, // 5 minutes
    );
  }

  // // Initialize Email OTP
  // void initEmailOTP() {
  //   EmailOTP.config(
  //     appEmail: 'noreply@blueleafguide.com',
  //     appName: 'Blue Leaf Guide',
  //     otpType: OTPType.numeric,
  //     otpLength: 4,
  //     emailTheme: EmailTheme.v6,
  //     expiry: 5 * 60 * 1000,
  //   );
  // }

  /// Send OTP to email and store in Firestore
  Future<bool> sendOTP(String email, {String type = 'signup'}) async {
    try {
      // Send OTP via email
      final result = await EmailOTP.sendOTP(email: email);

      if (result) {
        // Get the generated OTP
        final generatedOTP = EmailOTP.getOTP();

        final docId = email.replaceAll('.', ',');
        try {
          await _firestore.collection('otp_verification').doc(docId).set({
            'otp': generatedOTP,
            'type': type,
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': DateTime.now().add(const Duration(minutes: 5)),
          });
          print('✅ Firestore document created: $docId');
        } catch (e) {
          print('❌ Firestore error: $e');
        }

        print('✅ OTP sent successfully to $email: $generatedOTP');
        return true;
      } else {
        print('❌ Failed to send OTP to $email');
        return false;
      }
    } catch (e) {
      print('❌ Error sending OTP: $e');
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    try {
      final docId = email.replaceAll('.', ','); // same as when saving
      final doc = await _firestore
          .collection('otp_verification')
          .doc(docId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final storedOTP = data['otp'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiresAt)) {
        await _firestore.collection('otp_verification').doc(docId).delete();
        return false;
      }

      if (storedOTP == otp) {
        await _firestore.collection('otp_verification').doc(docId).delete();
        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  // Create user account with email and password
  Future<Map<String, dynamic>> createAccount({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional user info in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save login state
      await _saveLoginState(userCredential.user!.uid);

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login state
      await _saveLoginState(userCredential.user!.uid);

      return {
        'success': true,
        'message': 'Signed in successfully',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId') && _auth.currentUser != null;
  }

  // Save login state
  Future<void> _saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setBool('isLoggedIn', true);
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get auth error message
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
