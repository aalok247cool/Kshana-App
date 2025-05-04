// File: lib/pages/kyc_page.dart
import 'package:flutter/material.dart';

// Trust Score status enum
enum KycStatus {
  notVerified,     // Red
  partiallyVerified, // Yellow
  fullyVerified,   // Green
}

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  _KycPageState createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  // Current step in the KYC process
  int _currentStep = 0;

  // Form keys for each step
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();

  // Controllers for personal info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  // Controllers for address
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Selected document type
  String _selectedDocType = 'Aadhaar Card';
  final List<String> _documentTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Voter ID',
    'Passport',
    'Driving License',
  ];

  // Date picker
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Select date method
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime(DateTime.now().year - 18, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Color(0xFF303030),
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF212121)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Go to next step
  void _nextStep() {
    if (_currentStep == 0) {
      if (_personalInfoFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      }
    } else if (_currentStep == 1) {
      // Document step doesn't require validation
      setState(() {
        _currentStep += 1;
      });
    } else if (_currentStep == 2) {
      if (_addressFormKey.currentState!.validate()) {
        setState(() {
          _currentStep += 1;
        });
      }
    }
  }

  // Go to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // Submit KYC
  void _submitKyc() {
    // Here you'd normally send the data to your backend
    // For now, we'll just show a success dialog

    // Example of updating the trust score (in a real app, this would come from your backend)
    // Here you would update your user provider or state management
    // Example: Provider.of<UserProvider>(context, listen: false).updateKycStatus(KycStatus.fullyVerified);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'KYC Submitted Successfully',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Your KYC details have been submitted for verification. This process may take 24-48 hours. You will be notified once verification is complete.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'KYC Verification',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stepper(
        type: StepperType.vertical,
        physics: const ScrollPhysics(),
        currentStep: _currentStep,
        onStepTapped: (step) {
          setState(() {
            _currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.amber),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? _submitKyc : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _currentStep == 3 ? 'Submit' : 'Continue',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Personal Information
          Step(
            title: const Text('Personal Information', style: TextStyle(color: Colors.white)),
            content: Form(
              key: _personalInfoFormKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    hint: 'Enter your mobile number',
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    hint: 'DD/MM/YYYY',
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),

          // Step 2: Document Verification
          Step(
            title: const Text('Identity Document', style: TextStyle(color: Colors.white)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Document Type',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDocType,
                      isExpanded: true,
                      dropdownColor: Colors.grey.shade900,
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                      items: _documentTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDocType = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDocumentUploadSection(
                  title: 'Front Side of Document',
                  description: 'Upload a clear photo of the front side',
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadSection(
                  title: 'Back Side of Document',
                  description: 'Upload a clear photo of the back side',
                ),
                const SizedBox(height: 16),
                _buildDocumentUploadSection(
                  title: 'Selfie with Document',
                  description: 'Hold your ID next to your face',
                ),
              ],
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),

          // Step 3: Address Verification
          Step(
            title: const Text('Address Verification', style: TextStyle(color: Colors.white)),
            content: Form(
              key: _addressFormKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _addressLine1Controller,
                    label: 'Address Line 1',
                    hint: 'House/Flat No., Building Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressLine2Controller,
                    label: 'Address Line 2',
                    hint: 'Street, Area, Landmark',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Enter your city',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'Enter your state',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your state';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _pincodeController,
                    label: 'PIN Code',
                    hint: 'Enter 6-digit PIN code',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your PIN code';
                      }
                      if (value.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid 6-digit PIN code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDocumentUploadSection(
                    title: 'Address Proof Document',
                    description: 'Upload a utility bill or bank statement (not older than 3 months)',
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),

          // Step 4: Review & Submit
          Step(
            title: const Text('Review & Submit', style: TextStyle(color: Colors.white)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewSection(
                  title: 'Personal Information',
                  items: [
                    'Name: ${_nameController.text.isEmpty ? 'Not provided' : _nameController.text}',
                    'Email: ${_emailController.text.isEmpty ? 'Not provided' : _emailController.text}',
                    'Phone: ${_phoneController.text.isEmpty ? 'Not provided' : _phoneController.text}',
                    'Date of Birth: ${_dobController.text.isEmpty ? 'Not provided' : _dobController.text}',
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewSection(
                  title: 'Identity Document',
                  items: [
                    'Document Type: $_selectedDocType',
                    'Front Side: Uploaded',
                    'Back Side: Uploaded',
                    'Selfie with Document: Uploaded',
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewSection(
                  title: 'Address Information',
                  items: [
                    'Address: ${_addressLine1Controller.text.isEmpty ? 'Not provided' : _addressLine1Controller.text}',
                    'City: ${_cityController.text.isEmpty ? 'Not provided' : _cityController.text}',
                    'State: ${_stateController.text.isEmpty ? 'Not provided' : _stateController.text}',
                    'PIN Code: ${_pincodeController.text.isEmpty ? 'Not provided' : _pincodeController.text}',
                    'Address Proof: Uploaded',
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Declaration',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'I hereby declare that all the information provided by me is true and correct to the best of my knowledge. I understand that any false statement may result in the rejection of my application and possibly legal action.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
          ),
        ],
      ),
    );
  }

  // Helper widget for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // Helper widget for document upload sections
  Widget _buildDocumentUploadSection({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: InkWell(
            onTap: () {
              // TODO: Implement image picking functionality
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to upload',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for review sections
  Widget _buildReviewSection({
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              item,
              style: TextStyle(color: Colors.grey.shade300),
            ),
          )),
        ],
      ),
    );
  }
}

// Widget for trust score indicator that you'll use in dashboard
class TrustScoreIndicator extends StatelessWidget {
  final KycStatus kycStatus;

  const TrustScoreIndicator({
    super.key,
    required this.kycStatus,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData iconData = Icons.verified;

    switch (kycStatus) {
      case KycStatus.fullyVerified:
        backgroundColor = Colors.green;
        break;
      case KycStatus.partiallyVerified:
        backgroundColor = Colors.amber;
        break;
      case KycStatus.notVerified:
        backgroundColor = Colors.red;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

// KYC alert banner to replace the one in your dashboard
class KycAlertBanner extends StatelessWidget {
  const KycAlertBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KYC required before redemption.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KycPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Please verify your identity.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}