import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động tải thời tiết khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dự báo Lũ & Thời tiết")),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          final data = provider.weatherData;
          Color riskColor = Colors.green;
          if (data['riskColor'] == 'red') riskColor = Colors.red;
          if (data['riskColor'] == 'orange') riskColor = Colors.orange;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Thẻ Cảnh Báo Lũ (QUAN TRỌNG)
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(color: riskColor, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 50, color: riskColor),
                      const SizedBox(height: 10),
                      Text(
                        data['floodRisk'] ?? 'An toàn',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: riskColor),
                        textAlign: TextAlign.center,
                      ),
                      const Text("Dựa trên lượng mưa thực tế",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Thông tin thời tiết
                Text(data['location'] ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text("${data['temp']}°C",
                    style: const TextStyle(
                        fontSize: 60, fontWeight: FontWeight.w300)),
                Text(data['desc'] ?? '',
                    style:
                        const TextStyle(fontSize: 20, color: Colors.blueGrey)),
                const SizedBox(height: 20),

                // Chi tiết
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _detailItem(
                        Icons.water_drop, "${data['humidity']}%", "Độ ẩm"),
                    _detailItem(
                        Icons.cloudy_snowing, "${data['rain']}mm", "Lượng mưa"),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<WeatherProvider>().fetchWeather(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Cập nhật ngay"),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
