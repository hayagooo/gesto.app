import 'package:flutter/material.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var selectedIndex = 0;
  
  void changePage(int index) {
    setState(() { selectedIndex = index; });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if(!_tabController.indexIsChanging) onTabSelected();
    });
  }

  void onTabSelected() {
    changePage(_tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(onTabSelected);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    String title;
    String avatarImage = 'assets/avatar.png';
    switch (selectedIndex) {
      case 0:
        title =  'Selamat Datang \nUser';
        page = DashboardPage();
        break;
      case 1:
        title = 'Community';
        page = CommunityPage(navLabel: 'Community');
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Column(
            children: [
              NavBar(title: title, avatarImage: avatarImage),
              Container(
                child: page
              ),
            ],
          ),
        ),
        bottomNavigationBar: Material(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard',),
              Tab(icon: Icon(Icons.people), text: 'Community'),
              Tab(icon: Icon(Icons.person), text: 'Friend'),
            ],
          ),
        ),
      );
    });
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}): super(key: key);
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late List<bool> logs;
  @override
  void initState() {
    super.initState();
    logs = List<bool>.filled(5, false);
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
      child: Column(
        children: [
          
          SizedBox(height: 24.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF1549FF),
                  Color(0xFF0029BB),
                ],
                stops: [0.0255, 0.9942]
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Current Mode', style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600
                  )),
                  Card(
                    color: Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Easy Command',
                        style: TextStyle(
                          color: Color(0xFF1549FF),
                          fontWeight: FontWeight.w500
                        )),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 24.0),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Easy Command",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0
                      ),
                    ),
                    Text("Berbahasa isyarat lebih mudah \ndengan fitur pintasan. ",
                      style: TextStyle(
                        fontSize: 12.0
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(onPressed: () {
                        Navigator.of(context).pushNamed('/smart_gestures');
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                        )
                      ),
                      child: Text('Ayo Mulai', style: TextStyle(color: Colors.white))
                    )
                  ],
                ),
                Card(
                  color: Color(0xFF1549FF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                    child: Text("10 Data", style: TextStyle(color: Colors.white),),
                  ),
                )
              ]),
            ),
          ),
          SizedBox(height: 20.0),
          Row(children: [
            Text("Log Activity", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),),
            SizedBox(width: 10.0),
            Card(
              color: Color(0xFF1549FF),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                child: Text("${logs.length}", style: TextStyle(color: Colors.white),),
              ),
            )
          ]),
          SizedBox(height: 16.0),
          for(int i = 0; i < logs.length; i++)
            GestureDetector(
              onTap: () { setState(() {
                logs[i] = !logs[i];
              }); },
              child: MouseRegion(
                onEnter: (_) { setState(() {
                  logs[i] = true;
                }); },
                onExit: (_) { setState(() {
                  logs[i] = false;
                }); },
                child: Expanded(
                  child: Card(
                    elevation: 0.0,
                    color: logs[i] ? Colors.white : Colors.white10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Saya ingin makan sekarang."),
                              Card(
                                color: Color(0xFF1549FF),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                                  child: Text("Easy Command", style: TextStyle(color: Colors.white),),
                                ),
                              )
                            ],
                          ),
                          Text('23 Des 2023 10:03', style: TextStyle(fontSize: 12.0, color: Colors.black54),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class CommunityPage extends StatefulWidget {
  final String navLabel;
  const CommunityPage({Key? key, required this.navLabel}): super(key: key);
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Community'),
      ],
    );
  }
}

class NavBar extends StatelessWidget {
  final String title;
  final String avatarImage;
  final String path;
  const NavBar({Key? key, required this.title, required  this.avatarImage, this.path = ''}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            if(path != '')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(10, 20),
                  elevation: 0.0,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(path);
                }, 
                child: Icon(Icons.chevron_left_rounded)
              ),
            SizedBox(width: 12),
            Text(title, 
              style: TextStyle(
                fontSize: 24.0,
                color: Color.fromARGB(246, 43, 43, 43),
                fontWeight: FontWeight.bold
              )
            ),
          ]),
          CircleAvatar(
            radius: 28.0,
            backgroundImage: AssetImage('assets/avatar.png'),
          )
        ],
      ),
    );
  }
}