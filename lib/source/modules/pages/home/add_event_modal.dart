import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Formata automaticamente para HH:MM
class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;
    if (text.length == 2 && oldValue.text.length < text.length) {
      text += ':';
    }
    if (text.length > 5) {
      text = text.substring(0, 5);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class AddEventModal extends StatefulWidget {
  final VoidCallback onEventAdded;
  const AddEventModal({super.key, required this.onEventAdded});

  @override
  State<AddEventModal> createState() => _AddEventModalState();
}

class _AddEventModalState extends State<AddEventModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  DateTime? _selectedDate;
  bool _loading = false;

  // Google Places API Key (substitua pela sua chave)
  final String _googleApiKey = 'AIzaSyBo41Vvwpnqnn0ctCZuJeZkg9mpHIyVyBI';
  List<dynamic> _addressSuggestions = [];
  double? _selectedLat;
  double? _selectedLng;
  String? _selectedAddress;
  GoogleMapController? _mapController;

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedLat == null ||
        _selectedLng == null ||
        _selectedAddress == null) return;
    setState(() => _loading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não logado');
      final docRef = await FirebaseFirestore.instance.collection('events').add({
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'location': _selectedAddress,
        'latitude': _selectedLat,
        'longitude': _selectedLng,
        'time': _timeController.text.trim(),
        'date': _selectedDate,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Atualizar o documento com seu próprio ID
      await docRef.update({
        'id': docRef.id,
      });
      widget.onEventAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _getAddressSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() => _addressSuggestions = []);
      return;
    }
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_googleApiKey&language=pt-BR';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _addressSuggestions = data['predictions'];
      });
    }
  }

  Future<void> _selectAddress(String placeId, String description) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey&language=pt-BR';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      setState(() {
        _selectedLat = location['lat'];
        _selectedLng = location['lng'];
        _selectedAddress = description;
        _locationController.text = description;
        _addressSuggestions = [];
      });
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(
          LatLng(_selectedLat!, _selectedLng!),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar Evento',
                style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'CodeProLC',
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Evento'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo do Evento'),
                items: const [
                  DropdownMenuItem(value: 'lazer', child: Text('Lazer')),
                  DropdownMenuItem(value: 'musica', child: Text('Música')),
                  DropdownMenuItem(value: 'comida', child: Text('Comida')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o tipo' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Endereço'),
                onChanged: _getAddressSuggestions,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o endereço' : null,
              ),
              if (_addressSuggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _addressSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _addressSuggestions[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFFFF5800).withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: ListTile(
                          title: Text(
                            suggestion['description'],
                            style: TextStyle(
                              color: index == 0
                                  ? const Color(0xFFFF5800)
                                  : Colors.black,
                              fontWeight: index == 0
                                  ? FontWeight.normal
                                  : FontWeight.normal,
                            ),
                          ),
                          onTap: () => _selectAddress(suggestion['place_id'],
                              suggestion['description']),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              if (_selectedLat != null && _selectedLng != null)
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_selectedLat!, _selectedLng!),
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: LatLng(_selectedLat!, _selectedLng!),
                        infoWindow: InfoWindow(title: _selectedAddress ?? ''),
                      ),
                    },
                    onMapCreated: (controller) => _mapController = controller,
                    zoomControlsEnabled: false,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Horário'),
                maxLength: 5,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                  LengthLimitingTextInputFormatter(5),
                  TimeTextInputFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o horário';
                  if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(v)) {
                    return 'Formato deve ser HH:MM';
                  }
                  int hh = int.tryParse(v.substring(0, 2)) ?? -1;
                  int mm = int.tryParse(v.substring(3, 5)) ?? -1;
                  if (hh < 0 || hh > 23) {
                    return 'Hora deve ser entre 00 e 23';
                  }
                  if (mm < 0 || mm > 59) {
                    return 'Minutos devem ser entre 00 e 59';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedDate == null
                        ? 'Selecione a data'
                        : 'Data: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5800),
                    foregroundColor: Colors.white,
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Salvar Evento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
