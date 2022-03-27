import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'map.dart';
import 'setting.dart';
import 'search/searchRoute.dart';
import 'LoginSignUpUI.dart';
import 'LoginSignUpScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';

bool acc = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bicycle navigation',
      home: AnimatedSplashScreen(
        splash: Image.asset('Assets/Image/title.PNG'),
        nextScreen: MyHomePage(title: 'Bicycle navigation'),
        splashTransition: SplashTransition.fadeTransition,
        //backgroundColor: Colors.white,
        //duration: 3000,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int selectedPage = 1;

  late TabController _tabController;
  late PageController _pageController;
  late List<Widget> _pageList;

  @override
  void initState(){
    _pageList = [LoginSignUpUI(), Map(), Setting()];

    _pageController = PageController(initialPage: selectedPage);
    _tabController = TabController(length: _pageList.length, vsync: this, initialIndex: selectedPage);

    super.initState();
    _listenLocation();
  }

  final _firestore = FirebaseFirestore.instance;

  String currUsername = '';
  List<String> names = [];
  List<LatLng> locs = [];
  List<String> uids = [];
  DatabaseService database = DatabaseService();
  final _auth = FirebaseAuth.instance;
  currUser() {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    return uid.toString();
  }

  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _location;
  Future<void> _listenLocation() async{
    _location = location.onLocationChanged.handleError((onError) {
      print(onError);
      _location?.cancel();
      setState(() {
        _location = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      for(int k=0; k<names.length; k++){
        if(currUser() == uids[k]){
          GeoPoint geo = GeoPoint(curr_lat, curr_lng);
          if(geo != locs[k]){
            await _firestore.collection('users').doc(currUser()).update({
              'location': GeoPoint(currentlocation.latitude!, currentlocation.longitude!),
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          names.clear();
          locs.clear();
          uids.clear();
          final users = snapshot.data!.docs;
          for(var user in users){
            var username = user['name'];
            var uid = user['uid'];
            GeoPoint geoPoint = user['location'];
            locs.add(LatLng(geoPoint.latitude, geoPoint.longitude));
            names.add(username.toString());
            uids.add(uid.toString());
          }
          for(int pos=0; pos<names.length; pos++){
            if(uids[pos] == currUser())
              currUsername = names[pos];
          }
          print(currUsername);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(45, 78, 115, 1),
        title: Text('자전거 내비게이션'),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0.0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('Assets/Image/title.PNG'),
                backgroundColor: Colors.white,
              ),
              accountName: Text('김현성'),
              accountEmail: Text('kimhsr@naver.com'),
              onDetailsPressed:(){
                print('arrow is clicked');
              } ,
              decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0)
                  )
              ),
            ),
            ListTile(
              leading: Icon(Icons.home,
                color: Colors.grey[850],
              ),
              title: Text('홈'),
              onTap: (){
                acc = false;
                _onTapItem(1);
                Navigator.pop(context);
              },
              trailing: Icon(Icons.add),
            ),
            ListTile(
              leading: Icon(Icons.location_on,
                color: Colors.grey[850],
              ),
              title: Text('경로 설정'),
              onTap: (){
                acc = false;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchRoute(),
                  ),
                );
              },
              trailing: Icon(Icons.add),
            ),
            ListTile(
              leading: Icon(Icons.warning_amber_outlined,
                color: Colors.grey[850],
              ),
              title: Text('위험 지역'),
              onTap: (){
                acc = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchRoute(),
                  ),
                );
              },
              trailing: Icon(Icons.add),
            ),
            ListTile(
              leading: Icon(Icons.emoji_people,
                color: Colors.grey[850],
              ),
              title: Text('내 정보'),
              onTap: (){
                acc = false;
                _onTapItem(0);
                Navigator.pop(context);
              },
              trailing: Icon(Icons.add),
            ),
            ListTile(
              leading: Icon(Icons.settings,
                color: Colors.grey[850],
              ),
              title: Text('설정'),
              onTap: () {
                acc = false;
                _onTapItem(2);
                Navigator.pop(context);
              },
              trailing: Icon(Icons.add),
            ),
          ],
        ),
      ),
      body: //_pageOptions[selectedPage],
      PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _pageList,
        onPageChanged: (index) {
          setState(() {
            acc = false;
            selectedPage = index;
          });
        },
      ),
      bottomNavigationBar: ConvexAppBar(
        initialActiveIndex: 1, //optional, default as 0
        controller: _tabController,
        backgroundColor: Colors.white, // 배경색
        color: Colors.black54,
        activeColor: Color.fromRGBO(45, 78, 115, 1),
        elevation: 1, // elevation 0으로 처리하면 그림자가 제거됨
        curveSize: 80, // 동그라미를 감싸는 커브 각도
        top: -10,      // 동그라미 사이즈
        height: 60,    // 탭 높이
        items: [
          TabItem(icon: Icons.emoji_people, title: '내 정보'),
          TabItem(icon: Icons.map, title: '길 찾기'),
          TabItem(icon: Icons.settings, title: '설정'),
        ],
        // 어떤 탭 인덱스를 눌렀는지 트리거 처리하여 페이지를 변경함
        onTap: _onTapItem,
      ),
    );
  }
    );}
  void _onTapItem(int index){
    setState(() {
      acc = false;
      selectedPage = index;
      //스와이프
      //_pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.linear);
      _pageController.jumpToPage(index);
      _tabController = TabController(length: _pageList.length, vsync: this, initialIndex: selectedPage);
    });
  }

}
