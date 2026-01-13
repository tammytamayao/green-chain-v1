import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api/auth_api.dart';
import 'ui/green_theme.dart'; // <-- adjust path if different

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onRegistered});
  final VoidCallback onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // general
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _contactNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // type
  final List<String> _types = const [
    'farmer',
    'disposer',
    'driver',
    'admin',
    'consumer',
  ];
  String? _type;

  // farmer fields
  final _farmName = TextEditingController();
  final _farmLocation = TextEditingController();

  // disposer fields
  final _business = TextEditingController();
  final _location = TextEditingController();

  // driver fields
  final _licenseId = TextEditingController();

  // admin fields
  final _email = TextEditingController();
  final _organization = TextEditingController();

  // consumer fields
  final _address = TextEditingController();

  // driver vehicles (dynamic)
  final List<_VehicleFields> _vehicles = [];

  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = _types.first; // default selection (farmer)
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _contactNumber.dispose();
    _username.dispose();
    _password.dispose();
    _confirm.dispose();

    _farmName.dispose();
    _farmLocation.dispose();

    _business.dispose();
    _location.dispose();

    _licenseId.dispose();

    _email.dispose();
    _organization.dispose();

    _address.dispose();

    for (final v in _vehicles) {
      v.dispose();
    }
    super.dispose();
  }

  void _addVehicle() {
    setState(() => _vehicles.add(_VehicleFields()));
  }

  void _removeVehicle(int index) {
    setState(() {
      _vehicles[index].dispose();
      _vehicles.removeAt(index);
    });
  }

  Future<void> _doRegister() async {
    final fn = _firstName.text.trim();
    final ln = _lastName.text.trim();
    final cn = _contactNumber.text.trim();
    final u = _username.text.trim();
    final p = _password.text;
    final c = _confirm.text;
    final t = _type ?? '';

    // basic validation
    if ([fn, ln, cn, u, p, c, t].any((v) => v.isEmpty)) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (p != c) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (cn.length < 7) {
      setState(() => _error = 'Contact number looks too short');
      return;
    }

    // type-specific validation
    String? farmName, farmLocation, business, location, licenseId;
    String? email, organization, address;
    List<Map<String, String>> vehicles = [];

    if (t == 'farmer') {
      farmName = _farmName.text.trim();
      farmLocation = _farmLocation.text.trim();
      if (farmName.isEmpty || farmLocation.isEmpty) {
        setState(
          () => _error = 'Farm name and location are required for farmers',
        );
        return;
      }
    } else if (t == 'disposer') {
      business = _business.text.trim();
      location = _location.text.trim();
      if (business.isEmpty || location.isEmpty) {
        setState(
          () => _error = 'Business and location are required for disposers',
        );
        return;
      }
    } else if (t == 'driver') {
      licenseId = _licenseId.text.trim();
      if (licenseId.isEmpty) {
        setState(() => _error = 'License ID is required for drivers');
        return;
      }
      if (_vehicles.isEmpty) {
        setState(() => _error = 'Please add at least one vehicle');
        return;
      }
      for (final v in _vehicles) {
        final model = v.model.text.trim();
        final klass = v.klass.text.trim();
        final plate = v.plate.text.trim();
        if ([model, klass, plate].any((s) => s.isEmpty)) {
          setState(
            () =>
                _error = 'Vehicle model, class, and plate number are required',
          );
          return;
        }
        vehicles.add({'model': model, 'class': klass, 'plate_number': plate});
      }
    } else if (t == 'admin') {
      email = _email.text.trim();
      organization = _organization.text.trim();
      if (email.isEmpty || organization.isEmpty) {
        setState(
          () => _error = 'Email and organization are required for admins',
        );
        return;
      }
    } else if (t == 'consumer') {
      address = _address.text.trim();
      if (address.isEmpty) {
        setState(() => _error = 'Address is required for consumers');
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await registerUser(
        firstName: fn,
        lastName: ln,
        contactNumber: cn,
        username: u,
        password: p,
        type: t,
        // farmer
        farmName: farmName,
        farmLocation: farmLocation,
        // disposer
        business: business,
        location: location,
        // driver
        licenseId: licenseId,
        vehicles: vehicles,
        // admin
        email: email,
        organization: organization,
        // consumer
        address: address,
      );
      widget.onRegistered(); // token saved -> authenticated
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: GreenTheme.primary, width: 2),
    );

    InputDecoration dec(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: baseBorder,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General name row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstName,
                      textCapitalization: TextCapitalization.words,
                      decoration: dec('First name', Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastName,
                      textCapitalization: TextCapitalization.words,
                      decoration: dec('Last name', Icons.badge),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _contactNumber,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ -]')),
                ],
                decoration: dec('Contact number', Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _username,
                decoration: dec('Username', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _password,
                obscureText: true,
                decoration: dec('Password', Icons.lock_outline),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: dec('Confirm password', Icons.lock_reset),
              ),
              const SizedBox(height: 16),

              // User type dropdown
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: _types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t[0].toUpperCase() + t.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v),
                decoration: dec('User type', Icons.category_outlined),
              ),

              const SizedBox(height: 16),

              // Conditional sections
              if (_type == 'farmer') ...[
                TextField(
                  controller: _farmName,
                  decoration: dec('Farm name', Icons.agriculture_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _farmLocation,
                  decoration: dec('Farm location', Icons.place_outlined),
                ),
              ] else if (_type == 'disposer') ...[
                TextField(
                  controller: _business,
                  decoration: dec(
                    'Business name',
                    Icons.business_center_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _location,
                  decoration: dec('Business location', Icons.place_outlined),
                ),
              ] else if (_type == 'driver') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _licenseId,
                  decoration: dec('License ID', Icons.credit_card_outlined),
                ),
                const SizedBox(height: 16),

                // Vehicles list
                Text(
                  'Vehicles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _vehicles.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VehicleCard(
                      fields: _vehicles[i],
                      onRemove: () => _removeVehicle(i),
                      focusedBorder: focusedBorder,
                      enabledBorder: enabledBorder,
                      baseBorder: baseBorder,
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _addVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Add vehicle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GreenTheme.primary,
                    side: const BorderSide(color: GreenTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ] else if (_type == 'admin') ...[
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: dec('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _organization,
                  decoration: dec('Organization', Icons.apartment_outlined),
                ),
              ] else if (_type == 'consumer') ...[
                TextField(
                  controller: _address,
                  decoration: dec('Address', Icons.home_outlined),
                ),
              ],

              const SizedBox(height: 24),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              _busy
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _doRegister,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GreenTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Helper classes/widgets for vehicle entries ----------

class _VehicleFields {
  final model = TextEditingController();
  final klass = TextEditingController();
  final plate = TextEditingController();

  void dispose() {
    model.dispose();
    klass.dispose();
    plate.dispose();
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.fields,
    required this.onRemove,
    required this.baseBorder,
    required this.enabledBorder,
    required this.focusedBorder,
  });
  final _VehicleFields fields;
  final VoidCallback onRemove;

  final OutlineInputBorder baseBorder;
  final OutlineInputBorder enabledBorder;
  final OutlineInputBorder focusedBorder;

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: baseBorder,
      enabledBorder: enabledBorder,
      focusedBorder: focusedBorder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fields.model,
                    decoration: _dec('Model', Icons.directions_car_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: fields.klass,
                    decoration: _dec('Class', Icons.category_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fields.plate,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9 -]'),
                      ),
                    ],
                    decoration: _dec(
                      'Plate number',
                      Icons.confirmation_number_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove vehicle',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
