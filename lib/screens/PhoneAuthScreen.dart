import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotbuddy/screens/HomeScreen.dart';
import 'package:spotbuddy/screens/gender.dart';

class PhoneAuthScreen extends StatefulWidget {
  double lat = 0.0;
  double long = 0.0;
  late String mUid;
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
  PhoneAuthScreen();
  PhoneAuthScreen.withOptions(this.lat, this.long, this.mUid);
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  ///************************** Variables ****************************///
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String _verificationId = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _errorMessage = '';
  late String phoneNumber;
  bool _isOtpVisible = false; // To track whether the OTP widget should be visible
  ///************************** Variables ****************************///


  // Send OTP to the phone number
  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _errorMessage = ''; // Clear previous error message
    });

    phoneNumber = '+91' + _phoneController.text.trim(); // Append country code

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Automatically signs the user in when OTP is auto-detected
          await _linkPhoneNumberWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          print(e);
          print(e.stackTrace);
          setState(() {
            _errorMessage = 'Verification failed. Please try again.';
            // _isOtpVisible = false; // Hide OTP field in case of failure
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Code Sent!");
          setState(() {
            _verificationId = verificationId;
            _isOtpVisible = true; // Show the OTP field
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code Auto Retrieval Timeout");
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error sending OTP: $e';
        _isOtpVisible = false; // Hide OTP field in case of error
      });
    }
  }

  // Verify OTP entered by the user
  Future<void> _verifyOTP() async {
    final String smsCode = _otpController.text.trim();

    if (smsCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP.';
      });
      return;
    }

    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );

      // Link the phone number to the existing user (signed in via Google)
      await _linkPhoneNumberWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  // Link the phone number to the current Firebase user
  Future<void> _linkPhoneNumberWithCredential(AuthCredential credential) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.linkWithCredential(credential);
        await FirebaseFirestore.instance.collection('users')
            .doc(currentUser.uid)
            .update({
          'isPhoneNumberVerified': true,
          'phoneNumber': _phoneController.text,
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("phoneNumber", phoneNumber);

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if(userDoc['isBasicDetails']){
          // Phone number successfully linked, navigate to Homepage
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => HomeScreen.withOptions(widget.lat,widget.long,widget.mUid)));
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => GenderSelectionScreen()));
        }

        //Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to link phone number: $e';
        });
      }
    }
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('Phone Authentication'),
        backgroundColor: const Color(0xffffffff), // Consistent theme
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phone number input field
              if (!_isOtpVisible) // Show phone input only when OTP is not yet sent
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Enter your phone number',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '*** *** ****',
                        prefixText: '+91 ',
                        filled: true,
                        fillColor: Colors.grey[200],
                        prefixIcon: Icon(Icons.phone, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, // Button will take full width
                      child: ElevatedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _verifyPhoneNumber();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xff4C46EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // OTP input field
              if (_isOtpVisible) // Show OTP input after phone number verification
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Enter OTP sent to your number',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: _otpController,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          hintText: 'Enter your 6-digit OTP',
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: Icon(Icons.password, color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please OTP';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _verifyOTP();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xff4C46EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Error message display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

}
