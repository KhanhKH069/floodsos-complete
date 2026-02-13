// server.js - FULL TÍNH NĂNG (Login, SOS, Drone, Chatbot)
console.log("🚀 SERVER ĐANG KHỞI ĐỘNG...");

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3002;
const MONGO_URI = 'mongodb://127.0.0.1:27017/floodsos'; 

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

if (!fs.existsSync(path.join(__dirname, 'uploads'))){
    fs.mkdirSync(path.join(__dirname, 'uploads'));
}

mongoose.connect(MONGO_URI).then(() => console.log("✅ MongoDB Connected!"));

const SOSAlert = mongoose.model('SOSAlert', new mongoose.Schema({
    lat: Number, lon: Number, phone: String, name: String, 
    water_level: String, people_count: String, 
    status: { type: String, default: 'pending' },
    message: String, audio: String, 
    created_at: { type: Date, default: Date.now },
    assigned_drone: { type: String, default: null }
}));

const upload = multer({ storage: multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
})});

// CẤU HÌNH CĂN CỨ DRONE
const DRONE_BASES = {
    'DR-01': { lat: 21.0487, lon: 105.8350 }, // Hồ Tây
    'DR-02': { lat: 21.0068, lon: 105.7445 }, // Smart City
    'DR-03': { lat: 20.9806, lon: 105.8413 }  // Giáp Bát
};

let GLOBAL_DRONES = [
    { id: 'DR-01', name: 'Drone Hồ Tây', lat: 21.0487, lon: 105.8350, status: 'idle', battery: 95, targetId: null },
    { id: 'DR-02', name: 'Drone Smart City',  lat: 21.0068, lon: 105.7445, status: 'idle', battery: 88, targetId: null },
    { id: 'DR-03', name: 'Drone Giáp Bát', lat: 20.9806, lon: 105.8413, status: 'idle', battery: 72, targetId: null }
];

// --- API ---

// 1. LOGIN
app.post('/api/auth/login', (req, res) => {
    const { username, password } = req.body;
    if (username === 'admin' && password === 'admin123') {
        res.json({ success: true, token: 'admin-secret-token', role: 'admin' });
    } else {
        res.status(401).json({ success: false, message: 'Sai tài khoản/mật khẩu' });
    }
});

// 2. CHATBOT (QUAN TRỌNG)
app.post('/api/chat', (req, res) => {
    const userMsg = req.body.message ? req.body.message.toLowerCase() : "";
    let reply = "Xin lỗi, tôi chưa hiểu ý bạn.";

    if (userMsg.includes('xin chào') || userMsg.includes('hi')) reply = "Chào bạn! Tôi là trợ lý ảo FloodSOS.";
    else if (userMsg.includes('công an') || userMsg.includes('113')) reply = "👮 Số Cảnh sát phản ứng nhanh: 113";
    else if (userMsg.includes('cứu thương') || userMsg.includes('115')) reply = "🚑 Cấp cứu Y tế: 115";
    else if (userMsg.includes('cứu hỏa') || userMsg.includes('114')) reply = "🚒 Cứu hỏa: 114";
    else if (userMsg.includes('sos')) reply = "🚨 Hãy bấm nút ĐỎ ngoài màn hình chính để gửi SOS!";

    res.json({ success: true, reply: reply });
});

// 3. XÁC NHẬN CỨU -> XÓA SOS
app.put('/api/sos/:id/resolve', async (req, res) => {
    try {
        const { id } = req.params;
        const alert = await SOSAlert.findById(id);
        if (alert && alert.assigned_drone) {
            const drone = GLOBAL_DRONES.find(d => d.id === alert.assigned_drone);
            if (drone) {
                drone.status = 'idle';
                drone.targetId = null;
                if (DRONE_BASES[drone.id]) {
                    drone.lat = DRONE_BASES[drone.id].lat;
                    drone.lon = DRONE_BASES[drone.id].lon;
                }
            }
        }
        await SOSAlert.findByIdAndDelete(id);
        res.json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

// Các API Drone & SOS
app.get('/api/drones', (req, res) => res.json(GLOBAL_DRONES));
app.post('/api/drones/reset', (req, res) => {
    GLOBAL_DRONES.forEach(d => {
        d.lat = DRONE_BASES[d.id].lat;
        d.lon = DRONE_BASES[d.id].lon;
        d.status = 'idle';
        d.targetId = null;
    });
    res.json({ success: true });
});
app.get('/api/sos', async (req, res) => {
    const alerts = await SOSAlert.find().sort({ created_at: -1 });
    res.json(alerts.map(a => ({
        id: a._id, name: a.name, phone: a.phone, latitude: a.lat, longitude: a.lon,
        waterLevel: a.water_level, peopleCount: a.people_count, status: a.status, 
        message: a.message, createdAt: a.created_at
    })));
});
app.delete('/api/sos/:id', async (req, res) => {
    await SOSAlert.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true });
});
app.post('/api/sos/voice', upload.single('audio'), async (req, res) => {
    try {
        const lat = parseFloat(req.body.lat || req.body.latitude);
        const lon = parseFloat(req.body.lon || req.body.longitude);
        let bestDrone = GLOBAL_DRONES.find(d => d.status === 'idle');
        let assignedId = null;
        if (bestDrone) {
            bestDrone.status = 'busy'; bestDrone.lat = lat; bestDrone.lon = lon; assignedId = bestDrone.id;
        }
        const newAlert = new SOSAlert({
            lat, lon, phone: req.body.phone, name: req.body.name,
            water_level: req.body.water_level, people_count: req.body.people_count,
            message: req.body.message, status: 'warning', assigned_drone: assignedId
        });
        await newAlert.save();
        res.status(200).json({ success: true });
    } catch (e) { res.status(500).json({ success: false }); }
});

app.listen(PORT, '0.0.0.0', () => console.log(`✅ Server chạy port ${PORT}`));