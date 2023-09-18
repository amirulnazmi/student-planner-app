import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_planner_app/models/user.dart';
import 'package:student_planner_app/pages/homePage.dart';
import 'package:student_planner_app/themes/colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = new GlobalKey<FormState>();
  String _email, _password, _username, errorMessage;
  bool _autoValidate = false;
  bool _isLoginForm = true;
  bool _obscureText = true;

  SharedPreferences loginData;
  bool newUser;

  final labelStyle = TextStyle(
    color: CustomColor.secondary1,
    fontWeight: FontWeight.bold,
  );

  final outlineInputBorderStyle = OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
    borderRadius: BorderRadius.circular(10.0),
  );

  String capitalize(String string) {
    if (string == null) {
      throw ArgumentError("string: $string");
    }

    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  inputFieldStyle(String hint, IconData icon){
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      focusedBorder: outlineInputBorderStyle,
      focusedErrorBorder: outlineInputBorderStyle,
      errorBorder: outlineInputBorderStyle,
      enabledBorder: outlineInputBorderStyle,
      errorStyle: TextStyle(
        color: Colors.white,
        fontSize: 11.0,
      ),
      prefixIcon: Icon(
        icon,
        color: CustomColor.primary,
        size: 20.0
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: CustomColor.primary,
      ),
    );
  }

  Widget usernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Username', style: labelStyle,),
        SizedBox(height: 5.0),
        Material(
          color: Color(0x00000000),
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10.0,
          shadowColor: Colors.black,
          child: TextFormField(
            autovalidate: _autoValidate,
            onSaved: (input) => _username = input.trim(),
            validator: (input) {
              if(input.isEmpty){
                return 'Please provide a username';
              }
              return null;
            },
            style: TextStyle(
              color: CustomColor.primary,
            ),
            decoration: inputFieldStyle('Enter your username', FontAwesome5Solid.user),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Email', style: labelStyle,),
        SizedBox(height: 5.0),
        Material(
          color: Color(0x00000000),
          elevation: 10.0,
          shadowColor: Colors.black,
          child: TextFormField(
            autovalidate: _autoValidate,
            onSaved: (input) => _email = input.trim(),
            validator: (input) {
              if(input.isEmpty){
                return 'Please provide an email';
              }
              // else if(!EmailValidator.validate(input)){
              //   return "Please enter a valid email";
              // }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: CustomColor.primary,
            ),
            decoration: inputFieldStyle('Enter your email', FontAwesome5Solid.envelope)
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Password', style: labelStyle,),
        SizedBox(height: 5.0),
        Material(
          color: Colors.white.withOpacity(0.0),
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10.0,
          child: TextFormField(
            autovalidate: _autoValidate,
            onSaved: (input) => _password = input.trim(),
            validator: (input) {
              if(input.isEmpty){
                return 'Please provide a password';
              }
              else if(input.length < 6){
                return 'Password is too short';
              }
              return null;
            },
            obscureText: _obscureText,
            style: TextStyle(
              color: CustomColor.primary,
            ),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              focusedBorder: outlineInputBorderStyle,
              focusedErrorBorder: outlineInputBorderStyle,
              errorBorder: outlineInputBorderStyle,
              enabledBorder: outlineInputBorderStyle,
              errorStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 11.0,
                ),
              prefixIcon: Icon(
                FontAwesome5Solid.lock,
                color: CustomColor.primary,
                size: 20.0,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(_obscureText? FontAwesome5Solid.eye : FontAwesome5Solid.eye_slash, color: CustomColor.primary, size: 20.0,)
              ),
              hintText: 'Enter your Password',
              hintStyle: TextStyle(
                color: CustomColor.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: _isLoginForm ? signIn : signUp,
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: CustomColor.secondary1,
        child: Text(
          _isLoginForm ? 'LOGIN' : 'REGISTER',
          style: TextStyle(
            color: CustomColor.primary,
            letterSpacing: 1.5,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget displayLoginText() {
    return GestureDetector(
      onTap: _toggleFormMode,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _isLoginForm ? 'Don\'t have an Account? ' : 'Have an account? ',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: _isLoginForm ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                color: CustomColor.secondary1,
                fontFamily: 'Nunito',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.primary,
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 80.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Student Planner Application',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CustomColor.secondary1,
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _isLoginForm ? SizedBox(height: 0.0) : usernameField(),
                    SizedBox(height: 20.0),
                    _buildEmailTF(),
                    SizedBox(height: 20.0),
                    _buildPasswordTF(),
                    _isLoginForm? SizedBox(height: 30.0) : SizedBox(height: 10.0),
                    _buildLoginBtn(),
                    displayLoginText(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

    @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleFormMode(){
    _formKey.currentState.reset();
    if(_isLoginForm){
      setState(() {
        _autoValidate = false;
        _isLoginForm = false;
      });
    }
    else{
      setState(() {
        _autoValidate = false;
        _isLoginForm = true;
      });
    }
  }

  void showErrorMessage(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text('Error Message',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CustomColor.secondary1,
            ),
          ),
          content: Text(
            errorMessage, 
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _showSignUpMessage(){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: CustomColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Text(
            'Success Message',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: CustomColor.secondary1,
            ),
          ),
          content: Text('Your account has been registered successfully. \nPlease log in to continue.',
            style: TextStyle(
              fontSize: 17.0,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            )
          ],
        );
      },
    );
  }

  void _createUser(String uID){
    var db = FirebaseDatabase.instance.reference();
    DateTime defaultTime = DateTime(0000, 0, 0, 7, 0);
    User user = User(uID, capitalize(_username), _email, false, false, defaultTime, defaultTime);

    db.child('User').push().set(user.toJson());
  }

  Future<void> signUp() async{
    String userID;
    final _formState = _formKey.currentState;

    if(_formState.validate()){
      _formState.save();
      try{
        FirebaseUser user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password)).user;
        userID = user.uid;
        _createUser(userID);
        _showSignUpMessage();
      }catch(e){
        setState( () {
          errorMessage = e.message;
          showErrorMessage();
        });
      }
    }
    else{
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<void> signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final _formState = _formKey.currentState;

    if(_formState.validate()){
      _formState.save();
      try{
        FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)).user;
        String userID = user.uid.toString();
        prefs.setString('userID', userID);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext ctx) => HomePage()));
      }catch(e){
        setState( () {
          errorMessage = e.message;
          showErrorMessage();
        });
      }
    }
    else{
      setState(() {
        _autoValidate = true;
      });
    }
  }

  
}
