import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nibret/screens/login_screen.dart';
import 'package:nibret/services/auth_service.dart';
import 'package:nibret/services/tour_service.dart';
import 'package:toastification/toastification.dart';

class RequestTour extends StatefulWidget {
  final String propertyId;
  final bool property;

  const RequestTour(
      {super.key, required this.propertyId, this.property = false});

  @override
  State<RequestTour> createState() => _RequestTourState();
}

class _RequestTourState extends State<RequestTour> {
  final _formKey = GlobalKey<FormState>();
  final TourApiService _tourApiService = TourApiService();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final String _communicationPreference = 'Phone';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ));
    }
  }

  Future<void> _selectDate(context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (BuildContext context, Widget? widget) => Theme(
        data: ThemeData(
          colorScheme:
              const ColorScheme.light(primary: Color.fromARGB(255, 5, 79, 207)),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Colors.white,
            dividerColor: Color.fromARGB(255, 5, 79, 207),
            headerBackgroundColor: Color.fromARGB(255, 5, 79, 207),
            headerForegroundColor: Colors.white,
          ),
        ),
        child: widget!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitTourRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final DateTime tourDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime?.hour ?? 12,
        _selectedTime?.minute ?? 0,
      );

      await _tourApiService.requestTour(
        propertyId: widget.propertyId,
        tourDate: tourDateTime,
        notes: _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context);
        _showToast('Tour request submitted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showToast(e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    toastification.show(
        type: !isError ? ToastificationType.success : ToastificationType.error,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 5),
        title: Text(message),
        animationDuration: const Duration(milliseconds: 300),
        alignment: Alignment.bottomRight);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Tour'),
        backgroundColor: Colors.transparent,
        elevation: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Preferred Date & Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedDate == null
                            ? 'Select Date and Time'
                            : '${DateFormat('MMM dd, yyyy').format(_selectedDate!)} ${_selectedTime?.format(context) ?? ''}',
                      ),
                      onTap: () => _selectDate(context),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.blue[900],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                validator: (value) {
                  if (_communicationPreference == 'Phone' &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Colors.blue[900],
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.grey),
                  focusColor: Colors.blue[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
                  if (_communicationPreference == 'Email' &&
                      (value == null || value.isEmpty)) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                cursorColor: Colors.blue[900],
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTourRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0XFF163C9F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Tour Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
