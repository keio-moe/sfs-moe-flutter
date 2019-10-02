import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sfs/pages/assignments.dart';
import 'package:sfs/pages/login.dart';
import 'package:sfs/utils/consts.dart';
import 'package:sfs/utils/settings.dart';
import 'package:sfs/utils/sfs_auth.dart';

class ContainerWidget extends StatefulWidget {
  ContainerWidget({Key key, @required this.onThemeChanged}) : super(key: key);

  final ValueChanged<bool> onThemeChanged;
  @override
  _ContainerWidgetState createState() =>
      _ContainerWidgetState(onThemeChanged: onThemeChanged);
}

class _ContainerWidgetState extends State<ContainerWidget> {
  final ValueChanged<bool> onThemeChanged;
  int _selectedIndex = 0;
  bool _darkMode = false;
  bool _isLoading = false;
  String _sfsUrl = Consts.SFS_HOST;

  _ContainerWidgetState({@required this.onThemeChanged}) {
    Settings.darkMode.then((value) {
      this.setState(() {
        _darkMode = value;
        onThemeChanged(value);
      });
    });

    SfsAuth.token.then((value) {
      this.setState(() {
        _sfsUrl =
            "https://vu.sfc.keio.ac.jp/sfc-sfs/portal_s/s01.cgi?lang=ja&id=$value&type=s&mode=0";
      });
    });
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    AssignmentsWidget(),
    // Text(
    //   'Coming Soon...',
    //   style: optionStyle,
    // ),
    Text(
      'Coming Soon...',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SFS Moe'),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            _widgetOptions.elementAt(_selectedIndex),
            _showCircularProgress(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.school),
          //   title: Text('Timetable'),
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Assignments'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            title: Text('Bus Timer'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(child: Image.asset('assets/images/logo.png')),
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.web),
              title: Text('Go To SFC-SFS'),
              onTap: () async {
                await launch(_sfsUrl);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_activity),
              title: Text('Go To Wellness'),
              onTap: () async {
                await launch('https://wellness.sfc.keio.ac.jp/');
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.settings),
            //   title: Text('Settings'),
            //   onTap: () {
            //     // Update the state of the app.
            //     // ...
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () async {
                await SfsAuth.removeProfile();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginWidget()));
              },
            ),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (darkMode) {
                setState(() {
                  _darkMode = darkMode;
                });
                this.onThemeChanged(darkMode);
              },
              secondary: const Icon(Icons.lightbulb_outline),
            ),
          ],
        ),
      ),
    );
  }
}
