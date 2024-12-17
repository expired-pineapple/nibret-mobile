import 'package:flutter/material.dart';
import 'package:nibret/models/home_loan.dart';
import 'package:nibret/screens/home_loan_detail.dart';
import 'package:nibret/services/home_loan_api.dart';
import 'package:nibret/widgets/expandable_text.dart';

class HomeLoan extends StatefulWidget {
  const HomeLoan({super.key});

  @override
  State<HomeLoan> createState() => _HomeLoanScreenState();
}

class _HomeLoanScreenState extends State<HomeLoan> {
  final HomeLoanApiService _apiService = HomeLoanApiService();
  final List<LoanResponse> _items = [];
  final ScrollController _scrollController = ScrollController();

  String? _next;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String _searchQuery = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHomeLoans();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadHomeLoans();
      }
    }
  }

  Future<void> _loadHomeLoans() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getHomeLoans(
        next: _next,
        searchQuery: _searchQuery,
      );

      final List<dynamic> jsonList = data['results'];
      final newItems =
          jsonList.map((json) => LoanResponse.fromJson(json)).toList();
      setState(() {
        if (newItems.isEmpty) {
          _hasMoreData = false;
        } else {
          _items.addAll(newItems);
          _next = data['next'];
          _hasMoreData = data['next'] != null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong.";
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _hasMoreData = true;
      _error = null;
    });
    await _loadHomeLoans();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _items.clear();
      _hasMoreData = true;
    });
    _loadHomeLoans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0668FE),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 18, 20),
            color: const Color(0xFF0668FE),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.33),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white),
                  ),
                  child: TextField(
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search loans',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _items.length) {
                            if (_isLoading) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (!_isLoading && _items.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('No home loans available'),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final item = _items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide()),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoanDetail(
                                            item.id,
                                            propertyId: item.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ExpandableText(
                                    text: item.description,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.loaner.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              item.loaner.phone,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }
}
