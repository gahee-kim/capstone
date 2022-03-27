import 'package:flutter/material.dart';
import 'search.dart';
import '/map.dart';
import 'bicycleRoad.dart';
import 'Accident.dart';
import 'Storage.dart';
import '../main.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';

class SearchRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchRoute();
}

class _SearchRoute extends State<SearchRoute> with TickerProviderStateMixin {

  int selectedPage = 0;
  late TabController _tabController;
  late PageController _pageController;
  late List<Widget> _contents;

  @override
  void initState(){
    _contents = [Search(), BicycleRoad(), Storage(), Accident()];

    setState(() {
      if(acc == true){
        selectedPage = 3;
      }
    });

    _pageController = PageController(initialPage: selectedPage);
    _tabController = TabController(length: _contents.length, vsync: this, initialIndex: selectedPage);

    super.initState();
  }

  final icon1 = InkWell(
    //splashColor: Colors.green, // splash color
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.add_location, size: 40),
      ],
    ),
  );
  final icon2 = InkWell(
    //splashColor: Colors.green, // splash color
    child: Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.directions_bike, size: 40),
      ],
    ),
  );
  final icon3 = InkWell(
    //splashColor: Colors.green, // splash color
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.security_update_good, size: 40),
      ],
    ),
  );
  final icon4 = InkWell(
    //splashColor: Colors.green, // splash color
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.warning_amber_outlined, size: 40),
      ],
    ),
  );

  void _onTapItem(int index){
    setState(() {
      selectedPage = index;
      //스와이프
      _pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.linear);
      //_pageController.jumpToPage(index);
      _tabController = TabController(length: _contents.length, vsync: this, initialIndex: selectedPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  icon: Icon(Icons.arrow_back),
                ),
                backgroundColor: Color.fromRGBO(45, 78, 115, 1),
                centerTitle: true,
                elevation: 0.0,
                bottom: TabBar(
                  tabs: [
                    Tab(icon: icon1, text: "경로 검색",),
                    Tab(icon: icon2, text: "자전거도로",),
                    Tab(icon: icon3, text: "대여보관소",),
                    Tab(icon: icon4, text: "사고다발지",),
                  ],
                  onTap: _onTapItem,
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Color(0xAAFFFFFF),
                  indicatorColor: Colors.red,
                ),
                title: Text('길 찾기',
                  style: TextStyle(color: Color(0xffffffff)),
                ),
              ),
              body: //_pageOptions[selectedPage],
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: _contents,
                onPageChanged: (index) {
                  setState(() {
                    selectedPage = index;
                  });
                },
            ),
              // TabBarView(
              //   physics: NeverScrollableScrollPhysics(),
              //   children: _contents,
              // ),
            )
        )
    );
  }
}
