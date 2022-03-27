import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../bicycleRoad.dart';
import 'SeoulRoad/JongRo.dart';
import 'SeoulRoad/GangNam.dart';
import 'SeoulRoad/Yeongdeungpo.dart';
import 'SeoulRoad/Mapo.dart';

class Road1 extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _Road1();
}

class _Road1 extends State<Road1> with TickerProviderStateMixin{

  final AreaList = ['종로구', '강남구', '영등포구', '마포구'];
  var _selectedArea = '종로구';

  int selectedPage = 0;

  late TabController _tabController;
  late PageController _pageController;
  late List<Widget> _AreaList;

  @override
  void initState(){
    _AreaList = [JongRo(), GangNam(), Yeongdeungpo(), Mapo()];

    _pageController = PageController(initialPage: selectedPage);
    _tabController = TabController(length: _AreaList.length, vsync: this, initialIndex: selectedPage);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container( // drop down menu
            height: 70.0,
            alignment: Alignment.centerLeft,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    child: Text(
                      "서울특별시",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Container(
                    child: DropdownButton(
                      value: _selectedArea,
                      items: AreaList.map(
                            (value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedArea = value as String;
                          switch (_selectedArea) {
                            case '종로구':
                              selectedPage = 0;
                              break;
                            case '강남구':
                              selectedPage = 1;
                              break;
                            case '영등포구':
                              selectedPage = 2;
                              break;
                            case '마포구':
                              selectedPage = 3;
                              break;
                          }
                          _pageController.jumpToPage(selectedPage);
                          _tabController = TabController(length: _AreaList.length, vsync: this,
                              initialIndex: selectedPage);
                        });
                      },
                    ),
                  ),
                ],
              )
            ),
          ),
          Divider(
            height: 1,
          ),
          Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: PageView(
                  controller: _pageController,
                  children: _AreaList,
                  onPageChanged: (index) {
                    setState(() {
                      selectedPage = index;
                      _pageController.jumpToPage(index);
                    });
                  },
                ),
//                ListView(
//                  children: <Widget>[
//                    ListTile(
//                      leading: Icon(Icons.person),
//                      title: Text("test"),
//                    ),
//                    Divider(
//                      height: 1,
//                    ),
//                    ListTile(
//                      leading: Icon(Icons.person),
//                      title: Text("test2"),
//                    ),
//                    Divider(
//                      height: 1,
//                    ),
//                  ],
//                )
              ),
          ),
        ],
      )
    );
  }

}