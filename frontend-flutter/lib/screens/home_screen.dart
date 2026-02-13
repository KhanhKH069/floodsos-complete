// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/api_service.dart';
import 'chat_screen.dart';
import 'login_screen.dart'; // 🟢 Import màn hình đăng nhập Admin

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ... (Giữ nguyên các biến khai báo cũ: _apiService, _currentPosition, _audioRecorder...)
  final ApiService _apiService = ApiService();
  bool _isSending = false;
  Position? _currentPosition;
  String _locationMessage = "Đang lấy vị trí...";
  bool _isLocationReady = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _msgController = TextEditingController();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioFilePath;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _msgController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ... (Giữ nguyên các hàm _startRecording, _stopRecording, _determinePosition, _sendSOS)
  // COPY LẠI CÁC HÀM ĐÓ Y HỆT NHƯ CŨ NHÉ, KHÔNG THAY ĐỔI GÌ
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        String path =
            '${dir.path}/sos_record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await _audioRecorder.start(config, path: path);
        setState(() {
          _isRecording = true;
          _audioFilePath = path;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chưa cấp quyền Micro!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lỗi Micro!")));
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioFilePath = path;
      });
    } catch (e) {
      print("Lỗi dừng: $e");
    }
  }

  Future<void> _determinePosition() async {
    // ... (Giữ nguyên code lấy vị trí cũ)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationMessage = "Hãy bật GPS!");
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationMessage = "Cần quyền vị trí!");
        return;
      }
    }
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
        _locationMessage =
            "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}";
        _isLocationReady = true;
      });
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
    } catch (e) {
      setState(() => _locationMessage = "Lỗi vị trí: $e");
    }
  }

  Future<void> _sendSOS() async {
    // ... (Giữ nguyên code gửi SOS cũ)
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập tên & SĐT!")));
      return;
    }
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Chưa có vị trí!")));
      return;
    }
    setState(() => _isSending = true);
    final Map<String, String> data = {
      'lat': _currentPosition!.latitude.toString(),
      'lon': _currentPosition!.longitude.toString(),
      'name': _nameController.text,
      'phone': _phoneController.text,
      'message':
          _msgController.text.isEmpty ? "Cần cứu gấp!" : _msgController.text,
      'water_level': 'Chưa rõ',
      'people_count': '1'
    };
    bool success;
    if (_audioFilePath != null && File(_audioFilePath!).existsSync()) {
      success = await _apiService.sendVoiceSOS(data, _audioFilePath!);
    } else {
      success = await _apiService.sendTextSOS(data);
    }
    setState(() => _isSending = false);
    if (success) {
      if (_audioFilePath != null) {
        try {
          File(_audioFilePath!).delete();
        } catch (_) {}
        setState(() => _audioFilePath = null);
      }
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF2C2F36),
                  title: const Text("✅ Đã gửi SOS!",
                      style: TextStyle(color: Colors.white)),
                  content: const Text("Đội cứu hộ đã nhận được vị trí.",
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"))
                  ]));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lỗi gửi tin!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🟢 1. NÚT ADMIN (ẨN KHÉO LÉO Ở GÓC TRÁI)
        leading: IconButton(
          icon: const Icon(Icons.admin_panel_settings_outlined,
              color: Colors.white24), // Màu mờ (white24) để không gây chú ý
          tooltip: "Đăng nhập Admin",
          onPressed: () {
            // Chuyển sang màn hình đăng nhập Admin
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
        ),

        title: const Text("FLOOD SOS",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
      ),

      // 🟢 2. NÚT CHATBOT (Giữ nguyên)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ChatScreen())),
        backgroundColor: Colors.cyanAccent,
        icon: const Icon(Icons.smart_toy, color: Colors.black, size: 28),
        label: const Text("HỎI TRỢ LÝ",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        elevation: 8,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // LOGO Ở MÀN HÌNH CHÍNH (Thay vì icon cảnh báo, dùng Logo App cho đẹp)
            SizedBox(
              height: 100,
              child: Image.asset('assets/images/logoicnlab.png',
                  fit: BoxFit.contain), // Hoặc logo nào bạn thích
            ),

            const SizedBox(height: 20),
            const Text("Hệ thống tự động lấy GPS để điều Drone.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 20),

            // Các trường nhập liệu (Giữ nguyên)
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: "Họ và Tên", prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 15),
            TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: "Số điện thoại", prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                    labelText: "Lời nhắn", prefixIcon: Icon(Icons.message))),
            const SizedBox(height: 20),

            // Nút Ghi âm (Giữ nguyên)
            Listener(
              onPointerDown: (_) => _startRecording(),
              onPointerUp: (_) => _stopRecording(),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: _isRecording
                        ? Colors.redAccent.withOpacity(0.8)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white24)),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_isRecording ? Icons.mic : Icons.mic_none,
                      color: Colors.white, size: 30),
                  const SizedBox(width: 10),
                  Text(
                      _isRecording
                          ? "Đang ghi âm..."
                          : (_audioFilePath != null
                              ? "Đã ghi âm (Giữ để ghi lại)"
                              : "Giữ để ghi âm"),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))
                ]),
              ),
            ),
            if (_audioFilePath != null && !_isRecording)
              TextButton.icon(
                icon:
                    const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                label: const Text("Xóa file ghi âm",
                    style: TextStyle(color: Colors.redAccent)),
                onPressed: () => setState(() => _audioFilePath = null),
              ),

            const SizedBox(height: 20),

            // Nút SOS (Giữ nguyên)
            SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                    onPressed:
                        (_isSending || !_isLocationReady) ? null : _sendSOS,
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isLocationReady ? Colors.red : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.sos, size: 30, color: Colors.white),
                    label: Text(_isSending ? "ĐANG GỬI..." : "GỬI YÊU CẦU NGAY",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))),

            const SizedBox(height: 20),

            // Bản đồ (Giữ nguyên)
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _isLocationReady ? Colors.green : Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(21.0285, 105.8542),
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all),
                      ),
                      children: [
                        TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.floodsos.app'),
                        if (_currentPosition != null)
                          MarkerLayer(markers: [
                            Marker(
                                point: LatLng(_currentPosition!.latitude,
                                    _currentPosition!.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.my_location,
                                    color: Colors.red, size: 40))
                          ]),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14,
                                color: _isLocationReady
                                    ? Colors.greenAccent
                                    : Colors.orange),
                            const SizedBox(width: 5),
                            Expanded(
                                child: Text(_locationMessage,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
