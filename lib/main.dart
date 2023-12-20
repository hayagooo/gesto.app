import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:colorful_iconify_flutter/icons/vscode_icons.dart';
import 'package:iconify_flutter/icons/bxs.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/fa6_brands.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Gesto App',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Montserrat',
          scaffoldBackgroundColor: Color.fromARGB(255, 244, 244, 244),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class UserData {
  String name;
  String birthday;
  String country;
  String username;
  String email;
  String password;

  UserData({
    required this.name,
    required this.birthday,
    required this.country,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthday': birthday,
      'country': country,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  var selectedIndex = 3;

  UserData userData = UserData(name:'', birthday: '', country: '', email: '', password: '', username: '');
  void onUserDataChanged(UserData newUserData) {
    setState(() {
      userData = newUserData;
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '772924726267-vjuirtpc1u1kkovbbaefbsiq56lnhniu.apps.googleusercontent.com'
  );

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<String?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print("User successfully logged in: ${userCredential.user?.email}");
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return "Email / Password is invalid";
      }
      return "An error occurred with FirebaseAuth: ${e.message}";
    } catch(e) {
      return "An error occurred. Please try again later.";
    }
  }

  Future<String?> registerUser(String email, String password, UserData userData) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      await FirebaseDatabase.instance.ref('users/$uid').set(userData.toJson());
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
      return 'An error occurred. Please try again.';
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  void attemptRegistration() async {
    String? errorMessage;
    if(selectedIndex == 4) {
      if(_signUpFormKey.currentState!.validate()) {
        errorMessage = await registerUser(userData.email, userData.password, userData); 
      } else { print('Form is not valid'); return null; } 
    }
    else if(selectedIndex == 3) { 
      if(_signInFormKey.currentState!.validate()) {
        errorMessage = await loginWithEmailPassword(userData.email, userData.password);
      } else { print('Form is not valid'); return null; } 
    }
    if(mounted) {
      if (errorMessage != null) {
        _showAlertDialog('Error', errorMessage, context);
      } else {
        if(selectedIndex == 3) { _showAlertDialog('Success', 'Login Successfully', context); }
        else if(selectedIndex == 4) { _showAlertDialog('Success', 'Register Successfully', context); }
      }
    }
  }

  void _showAlertDialog(String title, String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override

  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = FirstPage();
        break;
      case 1:
        page = AboutPage(onChangePage: changePage);
        break;
      case 2:
        page = DevPage(onChangePage: changePage,);
        break;
      case 3:
        page = LoginPage(onChangePage: changePage, onUserDataChanged: onUserDataChanged, formKey: _signInFormKey,);
        break;
      case 4:
        page = SignUpPage(onChangePage: changePage, onUserDataChanged: onUserDataChanged, formKey: _signUpFormKey,);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: page,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      color: Color(0xFFFFFFFF),
                      elevation: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            if(selectedIndex != 3 && selectedIndex != 4)
                              TextButton(
                                style: TextButton.styleFrom(
                                  iconColor: Color.fromARGB(137, 0, 0, 0)
                                ),
                                onPressed: () { changePage(1); }, 
                                child: FittedBox(fit: BoxFit.fitWidth, child: Icon(Icons.person_pin),),
                              ),
                            if(selectedIndex != 3 && selectedIndex != 4)
                              TextButton(
                                style: TextButton.styleFrom(
                                  iconColor: Color.fromARGB(137, 0, 0, 0)
                                ),
                                onPressed: () { changePage(2); }, 
                                child: FittedBox(fit: BoxFit.fitWidth, child: Icon(Icons.code),),
                              ),
                            if(selectedIndex == 3 || selectedIndex == 4)
                              TextButton(
                                style: TextButton.styleFrom(
                                  iconColor: Color.fromARGB(137, 0, 0, 0)
                                ),
                                onPressed: () async { 
                                  try {
                                    await signInWithGoogle();
                                  } catch(e) {
                                    print(e);
                                  }
                                 }, 
                                child: FittedBox(fit: BoxFit.fitWidth, child: Iconify(Logos.google_icon),),
                              ),
                            Expanded(
                              child: ElevatedButtonTheme(
                                data: ElevatedButtonThemeData(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1549FF),
                                    elevation: 0,
                                    padding: EdgeInsets.all(16),
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF002094),
                                      offset: Offset(0, 2),
                                      blurRadius: 0,
                                      spreadRadius: 0
                                    )
                                  ]
                                ),
                                child: ElevatedButton(
                                  onPressed: () { 
                                    if(selectedIndex != 3 && selectedIndex != 4) { changePage(3); }
                                    else  {
                                      print("User Data: ${userData.toJson()}");
                                      attemptRegistration();
                                    }
                                  }, 
                                  child: Text(selectedIndex != 4 ? 'Sign In' : 'Sign Up', style: TextStyle(color: Color(0xFFFFFFFF)))),
                              ),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ),
              if(selectedIndex == 3)
                TextButton(
                  style: TextButton.styleFrom(
                    iconColor: Color.fromARGB(137, 0, 0, 0)
                  ),
                  onPressed: () { changePage(4); }, 
                  child: FittedBox(fit: BoxFit.fitWidth, child: Text('Sign Up')),
                ),
              if(selectedIndex == 4)
                TextButton(
                  style: TextButton.styleFrom(
                    iconColor: Color.fromARGB(137, 0, 0, 0)
                  ),
                  onPressed: () { changePage(3); }, 
                  child: FittedBox(fit: BoxFit.fitWidth, child: Text('Sign In')),
                ),
              if(selectedIndex == 3 || selectedIndex == 4)
                SizedBox(height: 20.0,)
              ],
            ),
          ),
        );
      }
    );
  }
}

