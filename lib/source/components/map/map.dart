import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  GoogleMapController? _controller;
  CameraPosition? _inicial;
  Set<Marker> _marcadores = {
    const Marker(
      markerId: MarkerId('centro-sp'),
      position: LatLng(-23.55052, -46.63331),
      infoWindow: InfoWindow(title: 'Centro de SP'),
    ),
  };

  BitmapDescriptor? _iconLazer;
  BitmapDescriptor? _iconMusica;
  BitmapDescriptor? _iconComida;

  Future<void> _loadIcons() async {
    final config = const ImageConfiguration(size: Size(48, 48));
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
    setState(() {});
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
      setState(() {
        _inicial = CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 14,
        );
      });
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newLatLng(
          LatLng(pos.latitude, pos.longitude),
        ));
      }
    } catch (e) {
      setState(() {
        _inicial = CameraPosition(
          target: LatLng(-23.55052, -46.63331),
          zoom: 12,
        );
      });
    }
  }

  Future<void> _buscarEventos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('events').get();
    final marcadores = <Marker>{
      const Marker(
        markerId: MarkerId('centro-sp'),
        position: LatLng(-23.55052, -46.63331),
        infoWindow: InfoWindow(title: 'Centro de SP'),
      ),
    };
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
            infoWindow: InfoWindow(title: data['name'] ?? 'Evento'),
            icon: icon,
          ),
        );
      }
    }
    setState(() {
      _marcadores = marcadores;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _inicial == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _inicial!,
              onMapCreated: (c) => _controller = c,
              markers: _marcadores,
              myLocationEnabled:
                  true, // Mostra o ponto azul (precisa permissão)
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapType: MapType.normal,
            ),
    );
  }
}
