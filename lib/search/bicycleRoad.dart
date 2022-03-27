import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'searchRoute.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'Road/Road1.dart';
import 'Road/Road2.dart';


class BicycleRoad extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _BicycleRoad();
}

class _BicycleRoad extends State<BicycleRoad> with TickerProviderStateMixin{

  late TabController _tabController;
  void initState() {
    _tabController =
        new TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              Material(
                color: Colors.black12,
                child: TabBar(
                  unselectedLabelColor: Colors.black54,
                  labelColor: Colors.black,
                  indicatorColor: Colors.white,
                  controller: _tabController,
                  labelPadding: const EdgeInsets.all(0.0),
                  tabs: [
                    _getTab(0,
                        Text("\n지역별 보기",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),)),
                    _getTab(1,
                        Text("\n지도로 보기",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),)),
                  ],
                  onTap: _onTap,
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    Road1(),
                    Road2(),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  void _onTap(int index){
    setState(() {
      _selectedTab = index;
      _tabController = TabController(length: 2, vsync: this, initialIndex: _selectedTab);
    });
  }

  _getTab(index, child) {
    return Tab(
      child: SizedBox.expand(
        child: Container(
          child: child,
          decoration: BoxDecoration(
              color: (_selectedTab == index ? Colors.white : Colors.black12)),
        ),
      ),
    );
  }
}