import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';
import 'app.dart';

class SmartGesturePage extends StatefulWidget {
  const SmartGesturePage({super.key});

  @override
  State<SmartGesturePage> createState() => SmartGesturePageState();
}

class SmartGesturePageState extends State<SmartGesturePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              DashboardPage(),
            ],
          ),
        ),
      );
    });
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> gestures = [];
  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("id-ID");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(1);
    fetchGestureData();
  }

  Future _speak(String text) async {
    await flutterTts.speak(text);
  }
  
  Future _stop() async {
    await flutterTts.stop();
  }

  Future genText2Wav(String text, int number) async {
    print("It is running communicating to golang");
    var request = http.Request('POST', Uri.parse('http://localhost:8000/speech'));
    request.headers.addAll({
      'Content-Type': 'application/json',
    });
    request.body = json.encode(<String, dynamic>{
      'text': text,
      'number': number
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to send data');
    }
  }

  Future <void> fetchGestureData() async {
    final dbRef = FirebaseDatabase.instance.ref("users/vtFaNWJcvPT9H4MYIuHOeruh4fu1/gestures");
    dbRef.get().then((snapshot) {
      if(snapshot.exists && snapshot.value != null) {
        final data = snapshot.value;
        List<Map<String, dynamic>> fetchedGestures = [];
        if(data is List<dynamic>) {
          fetchedGestures = data.where((item) => item != null).map((item) => Map<String, dynamic>.from(item as Map)).toList();
        } else if (data is Map<dynamic, dynamic>) {
          fetchedGestures = data.values.where((item) => item != null).map((item) => Map<String, dynamic>.from(item as Map)).toList();
        } 
        setState(() { gestures = fetchedGestures; });
      } else {
        setState(() { gestures = []; });
      }
    }).catchError((err) {
      print('Failed to fetch data: $err');
    });
  }

  void submitForm(BuildContext context, Map<String, TextEditingController> data) async {
    final dbRef = FirebaseDatabase.instance.ref("users/vtFaNWJcvPT9H4MYIuHOeruh4fu1/gestures/${data['number']?.text}");
    Map<String, dynamic> formData = {
      'number': data['number']?.text,
      'command': data['command']?.text,
    };
    genText2Wav(data['command']!.text.toString(), int.parse(data['number']!.text));

    await dbRef.set(formData).then((value) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success'))
      );
      fetchGestureData();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString()))
      );
    });
  }

  void deleteSmartGestureData(int index) async {
    final dbRef = FirebaseDatabase.instance.ref("users/vtFaNWJcvPT9H4MYIuHOeruh4fu1/gestures/$index");
    await dbRef.remove().then((value) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Success'))
      );
      fetchGestureData();
    }).catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.toString()))
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NavBar(title: 'Smart Gesture', avatarImage: 'assets/avatar.png', path: '/app'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(top: 24.0),
                width: double.infinity,
                child: 
                  ElevatedButton.icon(
                    onPressed: () {_showFormDialog(context, false); }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1549FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0)
                    ),
                    icon: Icon(Icons.add_circle_outline_sharp, color: Colors.white,), 
                    label: Text('Add new data', style: TextStyle(color: Colors.white),)
                  ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Shortcut Data', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700)),
                  SizedBox(width: 12.0),
                  Card(
                    color: Color(0xFF1549FF),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                      child: Text('${gestures.length}', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.0,),
              if(gestures.isNotEmpty)
                for(var gesture in gestures.asMap().entries)
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1549FF),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(gesture.key.toString(), style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(width: 12.0),
                                Expanded(child: Text(gesture.value['command'])),
                              ],)),
                            PopupMenuButton(
                              color: Colors.white,
                              onSelected: (String value) {
                                if(value == 'edit') {
                                  _showFormDialog(context, false, int.tryParse(gesture.value['number']), gesture.value['command']);
                                } else if(value == 'delete') {
                                  _showFormDialog(context, true, int.tryParse(gesture.value['number']), gesture.value['command']);
                                } else {
                                  _speak(gesture.value['command']);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem(value: 'play', child: Text('Play')),
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete'))
                              ],
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Colors.white,
                                  minimumSize: Size(10, 20),
                                  padding: EdgeInsets.symmetric(horizontal: 0)
                                ),
                                onPressed: null,
                                child: Icon(Icons.more_vert, color: Colors.grey[600],),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  )
           ],
          ),
        ),
      ],
    );
  }

  Future<void> _showFormDialog(BuildContext context, bool isDelete, [int? index, String? command]) async {
    Widget method;
    if(isDelete) {
      method = _buildDeleteContent(index!);
    } else {
      method = _buildFormContent(index, command);
    }
    return showDialog<void>(
      context: context, 
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
          child: Container(
            padding: EdgeInsets.all(24.0),
            color: Colors.white,
            child: method,
          ),
        );
    });
  }

  Widget _buildDeleteContent(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Are you sure for delete it ?', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('The data will be deleted permanently'),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              style: ElevatedButton.styleFrom(
                elevation: 0.0,
                backgroundColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)
                ),
                padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 20.0)
              ), 
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Process...'))
                );
                deleteSmartGestureData(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)
                ),
                padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 20.0)
              ), 
              child: Text('Delete', style: TextStyle(color: Colors.white),)
            )
         ],)
      ],
    );
  }

  Widget _buildFormContent(int? index, String? command) {
    final formKey = GlobalKey<FormState>();
    TextEditingController commandInput = TextEditingController();
    TextEditingController sortInput = TextEditingController();
    if(index != null) sortInput.text = index.toString();
    if(command != null) commandInput.text = command.toString();
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Form Smart Gesture", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.0),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: sortInput,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a number';
              final number = int.tryParse(value);
              if (number == null)  return 'Please enter a valid number';
              if (number > 100) return 'Number must not be greater than 100';
              return null;
            },
            decoration: InputDecoration(labelText: 'Sort Finger Number'),
          ),
          SizedBox(height: 12.0),
          TextFormField(
            controller: commandInput,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a command';
              return null;
            },
            decoration: InputDecoration(labelText: 'Command Text'),
          ),
          SizedBox(height: 48.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 20.0)
                ), 
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600]))
              ),
              ElevatedButton(
                onPressed: () {
                  if(formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Process...'))
                    );
                    var data = {
                      'number': sortInput,
                      'command': commandInput
                    };
                    submitForm(context, data);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 20.0)
                ), 
                child: Text('Submit', style: TextStyle(color: Colors.white),)
              )
            ],)
        ],
      ),
    );
  }
}