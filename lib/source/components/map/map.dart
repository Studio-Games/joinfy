import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

  Map<String, dynamic>? _eventoSelecionado;
  double _modalOffsetY = 0;
  bool _isClosing = false;
class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  Timer? _pulseLoadingTimer;
  int _pulseLoadingIndex = 0;
  Timer? _loadingTimer;
  int _loadingRouteIndex = 0;
  List<LatLng> _loadingRoutePoints = [];
  Timer? _pulseTimer;
  bool _showPulse = false;
  List<LatLng> _lastRoutePoints = [];
  List<LatLng> _decodePolyline(String polyline) {
  final List<LatLng> route = [];
  int index = 0;
  int latitude = 0;
  int longitude = 0;

  while (index < polyline.length) {
    int shift = 0;
    int result = 0;
    int byte;

    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    latitude += deltaLat;

    shift = 0;
    result = 0;
    do {
      byte = polyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    longitude += deltaLng;

    route.add(LatLng(latitude / 1e5, longitude / 1e5));
  }
  return route;
}

  final String _googleApiKey = 'AIzaSyBo41Vvwpnqnn0ctCZuJeZkg9mpHIyVyBI';
  Future<void> _abrirRotaGoogleMaps() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      final destinoLat = _eventoSelecionado?["latitude"];
      final destinoLng = _eventoSelecionado?["longitude"];
      if (destinoLat != null && destinoLng != null) {
        final url =
            'https://www.google.com/maps/dir/?api=1&origin=${pos.latitude},${pos.longitude}&destination=$destinoLat,$destinoLng&travelmode=driving';
  await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
  GoogleMapController? _controller;
  CameraPosition? _inicial;
  Set<Marker> _marcadores = {};
  Set<Polyline> _polylines = {};

  BitmapDescriptor? _iconLazer;
  BitmapDescriptor? _iconMusica;
  BitmapDescriptor? _iconComida;

  double _modalSlideOffset = 1;

  Future<void> _loadIcons() async {
    const config = ImageConfiguration(size: Size(48, 48));
    _iconLazer = await BitmapDescriptor.fromAssetImage(
      config,
      'assets/icons/lazer-icon.png',
    );
    _iconMusica = await BitmapDescriptor.fromAssetImage(
      config,
      'assets/icons/musica-icon.png',
    );
    _iconComida = await BitmapDescriptor.fromAssetImage(
      config,
      'assets/icons/food-icon.png',
    );
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _definirLocalizacaoInicial();
    _buscarEventos();
  }

  Future<void> _definirLocalizacaoInicial() async {
    try {
      await Geolocator.requestPermission();
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _inicial = CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 14,
          );
        });
      }
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLng(
          LatLng(pos.latitude, pos.longitude),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _inicial = const CameraPosition(
            target: LatLng(-23.55052, -46.63331),
            zoom: 12,
          );
        });
      }
    }
  }

  Future<void> _buscarEventos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    final marcadores = <Marker>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['latitude'] != null && data['longitude'] != null) {
        BitmapDescriptor icon;
        switch (data['type']) {
          case 'lazer':
            icon = _iconLazer ?? BitmapDescriptor.defaultMarker;
            break;
          case 'musica':
            icon = _iconMusica ?? BitmapDescriptor.defaultMarker;
            break;
          case 'comida':
            icon = _iconComida ?? BitmapDescriptor.defaultMarker;
            break;
          default:
            icon = BitmapDescriptor.defaultMarker;
        }
        marcadores.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(data['latitude'], data['longitude']),
            icon: icon,
            onTap: () async {
              if (mounted) {
                setState(() {
                  _eventoSelecionado = data;
                  _modalSlideOffset = 1; // Começa fora da tela
                });
                Future.delayed(const Duration(milliseconds: 10), () {
                  if (mounted) {
                    setState(() {
                      _modalSlideOffset = 0; // Anima para dentro
                    });
                  }
                });
                // Traçar linha real usando Directions API
                try {
                  final pos = await Geolocator.getCurrentPosition();
                  final destinoLat = data["latitude"];
                  final destinoLng = data["longitude"];
                  if (destinoLat != null && destinoLng != null) {
                    final url =
                        'https://maps.googleapis.com/maps/api/directions/json?origin=${pos.latitude},${pos.longitude}&destination=$destinoLat,$destinoLng&key=$_googleApiKey&mode=driving';
                    final response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      final json = jsonDecode(response.body);
                      final points = _decodePolyline(
                        json["routes"][0]["overview_polyline"]["points"],
                      );
                      _lastRoutePoints = points;
                      _loadingRoutePoints = points;
                      _loadingRouteIndex = 1;
                      _loadingTimer?.cancel();
                      // Duração total da animação (em ms)
                      const totalDuration = 2000;
                      final stepDuration = (totalDuration / points.length).clamp(10, 100).toInt();
                      _loadingTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
                        if (_loadingRouteIndex < points.length) {
                          setState(() {
                            final polylineMain = Polyline(
                              polylineId: const PolylineId('rota_usuario_evento'),
                              color: const Color(0xFFFF5800),
                              width: 6,
                              points: points.sublist(0, _loadingRouteIndex),
                            );
                            _polylines = {polylineMain};
                            _loadingRouteIndex++;
                          });
                        } else {
                          setState(() {
                            final polylineMain = Polyline(
                              polylineId: const PolylineId('rota_usuario_evento'),
                              color: const Color(0xFFFF5800),
                              width: 4,
                              points: points,
                            );
                            final polylinePulse = Polyline(
                              polylineId: const PolylineId('rota_usuario_pulse'),
                              color: const Color.fromARGB(255, 255, 200, 170),
                              width: 2,
                              points: points,
                              visible: _showPulse,
                            );
                            _polylines = {polylineMain, polylinePulse};
                          });
                          timer.cancel();
                          // Inicia o pulso normalmente
                          _pulseLoadingTimer?.cancel();
                          void startPulseLoading() {
                            _pulseLoadingIndex = 1;
                            final points = _lastRoutePoints;
                            const pulseDuration = 1200; // ms
                            final stepDuration = (pulseDuration / points.length).clamp(10, 80).toInt();
                            _pulseLoadingTimer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
                              if (_pulseLoadingIndex < points.length) {
                                setState(() {
                                  final polylineMain = Polyline(
                                    polylineId: const PolylineId('rota_usuario_evento'),
                                    color: const Color(0xFFFF5800),
                                    width: 4,
                                    points: points,
                                  );
                                  final polylinePulse = Polyline(
                                    polylineId: const PolylineId('rota_usuario_pulse'),
                                    color: const Color.fromARGB(255, 255, 200, 170),
                                    width: 2,
                                    points: points.sublist(0, _pulseLoadingIndex),
                                    visible: true,
                                  );
                                  _polylines = {polylineMain, polylinePulse};
                                  _pulseLoadingIndex++;
                                });
                              } else {
                                timer.cancel();
                                Future.delayed(const Duration(seconds: 3), () {
                                  if (mounted) startPulseLoading();
                                });
                              }
                            });
                          }
                          startPulseLoading();
                        }
                      });
                    }
                  }
                } catch (e) {
                  // ignore
                }
              }
            },
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _marcadores = marcadores;
      });
    }
  }

  void _closeEventModal() {
  _pulseLoadingTimer?.cancel();
  _loadingTimer?.cancel();
  _pulseTimer?.cancel();
  _showPulse = false;
    if (mounted) {
      setState(() {
        _isClosing = true;
        _modalSlideOffset = 1;
        _polylines = {};
      });
    }
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _eventoSelecionado = null;
          _modalOffsetY = 0;
          _isClosing = false;
        });
      }
    });
  }

  Future<void> _setMapStyle(BuildContext context) async {
    final style = await DefaultAssetBundle.of(context).loadString('assets/map/map_style.json');
    _controller?.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          _inicial == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                          initialCameraPosition: _inicial!,
                          onMapCreated: (c) {
                            _controller = c;
                            _setMapStyle(context);
                          },
                          markers: _marcadores,
                          polylines: _polylines,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          zoomGesturesEnabled: true,
                          mapToolbarEnabled: false,
                        ),
          if (_eventoSelecionado != null)
            GestureDetector(
              onTap: _closeEventModal,
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Stack(
                  children: [
                    Positioned(
                      left: mq.size.width * 0.02,
                      bottom: 20,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          setState(() {
                            _modalOffsetY += details.delta.dy;
                          });
                        },
                        onVerticalDragEnd: (details) {
                          if (_modalOffsetY > 40) {
                            _closeEventModal();
                          } else {
                            setState(() {
                              _modalOffsetY = 0;
                            });
                          }
                        },
                        child: AnimatedSlide(
                          offset: Offset(0, _isClosing ? 1 : (_modalOffsetY / 160).clamp(0, 1) + _modalSlideOffset),
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: mq.size.width * 0.96,
                              height: 230,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Informações
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 6),
                                              Text(
                                                _eventoSelecionado!['name'] ?? 'Evento',
                                                style: const TextStyle(
                                                  fontFamily: 'CodeProLC',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF23234A),
                                                ),
                                              ),
                                              const SizedBox(height: 14),
                                              Row(
                                                children: [
                                                  Text(
                                                    (_eventoSelecionado!['rating']?.toString() ?? '4,0'),
                                                    style: const TextStyle(fontSize: 15, color: Color(0xFF23234A)),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Row(
                                                    children: List.generate(5, (i) {
                                                      double rating = double.tryParse(_eventoSelecionado!['rating']?.toString() ?? '4.0') ?? 4.0;
                                                      return Icon(
                                                        i < rating ? Icons.star : Icons.star_border,
                                                        size: 18,
                                                        color: Color(0xFF23234A),
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                _eventoSelecionado!['type'] ?? 'Restaurante',
                                                style: const TextStyle(fontFamily: 'CodeProLC', fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF23234A)),
                                              ),
                                              Row(
                                                children: [
                                                  const Text(
                                                    'Aberto',
                                                    style: TextStyle(fontFamily: 'CodeProLC', fontSize: 15, color: Color(0xFF2ED47A), fontWeight: FontWeight.w400),
                                                  ),
                                                  const Text(' • ', style: TextStyle(fontSize: 15, color: Color(0xFF23234A))),
                                                  Text(
                                                    'Fecha às ${_eventoSelecionado!['closeTime'] ?? '23:30'}',
                                                    style: const TextStyle(fontFamily: 'CodeProLC', fontSize: 15, color: Color(0xFF23234A)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              SizedBox(
                                                width: 180,
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFF5800),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(24),
                                                    ),
                                                  ),
                                                  icon: const Icon(Icons.navigation, color: Colors.white),
                                                  label: const Text('Ir agora', style: TextStyle(fontFamily: 'CodeProLC', fontSize: 16, color: Colors.white)),
                                                  onPressed: _abrirRotaGoogleMaps,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Imagem
                                        if (_eventoSelecionado!['imageUrl'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 36),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Image.network(
                                                _eventoSelecionado!['imageUrl'],
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: -2,
                                    left: (mq.size.width * 0.9) / 2 - 16,
                                    child: const Icon(Icons.keyboard_arrow_up, size: 32, color: Color(0xFF23234A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
