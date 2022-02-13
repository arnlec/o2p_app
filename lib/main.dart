import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_login/flutter_login.dart';
import 'chicken_lib.dart';
import 'amplifyconfiguration.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O2P',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'O2P'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);


  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? _username;
  bool _isLoaded = false;
  bool _isSignedIn = false;


  @override
  initState(){
    super.initState();
    _configureAmplify();
  }

  _configureAmplify() async{
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugins([authPlugin,AmplifyAPI()]);
    try{
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      //print("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
    Amplify.Auth.fetchAuthSession()
      .then(
        (authSession) => setState((){
          _isLoaded = true;
          _isSignedIn = authSession.isSignedIn;})
      ); 
  }



  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: _actions(context)
        ),
        body: _body(context)
      );
  }

  List<Widget> _actions(context){
    if (_isSignedIn){
      return [
          IconButton(
            onPressed: ()=>_confirmLogout(context), 
            icon: const Icon(Icons.account_circle),
            tooltip: _username,
            )
      ];
    }
    else{
      return [];
    }
  } 

  Widget _body(context){
    if (!_isLoaded){
      return const CircularProgressIndicator();
    }
    else{
      return _isSignedIn ?
          const ChickenListWidget() : FlutterLogin(
                onLogin: _authUser,
                onSignup: _signupUser,
                onResendCode: _resendCode,
                hideForgotPasswordButton: true,
                onRecoverPassword: _recoverPassword,
                loginAfterSignUp: false,
                onSubmitAnimationCompleted: () => setState((){_isSignedIn = true;})
          );
    }
  }

  void _confirmLogout(context){
    showDialog(
      context: context,
      builder: (BuildContext ctx){
        return  AlertDialog(
          title: const Text('Logout confirmation'),
          content: const Text('Are you sure ?'),
          actions: [
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Amplify.Auth.signOut()
                .then((result) => setState((){_isSignedIn=false;}));
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: ()=> Navigator.of(context).pop(), 
            )
          ],);
      }

    );

  }

  Future<String?> _authUser(LoginData data){
    return Amplify.Auth.signIn(
        username: data.name,
        password: data.password)
        .then((value){
        if (value.isSignedIn){
          setState((){
            //_isSignedIn = true;
            _username = data.name;
          });
          return null;
        }
        else{
          return "Authentication failed";
        }
      })
      .catchError((e)=>"Authenticaton failed");
  }

  Future<String?> _signupUser(SignupData data){
    Map<String,String> userAttributes = {
      "email" : data.name as String
    };
    return Amplify.Auth.signUp(
        username: data.name as String,
        password: data.password,
        options: CognitoSignUpOptions(userAttributes: userAttributes))
        .then(
          (value) => value.isSignUpComplete ? null : "Signup failed"
        )
        .catchError((e)=>"Signup error");
  }

  Future<String?> _resendCode(SignupData data){
    throw UnimplementedError();
  }

  Future<String?> _recoverPassword(String name){
    throw UnimplementedError();
  }






}
