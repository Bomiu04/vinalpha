import React, { useState, useEffect } from 'react';
import { MapPin, Wifi, Save, Navigation, Trash2, Plus, Building2, CheckCircle2 } from 'lucide-react';
import axios from 'axios';

const LocationSettings = () => {
    const [locations, setLocations] = useState([]);
    const [selectedLoc, setSelectedLoc] = useState(null);
    const [loading, setLoading] = useState(false);
    const [ipInput, setIpInput] = useState('');

    // 1. Giả lập dữ liệu hoặc gọi API lấy danh sách
    useEffect(() => {
        const fetchData = async () => {
            // Sau này nối Backend: const res = await axios.get('/api/locations');
            const dummyData = [
                { id: 1, branch_name: 'Trụ sở chính Hà Nội', address: '123 Cầu Giấy, HN', latitude: 21.0285, longitude: 105.8542, radius_meters: 100, allowed_ips: ['192.168.1.1'], is_active: true },
                { id: 2, branch_name: 'Chi nhánh Đà Nẵng', address: '45 Nguyễn Văn Linh, ĐN', latitude: 16.0544, longitude: 108.2022, radius_meters: 50, allowed_ips: [], is_active: true },
                { id: 3, branch_name: 'Kho vận TP. HCM', address: 'KCN Tân Bình, HCM', latitude: 10.7626, longitude: 106.6602, radius_meters: 200, allowed_ips: ['1.1.1.1'], is_active: false },
            ];
            setLocations(dummyData);
            setSelectedLoc(dummyData[0]);
        };
        fetchData();
    }, []);

    // 2. Hàm lấy tọa độ GPS từ trình duyệt
    const getCurrentGPS = () => {
        if (!navigator.geolocation) {
            alert("Trình duyệt của bạn không hỗ trợ định vị!");
            return;
        }
        navigator.geolocation.getCurrentPosition((position) => {
            setSelectedLoc({
                ...selectedLoc,
                latitude: position.coords.latitude,
                longitude: position.coords.longitude
            });
        }, () => alert("Không thể lấy vị trí. Hãy bật quyền truy cập GPS!"));
    };

    // 3. Quản lý danh sách IP Wifi
    const addIp = () => {
        if (!ipInput) return;
        setSelectedLoc({
            ...selectedLoc,
            allowed_ips: [...selectedLoc.allowed_ips, ipInput]
        });
        setIpInput('');
    };

    const removeIp = (index) => {
        const newIps = selectedLoc.allowed_ips.filter((_, i) => i !== index);
        setSelectedLoc({ ...selectedLoc, allowed_ips: newIps });
    };

    const handleSave = async () => {
        setLoading(true);
        try {
            // Nối Backend sau: await axios.put(`/api/locations/${selectedLoc.id}/settings`, selectedLoc);
            alert("Đã lưu cấu hình khu vực chấm công thành công!");
        } catch (error) {
            alert("Lỗi khi lưu dữ liệu!");
        } finally {
            setLoading(false);
        }
    };

    if (!selectedLoc) return <div>Đang tải...</div>;

    return (
        <div className="location-container" style={{ display: 'flex', gap: '20px', padding: '20px', backgroundColor: '#f9fafb', height: '100vh' }}>
            {/* CỘT TRÁI: DANH SÁCH CHI NHÁNH */}
            <div style={{ width: '350px', backgroundColor: 'white', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', padding: '16px' }}>
                <h3 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Building2 size={20} color="#6366f1" /> Chi nhánh công ty
                </h3>
                {locations.map(loc => (
                    <div 
                        key={loc.id}
                        onClick={() => setSelectedLoc(loc)}
                        style={{
                            padding: '12px', borderRadius: '8px', cursor: 'pointer', marginBottom: '8px',
                            border: selectedLoc.id === loc.id ? '2px solid #6366f1' : '1px solid #e5e7eb',
                            backgroundColor: selectedLoc.id === loc.id ? '#f5f3ff' : 'transparent'
                        }}
                    >
                        <div style={{ fontWeight: '600', fontSize: '14px' }}>{loc.branch_name}</div>
                        <div style={{ fontSize: '12px', color: '#6b7280' }}>{loc.address}</div>
                        <div style={{ marginTop: '5px' }}>
                            <span style={{ fontSize: '10px', padding: '2px 8px', borderRadius: '10px', backgroundColor: loc.is_active ? '#dcfce7' : '#fee2e2', color: loc.is_active ? '#166534' : '#991b1b' }}>
                                {loc.is_active ? 'Đang bật' : 'Đang tắt'}
                            </span>
                        </div>
                    </div>
                ))}
            </div>

            {/* CỘT PHẢI: CẤU HÌNH CHI TIẾT */}
            <div style={{ flex: 1, backgroundColor: 'white', borderRadius: '12px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', padding: '24px', overflowY: 'auto' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
                    <h2>Thiết lập khu vực: {selectedLoc.branch_name}</h2>
                    <button onClick={handleSave} disabled={loading} style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '10px 20px', backgroundColor: '#6366f1', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer' }}>
                        <Save size={18} /> {loading ? 'Đang lưu...' : 'Lưu cài đặt'}
                    </button>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px' }}>
                    {/* PHẦN GPS */}
                    <div style={{ padding: '20px', border: '1px solid #f3f4f6', borderRadius: '12px' }}>
                        <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '15px' }}>
                            <MapPin size={18} color="#ef4444" /> Định vị GPS (Bắt buộc)
                        </h4>
                        <div style={{ marginBottom: '15px' }}>
                            <label style={{ fontSize: '13px', display: 'block', marginBottom: '5px' }}>Vĩ độ (Latitude)</label>
                            <input type="text" value={selectedLoc.latitude || ''} className="ca-input" readOnly style={{ backgroundColor: '#f3f4f6' }} />
                        </div>
                        <div style={{ marginBottom: '15px' }}>
                            <label style={{ fontSize: '13px', display: 'block', marginBottom: '5px' }}>Kinh độ (Longitude)</label>
                            <input type="text" value={selectedLoc.longitude || ''} className="ca-input" readOnly style={{ backgroundColor: '#f3f4f6' }} />
                        </div>
                        <button onClick={getCurrentGPS} style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#6366f1', background: 'none', border: '1px solid #6366f1', padding: '8px 12px', borderRadius: '6px', cursor: 'pointer' }}>
                            <Navigation size={16} /> Lấy tọa độ tại đây
                        </button>
                        <div style={{ marginTop: '20px' }}>
                            <label style={{ fontSize: '13px', display: 'block', marginBottom: '5px' }}>Bán kính chấm công cho phép (Mét)</label>
                            <input 
                                type="number" 
                                className="ca-input" 
                                value={selectedLoc.radius_meters} 
                                onChange={(e) => setSelectedLoc({...selectedLoc, radius_meters: e.target.value})}
                            />
                        </div>
                    </div>

                    {/* PHẦN WIFI & TRẠNG THÁI */}
                    <div style={{ padding: '20px', border: '1px solid #f3f4f6', borderRadius: '12px' }}>
                        <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '15px' }}>
                            <Wifi size={18} color="#3b82f6" /> Giới hạn IP Wifi (Tùy chọn)
                        </h4>
                        <div style={{ display: 'flex', gap: '8px', marginBottom: '15px' }}>
                            <input 
                                type="text" 
                                placeholder="Nhập địa chỉ IP..." 
                                className="ca-input" 
                                value={ipInput}
                                onChange={(e) => setIpInput(e.target.value)}
                            />
                            <button onClick={addIp} style={{ padding: '0 15px', backgroundColor: '#3b82f6', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer' }}>
                                <Plus size={18} />
                            </button>
                        </div>
                        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                            {selectedLoc.allowed_ips.map((ip, index) => (
                                <span key={index} style={{ padding: '4px 10px', backgroundColor: '#eff6ff', border: '1px solid #bfdbfe', borderRadius: '4px', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '5px' }}>
                                    {ip} <Trash2 size={12} color="#ef4444" style={{ cursor: 'pointer' }} onClick={() => removeIp(index)} />
                                </span>
                            ))}
                        </div>

                        <hr style={{ margin: '25px 0', border: 'none', borderTop: '1px solid #f3f4f6' }} />
                        
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <input 
                                type="checkbox" 
                                checked={selectedLoc.is_active} 
                                onChange={(e) => setSelectedLoc({...selectedLoc, is_active: e.target.checked})}
                                style={{ width: '20px', height: '20px', cursor: 'pointer' }}
                            />
                            <div>
                                <div style={{ fontWeight: '600' }}>Kích hoạt chấm công tại đây</div>
                                <div style={{ fontSize: '12px', color: '#6b7280' }}>Cho phép nhân viên chấm công tại khu vực này</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LocationSettings;