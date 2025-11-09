import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_api.dart';

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
  final List<String> _types = const ['farmer', 'disposer', 'driver'];
  String? _type;

  // farmer fields
  final _farmName = TextEditingController();
  final _farmLocation = TextEditingController();

  // disposer fields
  final _entity = TextEditingController();
  final _business = TextEditingController();

  // driver fields
  final _licenseId = TextEditingController();

  // driver vehicles (dynamic)
  final List<_VehicleFields> _vehicles = [];

  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _type = _types.first; // default selection
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

    _entity.dispose();
    _business.dispose();

    _licenseId.dispose();

    for (final v in _vehicles) { v.dispose(); }

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
    final u  = _username.text.trim();
    final p  = _password.text;
    final c  = _confirm.text;
    final t  = _type ?? '';

    // basic validation
    if ([fn, ln, cn, u, p, c, t].any((v) => (v is String) ? v.isEmpty : false)) {
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
    String? farmName, farmLocation, entity, business, licenseId;
    List<Map<String, String>> vehicles = [];

    if (t == 'farmer') {
      farmName = _farmName.text.trim();
      farmLocation = _farmLocation.text.trim();
      if (farmName.isEmpty || farmLocation.isEmpty) {
        setState(() => _error = 'Farm name and location are required for farmers');
        return;
      }
    } else if (t == 'disposer') {
      entity = _entity.text.trim();
      business = _business.text.trim();
      if (entity.isEmpty || business.isEmpty) {
        setState(() => _error = 'Entity and business are required for disposers');
        return;
      }
    } else if (t == 'driver') {
      licenseId = _licenseId.text.trim();
      if (licenseId.isEmpty) {
        setState(() => _error = 'Driver name and license ID are required for drivers');
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
          setState(() => _error = 'Vehicle model, class, and plate number are required');
          return;
        }
        vehicles.add({
          'model': model,
          'class': klass,
          'plate_number': plate,
        });
      }
    }

    setState(() { _busy = true; _error = null; });
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
        entity: entity,
        business: business,
        // driver
        licenseId: licenseId,
        vehicles: vehicles,
      );
      widget.onRegistered(); // token saved -> authenticated
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                      decoration: InputDecoration(
                        labelText: 'First name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: border,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lastName,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Last name',
                        prefixIcon: const Icon(Icons.badge),
                        border: border,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _contactNumber,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ -]'))],
                decoration: InputDecoration(
                  labelText: 'Contact number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: border,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: border,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: border,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _confirm,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  border: border,
                ),
              ),
              const SizedBox(height: 16),

              // User type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1))))
                    .toList(),
                onChanged: (v) => setState(() => _type = v),
                decoration: InputDecoration(
                  labelText: 'User type',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: border,
                ),
              ),

              const SizedBox(height: 16),

              // Conditional sections
              if (_type == 'farmer') ...[
                TextField(
                  controller: _farmName,
                  decoration: InputDecoration(
                    labelText: 'Farm name',
                    prefixIcon: const Icon(Icons.agriculture_outlined),
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _farmLocation,
                  decoration: InputDecoration(
                    labelText: 'Farm location',
                    prefixIcon: const Icon(Icons.place_outlined),
                    border: border,
                  ),
                ),
              ] else if (_type == 'disposer') ...[
                TextField(
                  controller: _entity,
                  decoration: InputDecoration(
                    labelText: 'Entity',
                    prefixIcon: const Icon(Icons.apartment_outlined),
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _business,
                  decoration: InputDecoration(
                    labelText: 'Business',
                    prefixIcon: const Icon(Icons.business_center_outlined),
                    border: border,
                  ),
                ),
              ] else if (_type == 'driver') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _licenseId,
                  decoration: InputDecoration(
                    labelText: 'License ID',
                    prefixIcon: const Icon(Icons.credit_card_outlined),
                    border: border,
                  ),
                ),
                const SizedBox(height: 16),

                // Vehicles list
                Text('Vehicles', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (int i = 0; i < _vehicles.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VehicleCard(
                      fields: _vehicles[i],
                      onRemove: () => _removeVehicle(i),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: _addVehicle,
                  icon: const Icon(Icons.add),
                  label: const Text('Add vehicle'),
                ),
              ],

              const SizedBox(height: 24),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
  const _VehicleCard({required this.fields, required this.onRemove, super.key});
  final _VehicleFields fields;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fields.model,
                    decoration: InputDecoration(
                      labelText: 'Model',
                      prefixIcon: const Icon(Icons.directions_car_outlined),
                      border: border,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: fields.klass,
                    decoration: InputDecoration(
                      labelText: 'Class',
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: border,
                    ),
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
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 -]'))],
                    decoration: InputDecoration(
                      labelText: 'Plate number',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      border: border,
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