class AboutPage extends StatefulWidget {
  final Function(int) onChangePage;
  AboutPage({Key? key, required this.onChangePage}): super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<dynamic> teams = [];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future <void> fetchData() async {
    final dbRef = FirebaseDatabase.instance.ref();
    dbRef.child("data/teams").get().then((snapshot) {
      if(snapshot.exists) {
        setState(() {
          teams = snapshot.value as List<dynamic>;
        });
      } else {
        print('No data available');
      }
    }).catchError((err) {
      print('Failed to fetch data: $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Image(
            image: AssetImage('assets/logo.png'),
            width: 80,
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(child: Text('Back'), onPressed: () {
              widget.onChangePage(0);
            },),
          ),
          SizedBox(height: 20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(alignment: Alignment.centerLeft, child: Text('Gesto', style: TextStyle(color: Color(0xFF1549FF), fontSize: 32, fontWeight: FontWeight.bold))),
              Image(image: AssetImage('assets/about.png')),
              SizedBox(height: 20),
              Text( "Welcome to an innovative journey where technology meets empathy - introducing our latest endeavor, the 'Gesto' Project. At the heart of Gesto lies a profound commitment to enhancing the lives of individuals with disabilities, specifically those who face challenges in verbal communication.\n\nOur mission with Gesto is to revolutionize the way people with speech and mobility impairments interact with the world around them. We've developed a groundbreaking device that utilizes advanced gesture recognition technology to translate sign language into spoken words. This technology not only bridges the communication gap but also empowers individuals to express themselves freely and effortlessly.",
                style: TextStyle(
                  fontSize: 16, // Adjust the font size for readability
                ),
              ),
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image(image: AssetImage('assets/hand.jpg'), width: MediaQuery.of(context).size.width * 0.95)),
              Text( "\nIn a world where inclusion is key, Gesto stands as a beacon of hope, offering a new avenue for seamless and inclusive communication. Our dedicated team has worked tirelessly to ensure that this tool is not just functional but also intuitive and user-friendly, catering to the unique needs of its users.\n\nJoin us as we unveil Gesto – a step towards a more inclusive and understanding world where every voice, no matter how it's expressed, is heard loud and clear.",
                style: TextStyle(
                  fontSize: 16, // Adjust the font size for readability
                ),
              ),
              SizedBox(height: 40,),
              Align(alignment: Alignment.centerLeft, child: Text('Hayago Team', style: TextStyle(color: Color(0xFF1549FF), fontSize: 32, fontWeight: FontWeight.bold))),
              for (var teamMember in teams)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(image: AssetImage('assets/${teamMember['image']}'), width: MediaQuery.of(context).size.width * 0.4,),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Text(teamMember['name'], style: TextStyle(color: Color(0xFF1549FF), fontSize: 28.0, fontWeight: FontWeight.bold)),
                        Text(teamMember['role'], style: TextStyle(color: Color.fromARGB(127, 0, 0, 0), fontSize: 16.0, fontWeight: FontWeight.w400)),
                      ]),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DevPage extends StatelessWidget {
  final Function(int) onChangePage;
  DevPage({Key? key, required this.onChangePage}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Image(
            image: AssetImage('assets/logo.png'),
            width: 80,
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(child: Text('Back'), onPressed: () {
              onChangePage(0);
            },),
          ),
          SizedBox(height: 20,),
          Align(alignment: Alignment.centerLeft, child: Text('Software Development', style: TextStyle(color: Color(0xFF1549FF), fontSize: 28.0, fontWeight: FontWeight.bold),)),
          SizedBox(height: 10,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Iconify(VscodeIcons.file_type_flutter, size: 48.0,),
                  Text('Flutter', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('App Development', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
              Column(
                children: [
                  Iconify(Fa6Brands.golang, size: 48.0,),
                  Text('Golang', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Web Server', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
              Column(
                children: [
                  Iconify(VscodeIcons.file_type_firebase, size: 48.0,),
                  Text('Firebase', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Cloud Database', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
            ],),
          SizedBox(height: 20,),
          Align(alignment: Alignment.centerLeft, child: Text('Designed Using', style: TextStyle(color: Color(0xFF1549FF), fontSize: 28.0, fontWeight: FontWeight.bold),)),
          SizedBox(height: 10,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Iconify(IconParkSolid.adobe_illustrate, size: 48.0,),
                  Text('Illustrator', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Graphic Design', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
              Column(
                children: [
                  Iconify(Logos.figma, size: 48.0,),
                  Text('Figma', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Ui Ux Design', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
              Column(
                children: [
                  Iconify(IconParkSolid.adobe_photoshop, size: 48.0,),
                  Text('Photoshop', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Image Editing', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
            ],),
          SizedBox(height: 20,),
          Align(alignment: Alignment.centerLeft, child: Text('IoT Tools', style: TextStyle(color: Color(0xFF1549FF), fontSize: 28.0, fontWeight: FontWeight.bold),)),
          SizedBox(height: 10,),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Iconify(Bxs.microchip, size: 48.0,),
                  Text('ESP32', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Wifi Module', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
              Column(
                children: [
                  Iconify(VscodeIcons.file_type_arduino, size: 48.0,),
                  Text('Arduino IDE', style: TextStyle(color: Color.fromARGB(255, 28, 28, 28), fontSize: 18.0, fontWeight: FontWeight.w600)),
                  Text('Microchip Editor', style: TextStyle(color: Color.fromARGB(154, 28, 28, 28), fontSize: 12.0, fontWeight: FontWeight.normal)),
                ],
              ),
            ],),
          
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final Function(int) onChangePage;
  final Function(UserData) onUserDataChanged;
  final GlobalKey<FormState> formKey;
  SignUpPage({Key? key, required this.onChangePage, required this.onUserDataChanged, required this.formKey}): super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController dateInput = TextEditingController();
  TextEditingController nameInput = TextEditingController();
  TextEditingController usernameInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  String? selectedCountry;
  final List<String> countries = ['Indonesia', 'Japan', 'Malaysia', 'Singapore', 'Thailand']; 
  var showPassword = false;

  @override
  void initState() {
    super.initState();
    nameInput.text = "";
    dateInput.text = "";
    usernameInput.text = "";
    emailInput.text = "";
    passwordInput.text = "";
    selectedCountry = 'Indonesia';
    nameInput.addListener(() => sendUserData());
    dateInput.addListener(() => sendUserData());
    usernameInput.addListener(() => sendUserData());
    emailInput.addListener(() => sendUserData());
    passwordInput.addListener(() => sendUserData());
  }

  void sendUserData() {
    UserData userData = UserData(name: nameInput.text, birthday: dateInput.text, country: selectedCountry ?? "", username: usernameInput.text, email: emailInput.text, password: passwordInput.text);
    widget.onUserDataChanged(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              Image( image: AssetImage('assets/logo.png'), width: 80,),
              Text('Gesto', style: TextStyle(color: Color(0xFF1549FF), fontSize: 32, fontWeight: FontWeight.bold),)
            ]),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(child: Text('Back'), onPressed: () {
                widget.onChangePage(0);
              },),
            ),
            SizedBox(height: 20,),
            Text('Signup And Start Communicating', style: TextStyle(color: Color(0xFF1549FF), fontSize: 32, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a name';
                return null;
              },
              controller: nameInput,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: dateInput,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your birthday';
                return null;
              },
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1945), lastDate: DateTime(2101));
                    if(pickedDate != null) {
                      print(pickedDate);
                      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(formattedDate);
                      setState(() {
                        dateInput.text = formattedDate;
                      });
                    } else { print('Date must selected first'); }
                  },
                ),
                border: UnderlineInputBorder(),
                labelText: 'Birthday',
              ),
              readOnly: true,
            ),
            SizedBox(height: 10,),
            DropdownButtonFormField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Country',
              ),
              value: selectedCountry,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCountry = newValue;
                  sendUserData();
                });
              },
              items: countries.map((e) => DropdownMenuItem(value: e, child: Text(e),)).toList(),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: usernameInput,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an username';
                if (value.length < 4) return 'Username must be at least 4 characters long';
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: emailInput,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an email';
                if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b').hasMatch(value)) return 'Enter a valid email address';
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: passwordInput,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter password';
                if (value.length < 8) return 'Password must be at least 8 characters long';
                return null;
              },
              obscureText: !showPassword,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                children: [
                  Checkbox(value: showPassword, onChanged: (bool? value) {
                    setState(() {
                      showPassword = value!;
                    });
                  }),
                  Text('Show Password')
                ],
              )
            ]),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameInput.dispose();
    dateInput.dispose();
    usernameInput.dispose();
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}

