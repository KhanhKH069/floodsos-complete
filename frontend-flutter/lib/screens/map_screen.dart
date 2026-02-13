// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/sos_alert_model.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final ApiService _apiService = ApiService();

  // Tọa độ trung tâm mặc định (Nghệ An - Hà Tĩnh)
  final LatLng _defaultCenter = const LatLng(18.6733, 105.6924);

  List<SOSAlertModel> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  // 🔴 Tải dữ liệu SOS thật từ API
  Future<void> _loadAlerts() async {
    try {
      final alerts = await _apiService.getSOSAlerts();
      setState(() {
        _alerts = alerts
            .where((a) => a.latitude != 0.0 && a.longitude != 0.0)
            .toList(); // Chỉ lấy alerts có tọa độ hợp lệ
        _isLoading = false;
      });

      // Tự động zoom vào khu vực có alerts
      if (_alerts.isNotEmpty) {
        _fitBoundsToAlerts();
      }
    } catch (e) {
      print("Lỗi tải bản đồ: $e");
      setState(() => _isLoading = false);
    }
  }

  // Tự động zoom để hiển thị tất cả markers
  void _fitBoundsToAlerts() {
    if (_alerts.isEmpty) return;

    double minLat = _alerts.first.latitude;
    double maxLat = _alerts.first.latitude;
    double minLon = _alerts.first.longitude;
    double maxLon = _alerts.first.longitude;

    for (var alert in _alerts) {
      if (alert.latitude < minLat) minLat = alert.latitude;
      if (alert.latitude > maxLat) maxLat = alert.latitude;
      if (alert.longitude < minLon) minLon = alert.longitude;
      if (alert.longitude > maxLon) maxLon = alert.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLon),
      LatLng(maxLat, maxLon),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, color: Colors.white),
            const SizedBox(width: 8),
            Text('Bản đồ Cứu hộ (${_alerts.length})'),
          ],
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới",
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAlerts();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Bản đồ
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: 13.0,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.floodsos.app',
                    ),
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),

                // Chú thích
                Positioned(
                    left: 12, bottom: 24, right: 80, child: _buildLegend()),

                // Thông báo nếu không có alerts
                if (_alerts.isEmpty)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hiện chưa có yêu cầu cứu hộ nào trên bản đồ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Nút về vị trí mặc định
          FloatingActionButton.small(
            heroTag: 'center',
            onPressed: () {
              if (_alerts.isNotEmpty) {
                _fitBoundsToAlerts();
              } else {
                _mapController.move(_defaultCenter, 13.0);
              }
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.center_focus_strong, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                  _mapController.camera.center, currentZoom + 1);
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                  _mapController.camera.center, currentZoom - 1);
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.remove, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // Tạo markers từ dữ liệu thật
  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    for (var alert in _alerts) {
      // Chọn màu dựa trên mức độ khẩn cấp
      Color alertColor = _getAlertColor(alert);

      markers.add(
        Marker(
          point: LatLng(alert.latitude, alert.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _showAlertDetails(alert),
            child: Container(
              decoration: BoxDecoration(
                color: alertColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.sos, color: Colors.white, size: 26),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  // Xác định màu dựa trên mức độ
  Color _getAlertColor(SOSAlertModel alert) {
    if (alert.status == 'critical' ||
        alert.waterLevel == 'Khẩn cấp' ||
        alert.waterLevel == 'Cao') {
      return Colors.red;
    } else if (alert.status == 'warning' || alert.waterLevel == 'Trung bình') {
      return Colors.orange;
    }
    return Colors.green;
  }

  // Hiển thị chi tiết khi bấm vào marker
  void _showAlertDetails(SOSAlertModel alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2E3B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sos, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SOS từ ${alert.name.isEmpty ? "Người dùng" : alert.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        alert.status == 'critical'
                            ? '🔴 ĐANG NGUY CẤP'
                            : '🟠 Cần hỗ trợ',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.white24),

            // Thông tin chi tiết
            _buildInfoRow('📍', 'Vị trí',
                '${alert.latitude.toStringAsFixed(5)}, ${alert.longitude.toStringAsFixed(5)}'),
            _buildInfoRow('📞', 'Số điện thoại',
                alert.phone.isEmpty ? 'Không có' : alert.phone),
            _buildInfoRow(
                '👥', 'Số người', '${alert.peopleCount ?? '?'} người'),
            _buildInfoRow('🌊', 'Mức nước', alert.waterLevel ?? 'Chưa rõ'),
            _buildInfoRow('🕐', 'Thời gian', _formatTime(alert.createdAt)),

            if (alert.message != null && alert.message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💬 Lời nhắn:',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert.message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Có thể mở ứng dụng bản đồ bên ngoài
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Chỉ đường'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
                if (alert.phone.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Gọi điện
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Gọi điện'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📌 Chú giải',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildLegendItem(Colors.red, 'SOS / Nguy cấp'),
          _buildLegendItem(Colors.orange, 'Cảnh báo'),
          _buildLegendItem(Colors.green, 'An toàn'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text('$label: ', style: TextStyle(color: Colors.grey[400])),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return "Vừa xong";
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    return "${time.day}/${time.month} lúc ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}
