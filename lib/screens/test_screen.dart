import 'package:flutter/material.dart';

class CarouselTabs extends StatefulWidget {
  const CarouselTabs({super.key});

  @override
  _CarouselTabsState createState() => _CarouselTabsState();
}

class _CarouselTabsState extends State<CarouselTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> _tabs = [
    const Tab(text: 'Tab 1'),
    const Tab(text: 'Tab 2'),
    const Tab(text: 'Tab 3'),
    const Tab(text: 'Tab 4'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          physics: const BouncingScrollPhysics(),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const PageScrollPhysics(), // Enables swipe gesture
        children: const [
          // Your tab content widgets
          Center(child: Text('Content 1')),
          Center(child: Text('Content 2')),
          Center(child: Text('Content 3')),
          Center(child: Text('Content 4')),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              if (_tabController.index > 0) {
                _tabController.animateTo(_tabController.index - 1);
              }
            },
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              if (_tabController.index < _tabs.length - 1) {
                _tabController.animateTo(_tabController.index + 1);
              }
            },
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
