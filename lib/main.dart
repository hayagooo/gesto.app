import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:intl/intl.dart';

void main() {
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 4;

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
        page = LoginPage(onChangePage: changePage,);
        break;
      case 4:
        page = SignUpPage(onChangePage: changePage,);
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
                                onPressed: () { print('Login google'); }, 
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
                                    if(selectedIndex != 3) { changePage(3); }
                                    else {
                                      print('login email password');
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

class AboutPage extends StatelessWidget {
  final Function(int) onChangePage;
  AboutPage({Key? key, required this.onChangePage}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage('assets/logo.png'),
          width: 80,
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(child: Text('Back'), onPressed: () {
              onChangePage(0);
            },),
          ),
        ),
        SizedBox(height: 20,),
        Text('About Me : Hayago Team')
      ],
    );
  }
}

class DevPage extends StatelessWidget {
  final Function(int) onChangePage;
  DevPage({Key? key, required this.onChangePage}): super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage('assets/logo.png'),
          width: 80,
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(child: Text('Back'), onPressed: () {
              onChangePage(0);
            },),
          ),
        ),
        SizedBox(height: 20,),
        Text('Development : Flutter, Firebase, Golang (Google Banget)')
      ],
    );
  }
}

class SignUpPage extends StatefulWidget {
  final Function(int) onChangePage;
  SignUpPage({Key? key, required this.onChangePage}): super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController dateInput = TextEditingController();
  String? selectedCountry;
  final List<String> countries = ['Indonesia', 'Japan', 'Malaysia', 'Singapore', 'Thailand']; 
  @override
  void initState() {
    dateInput.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Text('Development : Flutter, Firebase, Golang (Google Banget)'),
          SizedBox(height: 10,),
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: dateInput,
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
              });
            },
            items: countries.map((e) => DropdownMenuItem(value: e, child: Text(e),)).toList(),
          ),
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username',
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username',
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 10,),
          TextFormField(
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Password',
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final Function(int) onChangePage;
  LoginPage({Key? key, required this.onChangePage}): super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Username / Email',
            ),
          ),
        ),
        SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: TextFormField(
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
    );
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

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",),
      ),
    );
  }
}