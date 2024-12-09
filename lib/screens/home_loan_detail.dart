import 'package:flutter/material.dart';
import 'package:nibret/models/home_loan.dart';
import 'package:nibret/services/home_loan_api.dart';

class LoanDetail extends StatefulWidget {
  final String propertyId;
  const LoanDetail(String id, {super.key, required this.propertyId});

  @override
  State<LoanDetail> createState() => _LoanDetailState();
}

class _LoanDetailState extends State<LoanDetail> with TickerProviderStateMixin {
  final HomeLoanApiService _apiService = HomeLoanApiService();
  LoanResponse? _property;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final property = await _apiService.getHomeLoan(widget.propertyId);

      if (!mounted) return;

      setState(() {
        _property = property;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Oops,Something went wrong.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('$_error')),
      );
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_property!.name),
        ),
        body: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: _loadProperties,
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _property!.description,
                              style: const TextStyle(
                                color: Color(0xFF252525),
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (_property!.criteria!.isNotEmpty)
                              Column(
                                children: [
                                  const Text(
                                    "Criterias",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color(0xFF252525),
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: _property!.criteria?.length,
                                      itemBuilder: (context, index) {
                                        final c = _property!.criteria?[index];
                                        return Column(children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.check_circle_outline),
                                              Text(
                                                c!.description,
                                                style: const TextStyle(
                                                  color: Color(0xFF252525),
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 6)
                                        ]);
                                      },
                                    ),
                                  )
                                ],
                              )
                            else
                              const SizedBox(height: 16)
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