class LoginPage extends StatefulWidget {
  final Function(int) onChangePage;
  final Function(UserData) onUserDataChanged;
  final GlobalKey<FormState> formKey;
  LoginPage({Key? key, required this.onChangePage, required this.onUserDataChanged, required this.formKey}): super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailInput = TextEditingController();
  TextEditingController passwordInput = TextEditingController();
  var showPassword = false;

  @override
  void initState() {
    super.initState();
    emailInput.text = "";
    passwordInput.text = "";
    emailInput.addListener(() => sendUserData());
    passwordInput.addListener(() => sendUserData());
  }

  void sendUserData() {
    UserData userData = UserData(name: '', birthday: '', country: '', username: '', email: emailInput.text, password: passwordInput.text);
    widget.onUserDataChanged(userData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/login.png'), fit: BoxFit.cover),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage('assets/logo.png'),
                    width: 120,
                  ),
                  Text('GESTO', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 48, fontWeight: FontWeight.w800)),
                  SizedBox(height: 24,),
                  Text('Unlocking Worlds with Movement.', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 28, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic)),
                  SizedBox(height: 120,),
              ]),
            ),
          ),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(child: Text('Back'), onPressed: () {
                widget.onChangePage(0);
              },),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: TextFormField(
              controller: emailInput,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an email';
                if (!RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b').hasMatch(value)) return 'Enter a valid email address';
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: TextFormField(
              controller: passwordInput,
              obscureText: !showPassword,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter password';
                if (value.length < 8) return 'Password must be at least 8 characters long';
                return null;
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Password',
              ),
            ),
          ),
          SizedBox(height: 17,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Row(
                children: [
                  Checkbox(value: showPassword, onChanged: (bool? value) {
                    setState(() {
                      showPassword = value!;
                    });
                  }),
                  Text('Show Password')
                ],
              ),
              TextButton(onPressed: () {
                AlertDialog(title: Text('Email sending...'),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                  }, child: Text('Ok'))
                ],);
              }, child: Text('Forgot Password'))
            ]),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // var appState = context.watch<MyAppState>();
    // var pair = appState.current;

    // IconData icon;
    // if(appState.favorites.contains(pair)) {
    //   icon = Icons.favorite;
    // } else {
    //   icon = Icons.favorite_border;
    // }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image(
          image: AssetImage('assets/logo.png'),
          width: 80,
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 42.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Welcome to Gesto App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('A device facilitating communication for people with disabilities.', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
              Image(
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * 0.55,
                image: AssetImage('assets/illustration.png')
              ),
            ],
          ),
        ),
      ]
    );
  }
}