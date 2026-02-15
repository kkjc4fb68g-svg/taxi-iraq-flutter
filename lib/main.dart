import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const TaxiIraqApp());
}

class TaxiIraqApp extends StatelessWidget {
  const TaxiIraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi Iraq',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;

  final TextEditingController destinationController =
      TextEditingController();

  final LatLng baghdad = const LatLng(33.3152, 44.3661);

  double? fare;
  bool searching = false;

  double calculateFare(double km) {
    const baseFare = 2000;
    const perKm = 1000;
    return baseFare + (km * perKm);
  }

  void requestRide() {
    setState(() {
      fare = calculateFare(6); // مسافة تقريبية
    });
  }

  void confirmRide() {
    setState(() {
      searching = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        searching = false;
        fare = null;
        destinationController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚕 تم العثور على تكسي")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: searching
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text("جاري البحث عن أقرب تكسي..."),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: baghdad,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                ),

                // Bottom Card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: destinationController,
                          decoration: InputDecoration(
                            hintText: "وين تحب تروح؟",
                            prefixIcon: const Icon(Icons.place),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (fare == null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: requestRide,
                              child: const Text("احسب السعر"),
                            ),
                          ),

                        if (fare != null) ...[
                          const SizedBox(height: 12),
                          Text("المسافة التقريبية: 6 كم"),
                          const SizedBox(height: 4),
                          Text(
                            "السعر المتوقع: ${fare!.toInt()} دينار",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: confirmRide,
                              child: const Text("تأكيد الطلب"),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
