import 'package:flutter/material.dart';
import 'package:nibret/models/home_loan.dart';
import 'package:nibret/services/home_loan_api.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _loadProperties();
  }

  Future<void> _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
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
        body: Center(
            child: CircularProgressIndicator(
          color: Color.fromARGB(255, 13, 71, 161),
        )),
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
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 13, 71, 161),
                      ),
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
                                fontFamily: 'Montserrat',
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
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: _property!.criteria?.length,
                                    itemBuilder: (context, index) {
                                      final c = _property!.criteria?[index];
                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '-> ${c!.description}',
                                              style: const TextStyle(
                                                color: Color(0xFF252525),
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 6)
                                          ]);
                                    },
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Contact Information",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: Color(0xFF252525),
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _property?.loaner.name ?? "",
                                        style: const TextStyle(
                                          color: Color(0xFF252525),
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      InkWell(
                                        onTap: () => _launchPhoneDialer(
                                            _property?.loaner.phone ?? ""),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.phone,
                                                color: Color(0xFF252525)),
                                            const SizedBox(width: 8),
                                            Text(
                                              _property?.loaner.phone ?? "",
                                              style: const TextStyle(
                                                color: Color(0xFF252525),
                                                fontSize: 16,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
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
