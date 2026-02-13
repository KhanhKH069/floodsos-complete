import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _uC = TextEditingController();
  final _pC = TextEditingController();
  final _api = ApiService();
  bool _loading = false;

  Future<void> _login() async {
    if (_uC.text.isEmpty || _pC.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nhập đủ thông tin!")));
      return;
    }
    setState(() => _loading = true);
    final res = await _api.login(_uC.text, _pC.text);
    setState(() => _loading = false);
    if (res['success'] == true) {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminMapScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(res['message'] ?? "Lỗi"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ĐĂNG NHẬP HỆ THỐNG")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.security, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 40),
              TextField(
                  controller: _uC,
                  decoration: const InputDecoration(
                      labelText: "Tài khoản", prefixIcon: Icon(Icons.person))),
              const SizedBox(height: 20),
              TextField(
                  controller: _pC,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Mật khẩu", prefixIcon: Icon(Icons.lock))),
              const SizedBox(height: 40),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("ĐĂNG NHẬP",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }
}
