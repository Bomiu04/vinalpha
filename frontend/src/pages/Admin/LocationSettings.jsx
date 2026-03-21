import React, { useState, useEffect } from 'react';
import { MapPin, Wifi, Save, Navigation, Trash2, Plus, Edit2, CheckCircle, Map } from 'lucide-react';
import LocationMap from './LocationMap'; 
import axios from 'axios';

const LocationSettings = () => {
    const [locations, setLocations] = useState([]);
    const [selectedLoc, setSelectedLoc] = useState(null);
    const [ipInput, setIpInput] = useState('');

    // 🛠️ 1. GỌI API LẤY DANH SÁCH TỪ DATABASE
    useEffect(() => {
        const fetchLocations = async () => {
            try {
                const res = await axios.get('http://localhost:5000/api/admin/locations');
                const apiData = res.data.data || res.data;

                if (apiData && apiData.length > 0) {
                    const formattedLocations = apiData.map(item => ({
                        id: item.id,
                        branch_name: item.branch_name || item.location_name || 'Chưa có tên',
                        address: item.address || 'Chưa cập nhật',
                        latitude: Number(item.latitude) || 21.028511,
                        longitude: Number(item.longitude) || 105.804817,
                        radius_meters: Number(item.radius_meters) || 100,
                        allowed_ips: Array.isArray(item.allowed_ips) ? item.allowed_ips : 
                                    (typeof item.allowed_ips === 'string' ? JSON.parse(item.allowed_ips) : []),
                        is_active: item.is_active !== undefined ? item.is_active : true,
                        gps_status: !!item.latitude,
                        wifi_status: item.allowed_ips && item.allowed_ips.length > 0,
                        isNew: false
                    }));

                    setLocations(formattedLocations);
                    setSelectedLoc(formattedLocations[0]);
                } else {
                    handleAddNewBranch(); 
                }
            } catch (error) {
                console.error("Lỗi lấy dữ liệu từ DB:", error);
            }
        };
        fetchLocations();
    }, []);

    // 🛠️ 2. GỌI API LƯU XUỐNG DATABASE (Đã fix gọn gàng)
    const handleSaveConfig = async () => {
        const payload = {
            location_name: selectedLoc.branch_name,
            address: selectedLoc.address,
            latitude: selectedLoc.latitude,
            longitude: selectedLoc.longitude,
            radius_meters: selectedLoc.radius_meters,
            allowed_ips: selectedLoc.allowed_ips, 
            is_active: selectedLoc.is_active
        };

        try {
            if (selectedLoc.isNew) {
                // THÊM MỚI (POST)
                const res = await axios.post('http://localhost:5000/api/admin/locations', payload);
                alert("Đã THÊM MỚI khu vực chấm công thành công!");
                updateField('isNew', false);
                // Đề phòng backend trả về data lồng nhau
                const newId = res.data?.data?.id || res.data?.id; 
                if (newId) updateField('id', newId);
            } else {
                // CẬP NHẬT (PUT)
                await axios.put(`http://localhost:5000/api/admin/locations/${selectedLoc.id}/settings`, payload);
                alert("Đã CẬP NHẬT cấu hình thành công!");
            }
        } catch (error) {
            console.error("Lỗi khi lưu:", error);
            alert("Lỗi khi lưu vào Database! Xem Console để biết chi tiết.");
        }
    };

    // 🛠️ HÀM ĐỒNG BỘ DỮ LIỆU
    const updateField = (field, value) => {
        const updatedLoc = { ...selectedLoc, [field]: value };
        setSelectedLoc(updatedLoc);
        setLocations(locations.map(loc => loc.id === updatedLoc.id ? updatedLoc : loc));
    };

    // 🛠️ HÀM: THÊM VĂN PHÒNG MỚI
    const handleAddNewBranch = () => {
        const newId = Date.now(); 
        const newBranch = {
            id: newId,
            branch_name: 'Văn phòng mới',
            address: 'Chưa cập nhật địa chỉ',
            latitude: 21.028511, 
            longitude: 105.804817,
            radius_meters: 100,
            allowed_ips: [],
            is_active: false,
            gps_status: false,
            wifi_status: false,
            type: 'Branch',
            isNew: true 
        };
        setLocations([newBranch, ...locations]); 
        setSelectedLoc(newBranch);
    };

    // 🛠️ HÀM: XÓA CHI NHÁNH
    const handleDeleteBranch = () => {
        if (window.confirm(`Bạn có chắc muốn xóa cấu hình của "${selectedLoc.branch_name}"?`)) {
            const newLocations = locations.filter(loc => loc.id !== selectedLoc.id);
            setLocations(newLocations);
            setSelectedLoc(newLocations.length > 0 ? newLocations[0] : null);
        }
    };

    // 🛠️ HÀM: THÊM & XÓA IP WIFI
    const handleAddIp = () => {
        if (!ipInput.trim()) return;
        if (selectedLoc.allowed_ips.includes(ipInput.trim())) {
            alert("Địa chỉ IP này đã được thêm từ trước!");
            return;
        }
        const updatedIps = [...selectedLoc.allowed_ips, ipInput.trim()];
        updateField('allowed_ips', updatedIps);
        updateField('wifi_status', updatedIps.length > 0); 
        setIpInput(''); 
    };

    const handleRemoveIp = (ipToRemove) => {
        const updatedIps = selectedLoc.allowed_ips.filter(ip => ip !== ipToRemove);
        updateField('allowed_ips', updatedIps);
        updateField('wifi_status', updatedIps.length > 0);
    };

    // 🛠️ 3. LẤY TỌA ĐỘ GPS (Đã fix lỗi lặp code)
    // 🛠️ 3. LẤY TỌA ĐỘ GPS (Đã dọn dẹp sạch sẽ lỗi lồng code)
    const handleGetGPS = () => {
        if (!navigator.geolocation) {
            return alert("Trình duyệt của bạn không hỗ trợ định vị GPS!");
        }

        navigator.geolocation.getCurrentPosition(
            (pos) => {
                const updatedLoc = {
                    ...selectedLoc,
                    latitude: pos.coords.latitude,
                    longitude: pos.coords.longitude,
                    gps_status: true
                };

                setSelectedLoc(updatedLoc);
                setLocations(prevLocations => 
                    prevLocations.map(loc => loc.id === updatedLoc.id ? updatedLoc : loc)
                );
            },
            (error) => {
                console.error("Lỗi GPS:", error);
                if (error.code === 1) alert("Lỗi: Bạn đã chặn quyền truy cập vị trí!");
                else if (error.code === 3) alert("Lỗi: Quá thời gian chờ (Timeout).");
            },
            { enableHighAccuracy: false, timeout: 30000, maximumAge: 0 }
        );
    };

    const Badge = ({ label, active }) => (
        <span style={{ fontSize: '10px', fontWeight: '600', padding: '2px 8px', borderRadius: '6px', marginRight: '5px', backgroundColor: active ? '#E0F2FE' : '#FFE4E6', color: active ? '#0369A1' : '#E11D48', border: `1px solid ${active ? '#BAE6FD' : '#FECDD3'}` }}>
            {label}: {active ? 'Bật' : 'Tắt'}
        </span>
    );

    if (!selectedLoc) return <div style={{ padding: '20px' }}>Đang tải dữ liệu...</div>;

    return (
        <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', backgroundColor: '#F8FAFC', fontFamily: 'system-ui' }}>
            
            <div style={{ padding: '20px 30px', backgroundColor: 'white', borderBottom: '1px solid #E2E8F0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                    <div style={{ padding: '12px', backgroundColor: '#F0F9FF', borderRadius: '12px' }}>
                        <Map color="#0EA5E9" size={24} />
                    </div>
                    <div>
                        <h1 style={{ margin: 0, fontSize: '20px', color: '#0F172A', fontWeight: '700' }}>Cài đặt Khu vực Chấm công</h1>
                        <p style={{ margin: '5px 0 0 0', fontSize: '13px', color: '#64748B' }}>Thiết lập tọa độ GPS, bán kính hợp lệ và dải IP mạng cho phép nhân viên Check-in.</p>
                    </div>
                </div>
                <button onClick={handleAddNewBranch} style={{ backgroundColor: '#0EA5E9', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '8px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', boxShadow: '0 2px 4px rgba(14, 165, 233, 0.2)' }}>
                    <Plus size={18} /> Thêm văn phòng mới
                </button>
            </div>

            <div style={{ display: 'flex', flex: 1, padding: '20px', gap: '25px', overflow: 'hidden' }}>
                
                <div style={{ width: '280px', overflowY: 'auto', paddingRight: '5px' }}>
                    <p style={{ fontSize: '11px', fontWeight: 'bold', color: '#64748B', marginBottom: '15px' }}>DANH SÁCH CHI NHÁNH</p>
                    {locations.map(loc => (
                        <div key={loc.id} onClick={() => setSelectedLoc(loc)} style={{ padding: '15px', borderRadius: '15px', backgroundColor: 'white', cursor: 'pointer', marginBottom: '12px', border: selectedLoc.id === loc.id ? '1.5px solid #38BDF8' : '1px solid #F1F5F9', boxShadow: '0 2px 4px rgba(0,0,0,0.02)', position: 'relative' }}>
                            <div style={{ fontWeight: '700', fontSize: '14px', color: '#1E293B' }}>
                                {loc.branch_name} {loc.isNew && <span style={{color: '#E11D48', fontSize: '10px'}}>(Mới)</span>}
                            </div>
                            <div style={{ fontSize: '11px', color: '#94A3B8', margin: '4px 0 10px 0', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                <MapPin size={12} /> {loc.address}
                            </div>
                            <div style={{ display: 'flex' }}><Badge label="GPS" active={loc.gps_status} /><Badge label="Wifi" active={loc.wifi_status} /></div>
                            {loc.type === 'HQ' && <span style={{ position: 'absolute', top: '15px', right: '15px', fontSize: '9px', backgroundColor: '#0EA5E9', color: 'white', padding: '2px 5px', borderRadius: '4px', fontWeight: 'bold' }}>HQ</span>}
                        </div>
                    ))}
                </div>

                <div style={{ flex: 1, backgroundColor: 'white', borderRadius: '20px', padding: '30px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)', display: 'flex', flexDirection: 'column', overflowY: 'auto' }}>
                    
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <h2 style={{ fontSize: '20px', margin: 0 }}>Cấu hình: {selectedLoc.branch_name}</h2>
                            <Edit2 size={16} color="#94A3B8" style={{ cursor: 'pointer' }} onClick={() => {
                                const newName = prompt("Nhập tên chi nhánh mới:", selectedLoc.branch_name);
                                if (newName) updateField('branch_name', newName);
                            }} />
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }} onClick={() => updateField('is_active', !selectedLoc.is_active)}>
                            <div style={{ width: '40px', height: '20px', backgroundColor: selectedLoc.is_active ? '#22C55E' : '#CBD5E1', borderRadius: '20px', position: 'relative', transition: '0.3s' }}>
                                <div style={{ width: '16px', height: '16px', backgroundColor: 'white', borderRadius: '50%', position: 'absolute', right: selectedLoc.is_active ? '2px' : '22px', top: '2px', transition: '0.3s' }} />
                            </div>
                            <span style={{ fontSize: '13px', color: selectedLoc.is_active ? '#22C55E' : '#64748B', fontWeight: '600' }}>
                                {selectedLoc.is_active ? 'Đang áp dụng' : 'Đã tắt'}
                            </span>
                        </div>
                    </div>

                    <div style={{ display: 'flex', gap: '40px' }}>
                        <div style={{ flex: 1 }}>
                            <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '15px', color: '#334155' }}>
                                <div style={{ backgroundColor: '#F0F9FF', padding: '6px', borderRadius: '8px' }}><CheckCircle size={18} color="#0EA5E9" /></div> 
                                Kiểm tra tọa độ GPS
                            </h4>
                            <div style={{ marginTop: '20px' }}>
    <label style={{ fontSize: '12px', color: '#64748B' }}>Loại địa điểm (Location Type)</label>
    <select 
        value={selectedLoc.type || 'branch'} 
        onChange={(e) => updateField('type', e.target.value)}
        style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px', backgroundColor: 'white', cursor: 'pointer' }}
    >
        <option value="hq">Trụ sở chính (HQ)</option>
        <option value="branch">Chi nhánh (Branch)</option>
        <option value="warehouse">Kho bãi (Warehouse)</option>
    </select>
</div>
                            <div style={{ marginTop: '20px' }}>
                                <label style={{ fontSize: '12px', color: '#64748B' }}>Vĩ độ (Latitude)</label>
                                <input type="number" value={selectedLoc.latitude} onChange={(e) => updateField('latitude', e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                            </div>
                            <div style={{ marginTop: '15px' }}>
                                <label style={{ fontSize: '12px', color: '#64748B' }}>Kinh độ (Longitude)</label>
                                <input type="number" value={selectedLoc.longitude} onChange={(e) => updateField('longitude', e.target.value)} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                            </div>
                            <div style={{ display: 'flex', gap: '15px', marginTop: '15px', alignItems: 'flex-end' }}>
                                <div style={{ flex: 1 }}>
                                    <label style={{ fontSize: '12px', color: '#64748B' }}>Bán kính cho phép (m)</label>
                                    <div style={{ position: 'relative' }}>
                                        <input type="number" value={selectedLoc.radius_meters} onChange={(e) => updateField('radius_meters', Number(e.target.value))} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                                        <span style={{ position: 'absolute', right: '15px', top: '18px', color: '#94A3B8', fontSize: '13px' }}>mét</span>
                                    </div>
                                </div>
                                <button onClick={handleGetGPS} style={{ height: '45px', padding: '0 20px', backgroundColor: '#E0F2FE', color: '#0369A1', border: 'none', borderRadius: '10px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                                    <Navigation size={16} /> Lấy tọa độ hiện tại
                                </button>
                            </div>
                        </div>

                        <div style={{ width: '350px', height: '270px', borderRadius: '15px', overflow: 'hidden', marginTop: '45px', border: '1px solid #E2E8F0', zIndex: 1 }}>
                            <LocationMap lat={selectedLoc.latitude} lng={selectedLoc.longitude} radius={selectedLoc.radius_meters} />
                        </div>
                    </div>

                    <div style={{ marginTop: '40px' }}>
                        <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '15px', color: '#334155' }}>
                            <div style={{ backgroundColor: '#F5F3FF', padding: '6px', borderRadius: '8px' }}><Wifi size={18} color="#7C3AED" /></div>
                            Ràng buộc địa chỉ IP (Wifi Công ty)
                        </h4>
                        <p style={{ fontSize: '12px', color: '#94A3B8', margin: '10px 0 20px 0' }}>Chỉ cho phép nhân viên chấm công khi kết nối vào mạng Wifi có địa chỉ IP công khai được liệt kê dưới đây.</p>
                        
                        {selectedLoc.allowed_ips.map((ip, i) => (
                            <div key={i} style={{ display: 'flex', gap: '10px', marginBottom: '10px' }}>
                                <input type="text" value={ip} style={{ flex: 1, padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', backgroundColor: '#F8FAFC' }} readOnly />
                                <button onClick={() => handleRemoveIp(ip)} style={{ padding: '10px 15px', backgroundColor: '#FFF1F2', color: '#E11D48', border: 'none', borderRadius: '10px', cursor: 'pointer' }}>
                                    <Trash2 size={18} />
                                </button>
                            </div>
                        ))}
                        
                        <div style={{ display: 'flex', gap: '10px' }}>
                            <input 
                                type="text" 
                                placeholder="Nhập địa chỉ IPv4 (VD: 14.226.236.155)..." 
                                value={ipInput}
                                onChange={(e) => setIpInput(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleAddIp()} 
                                style={{ flex: 1, padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0' }} 
                            />
                            <button onClick={handleAddIp} style={{ padding: '0 25px', backgroundColor: '#F5F3FF', color: '#7C3AED', border: 'none', borderRadius: '10px', fontWeight: 'bold', cursor: 'pointer' }}>
                                Thêm IP
                            </button>
                        </div>
                    </div>

                    <div style={{ marginTop: 'auto', display: 'flex', justifyContent: 'space-between', borderTop: '1px solid #F1F5F9', paddingTop: '30px' }}>
                        <button onClick={handleDeleteBranch} style={{ padding: '12px 25px', color: '#E11D48', backgroundColor: 'transparent', border: '1px solid #FEE2E2', borderRadius: '10px', fontWeight: '600', cursor: 'pointer' }}>
                            Xóa khu vực này
                        </button>
                        {/* 🛑 NÚT LƯU ĐÃ ĐƯỢC KẾT NỐI SỰ KIỆN Ở ĐÂY */}
                        <button onClick={handleSaveConfig} style={{ padding: '12px 30px', backgroundColor: '#1E293B', color: 'white', border: 'none', borderRadius: '10px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
                            <Save size={18} /> Lưu cấu hình
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default LocationSettings;