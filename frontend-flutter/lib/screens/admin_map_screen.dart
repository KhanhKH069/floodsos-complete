// lib/screens/admin_map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sos_alert_model.dart';
import '../models/drone_model.dart';
import '../services/api_service.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key});
  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  final MapController _mapController = MapController();
  final ApiService _apiService = ApiService();

  final LatLng _defaultCenter = const LatLng(21.0285, 105.8542);

  List<SOSAlertModel> _alerts = [];
  List<DroneModel> _drones = [];
  bool _isLoading = true;
  bool _isMapReady = false;
  bool _showWeatherLayer = true;

  // Định nghĩa vị trí căn cứ
  final Map<String, LatLng> _droneBases = {
    'DR-01': const LatLng(21.0487, 105.8350), // Hồ Tây
    'DR-02': const LatLng(21.0068, 105.7445), // Smart City
    'DR-03': const LatLng(20.9806, 105.8413), // Giáp Bát
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _autoRefresh);
  }

  void _autoRefresh() {
    if (mounted) {
      if (_isMapReady) _loadData();
      Future.delayed(const Duration(seconds: 3), _autoRefresh);
    }
  }

  Future<void> _loadData() async {
    try {
      final alertsFuture = _apiService.getSOSAlerts();
      final dronesFuture = _apiService.getDrones();
      final results = await Future.wait([alertsFuture, dronesFuture]);

      if (mounted) {
        setState(() {
          _alerts = (results[0] as List<SOSAlertModel>)
              .where((a) => a.latitude != 0.0 && a.longitude != 0.0)
              .toList();
          _drones = results[1] as List<DroneModel>;
          _isLoading = false;
        });

        if (_drones.isNotEmpty &&
            _isMapReady &&
            _mapController.camera.zoom < 12) {
          _mapController.move(
              LatLng(_drones[0].latitude, _drones[0].longitude), 13.0);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🟢 NỀN TRẮNG
      appBar: AppBar(
        title: const Text('TRUNG TÂM ĐIỀU PHỐI',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        // Giữ màu xanh đậm cho AppBar để nổi bật trên nền trắng
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: _showDroneList),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 11.0,
              onMapReady: () {
                setState(() => _isMapReady = true);
                _loadData();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // 🟢 FIX LỖI ACCESS BLOCKED: Thêm dòng này
                userAgentPackageName: 'com.floodsos.app',
              ),
              if (_showWeatherLayer)
                TileLayer(
                  urlTemplate:
                      'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=${ApiService.openWeatherApiKey}',
                  // Cũng thêm userAgent cho lớp thời tiết luôn cho chắc
                  userAgentPackageName: 'com.floodsos.app',
                ),

              // VẼ ĐƯỜNG BAY
              PolylineLayer(
                polylines: _drones.where((d) => d.status == 'busy').map((d) {
                  final base = _droneBases[d.id] ?? _defaultCenter;
                  return Polyline(
                    points: [base, LatLng(d.latitude, d.longitude)],
                    strokeWidth: 3.0,
                    color: Colors.purpleAccent,
                  );
                }).toList(),
              ),

              // SOS MARKERS
              MarkerLayer(
                  markers: _alerts.map((s) {
                bool isSafe = s.status == 'safe';
                return Marker(
                  point: LatLng(s.latitude, s.longitude),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showSOSDetails(s),
                    child: Icon(isSafe ? Icons.check_circle : Icons.location_on,
                        color: isSafe ? Colors.green[700] : Colors.red,
                        size: 40),
                  ),
                );
              }).toList()),

              // DRONE MARKERS
              MarkerLayer(
                  markers: _drones.map((d) {
                bool isBusy = d.status == 'busy';
                return Marker(
                  point: LatLng(d.latitude, d.longitude),
                  width: 80,
                  height: 80,
                  child: Column(children: [
                    Container(
                      decoration: BoxDecoration(
                          color: isBusy
                              ? Colors.purple.withValues(alpha: 0.3)
                              : Colors.transparent,
                          shape: BoxShape.circle),
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.airplanemode_active,
                          color:
                              isBusy ? Colors.purpleAccent : Colors.blueAccent,
                          size: 35),
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black26),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        child: Text(d.name,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)))
                  ]),
                );
              }).toList()),
            ],
          ),
          if (_isLoading)
            Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- CẬP NHẬT GIAO DIỆN POPUP SANG MÀU TRẮNG ---
  void _showSOSDetails(SOSAlertModel alert) {
    bool isSafe = alert.status == 'safe';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để bo góc đẹp hơn
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 450,
        decoration: const BoxDecoration(
            color: Colors.white, // 🟢 NỀN TRẮNG
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Row(children: [
              Icon(isSafe ? Icons.check_circle : Icons.warning,
                  color: isSafe ? Colors.green : Colors.red, size: 30),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(isSafe ? "ĐÃ ĐƯỢC CỨU" : "YÊU CẦU CỨU HỘ",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSafe ? Colors.green : Colors.red))),
            ]),
            const Divider(),
            _buildDetailRow(Icons.person, "Họ tên:", alert.name),
            _buildDetailRow(Icons.phone, "SĐT:", alert.phone),
            _buildDetailRow(
                Icons.water, "Mức nước:", alert.waterLevel ?? "Chưa rõ"),
            _buildDetailRow(
                Icons.groups, "Số người:", alert.peopleCount ?? "Chưa rõ"),
            _buildDetailRow(
                Icons.message, "Lời nhắn:", alert.message ?? "Không có"),
            const Spacer(),
            Row(children: [
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: () => _makePhoneCall(alert.phone),
                      icon: const Icon(Icons.call),
                      label: const Text("GỌI ĐIỆN"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white))),
              const SizedBox(width: 10),
              if (!isSafe)
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () => _confirmRescue(alert),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("XÁC NHẬN CỨU"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white)))
              else
                Expanded(
                    child: ElevatedButton.icon(
                        onPressed: () => _deleteSOS(alert),
                        icon: const Icon(Icons.delete),
                        label: const Text("XÓA TIN"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white))),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(icon, size: 22, color: Colors.grey[700]), // Icon màu xám đậm
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87)), // Chữ đậm màu đen
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis)) // Chữ nội dung màu đen
        ]));
  }

  void _showDroneList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        decoration: const BoxDecoration(
            color: Colors.white, // 🟢 NỀN TRẮNG
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          const Text("🚁 ĐỘI BAY DRONE",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)), // Chữ đen
          const Divider(),
          Expanded(
              child: ListView.builder(
                  itemCount: _drones.length,
                  itemBuilder: (context, index) {
                    final drone = _drones[index];
                    bool isBusy = drone.status == 'busy';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.grey[100], // Nền item xám nhạt
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!)),
                      child: ListTile(
                          leading: Icon(Icons.airplanemode_active,
                              color: isBusy ? Colors.purple : Colors.blue,
                              size: 30),
                          title: Text(drone.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(isBusy ? "Đang cứu..." : "Rảnh",
                              style: TextStyle(
                                  color:
                                      isBusy ? Colors.orange : Colors.green)),
                          onTap: () {
                            Navigator.pop(context);
                            _mapController.move(
                                LatLng(drone.latitude, drone.longitude), 15.0);
                          }),
                    );
                  })),
          ElevatedButton(
              onPressed: _resetDrones,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3949AB),
                  foregroundColor: Colors.white),
              child: const Text("RESET VỊ TRÍ DRONE"))
        ]),
      ),
    );
  }

  Future<void> _resetDrones() async {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() => _isLoading = true);
    await _apiService.resetDrones();
    _loadData();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Đã gọi Drone về căn cứ!")));
  }

  Future<void> _confirmRescue(SOSAlertModel alert) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    bool success = await _apiService.resolveSOS(alert.id);
    if (success) {
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đã xác nhận cứu! Drone đang về.")));
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSOS(SOSAlertModel alert) async {
    Navigator.pop(context);
    await _apiService.deleteSOS(alert.id);
    _loadData();
  }

  Future<void> _makePhoneCall(String phone) async {
    final url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) await launchUrl(url);
  }
}
