import React, { useState, useEffect } from 'react';
// 🔥 BƯỚC 1: Đổi tên Map thành MapIcon ở đây
import { MapPin, Wifi, Save, Navigation, Trash2, Plus, Edit2, CheckCircle, Map as MapIcon } from 'lucide-react';
import LocationMap from './LocationMap'; 
import axios from 'axios';

const LocationSettings = () => {
    const [locations, setLocations] = useState([]);
    const [selectedLoc, setSelectedLoc] = useState(null);
    const [ipInput, setIpInput] = useState('');
    const [branches, setBranches] = useState([]);

    // 🛠️ 1. GỌI API LẤY DANH SÁCH TỪ DATABASE
    useEffect(() => {
        const fetchLocations = async () => {
            try {
                const res = await axios.get('http://localhost:5000/api/admin/locations');
                const apiData = res.data.data || res.data;

                if (apiData && apiData.length > 0) {
                    const uniqueBranches = [];
                   const validData = apiData.filter(item => item.work_location_id !== null);
                    const duplicateFilterMap = new Map(); 
                    for (const item of apiData) {
                        if(!duplicateFilterMap.has(item.id)){
                            duplicateFilterMap.set(item.id, true);
                            uniqueBranches.push({ id: item.id, branch_name: item.branch_name });
                        }
                    }
                    setBranches(uniqueBranches);

                    const formattedLocations = apiData.map(item => ({
                        id: item.work_location_id || `temp_${item.id}`, 
                        work_location_id: item.work_location_id,
                        branch_id: item.id,
                        location_name: item.location_name || 'Chưa đặt tên khu vực',
                        branch_name: item.branch_name || 'Chi nhánh chưa rõ',
                        address: item.address || 'Chưa cập nhật',
                        latitude: Number(item.latitude) || null,
                        longitude: Number(item.longitude) || null,
                        radius_meters: Number(item.radius_meters) || 100,
                        allowed_ips: Array.isArray(item.allowed_ips) ? item.allowed_ips : 
                                    (typeof item.allowed_ips === 'string' ? JSON.parse(item.allowed_ips) : []),
                        is_active: item.is_active !== undefined ? item.is_active : true,
                        gps_status: !!item.latitude,
                        wifi_status: item.allowed_ips && item.allowed_ips.length > 0,
                        type: item.type || 'branch', 
                        isNew: false
                    }));

                    setLocations(formattedLocations);
                    setSelectedLoc(formattedLocations[0]);
                } else {
                    handleAddNewLocation(); 
                }
            } catch (error) {
                console.error("Lỗi lấy dữ liệu từ DB:", error);
            }
        };
        fetchLocations();
    }, []);

    const handleSaveConfig = async () => {
        const payload = {
            location_name: selectedLoc.location_name,
            location_type: selectedLoc.type, 
            id: selectedLoc.branch_id, 
            address: selectedLoc.address,
            latitude: selectedLoc.latitude,
            longitude: selectedLoc.longitude,
            radius_meters: selectedLoc.radius_meters,
            allowed_ips: selectedLoc.allowed_ips, 
            is_active: selectedLoc.is_active
        };

        try {
            if (selectedLoc.isNew) {
                const res = await axios.post('http://localhost:5000/api/admin/locations', payload);
                alert("✅ Đã THÊM MỚI khu vực thành công!");
                updateField('isNew', false);
                const newId = res.data?.data?.id || res.data?.id; 
                if (newId) updateField('branch_id', newId);
            } else {
                await axios.put(`http://localhost:5000/api/admin/locations/${selectedLoc.branch_id}/settings`, payload);
                alert("✅ Đã CẬP NHẬT toàn bộ cấu hình thành công!");
            }
        } catch (error) {
            console.error("Lỗi khi lưu:", error);
            alert("❌ Lỗi khi lưu vào Database!");
        }
    };

    const updateField = (field, value) => {
        const updatedLoc = { ...selectedLoc, [field]: value };
        setSelectedLoc(updatedLoc);
        setLocations(locations.map(loc => loc.id === updatedLoc.id ? updatedLoc : loc));
    };

    const handleAddNewLocation = () => {
        const newId = Date.now(); 
        const newLocation = {
            id: newId,
            branch_id: '', 
            location_name: 'Khu vực mới', 
            branch_name: 'Chưa gắn chi nhánh',
            address: 'Chưa cập nhật',
            latitude: 21.028511, 
            longitude: 105.804817,
            radius_meters: 100,
            allowed_ips: [],
            is_active: false,
            gps_status: false,
            wifi_status: false,
            type: 'branch', 
            isNew: true 
        };
        setLocations([newLocation, ...locations]); 
        setSelectedLoc(newLocation);
    };

    const handleDeleteLocation = async () => {
        if (selectedLoc.isNew) {
            const newLocations = locations.filter(loc => loc.id !== selectedLoc.id);
            setLocations(newLocations);
            setSelectedLoc(newLocations.length > 0 ? newLocations[0] : null);
            return;
        }
        const confirmText = prompt(`Để xóa, vui lòng gõ chính xác tên: "${selectedLoc.location_name}"`);
        if (confirmText?.trim() !== selectedLoc.location_name) return alert("Sai tên xác nhận!");

        try {
            await axios.delete(`http://localhost:5000/api/admin/locations/${selectedLoc.branch_id}/work-location`);
            alert("✅ Đã xóa cấu hình GPS!");
            const updatedLoc = { ...selectedLoc, latitude: null, longitude: null, radius_meters: null, gps_status: false };
            setSelectedLoc(updatedLoc);
            setLocations(locations.map(loc => loc.id === updatedLoc.id ? updatedLoc : loc));
        } catch (error) {
            alert("❌ Lỗi khi xóa!");
        }
    };

    const handleAddIp = () => {
        if (!ipInput.trim() || selectedLoc.allowed_ips.includes(ipInput.trim())) return;
        const updatedIps = [...selectedLoc.allowed_ips, ipInput.trim()];
        updateField('allowed_ips', updatedIps);
        updateField('wifi_status', true); 
        setIpInput(''); 
    };

    const handleRemoveIp = (ipToRemove) => {
        const updatedIps = selectedLoc.allowed_ips.filter(ip => ip !== ipToRemove);
        updateField('allowed_ips', updatedIps);
        updateField('wifi_status', updatedIps.length > 0);
    };

    const handleGetGPS = () => {
        if (!navigator.geolocation) return alert("Không hỗ trợ GPS!");
        navigator.geolocation.getCurrentPosition(
            (pos) => {
                const updatedLoc = { ...selectedLoc, latitude: pos.coords.latitude, longitude: pos.coords.longitude, gps_status: true };
                setSelectedLoc(updatedLoc);
                setLocations(prevLocations => prevLocations.map(loc => loc.id === updatedLoc.id ? updatedLoc : loc));
            },
            () => alert("Lỗi lấy vị trí!"),
            { enableHighAccuracy: false, timeout: 30000, maximumAge: 0 }
        );
    };

    const Badge = ({ label, active }) => (
        <span style={{ fontSize: '10px', fontWeight: '600', padding: '2px 8px', borderRadius: '6px', marginRight: '5px', backgroundColor: active ? '#E0F2FE' : '#FFE4E6', color: active ? '#0369A1' : '#E11D48', border: `1px solid ${active ? '#BAE6FD' : '#FECDD3'}` }}>
            {label}: {active ? 'Bật' : 'Tắt'}
        </span>
    );

    if (!selectedLoc) return <div style={{ padding: '20px' }}>Đang tải...</div>;

    return (
        <div style={{ display: 'flex', flexDirection: 'column', height: '100vh', backgroundColor: '#F8FAFC', fontFamily: 'system-ui' }}>
            
            <div style={{ padding: '20px 30px', backgroundColor: 'white', borderBottom: '1px solid #E2E8F0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                    <div style={{ padding: '12px', backgroundColor: '#F0F9FF', borderRadius: '12px' }}>
                        {/* 🔥 BƯỚC 2: Đổi tên Component ở đây */}
                        <MapIcon color="#0EA5E9" size={24} />
                    </div>
                    <div>
                        <h1 style={{ margin: 0, fontSize: '20px', color: '#0F172A', fontWeight: '700' }}>Cài đặt Khu vực Chấm công</h1>
                        <p style={{ margin: '5px 0 0 0', fontSize: '13px', color: '#64748B' }}>Thiết lập GPS và Wifi chấm công cho toàn hệ thống.</p>
                    </div>
                </div>
                <button onClick={handleAddNewLocation} style={{ backgroundColor: '#0EA5E9', color: 'white', border: 'none', padding: '10px 20px', borderRadius: '8px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', boxShadow: '0 2px 4px rgba(14, 165, 233, 0.2)' }}>
                    <Plus size={18} /> Thêm khu vực mới
                </button>
            </div>

            <div style={{ display: 'flex', flex: 1, padding: '20px', gap: '25px', overflow: 'hidden' }}>
                
                <div style={{ width: '280px', overflowY: 'auto', paddingRight: '5px' }}>
                    <p style={{ fontSize: '11px', fontWeight: 'bold', color: '#64748B', marginBottom: '15px' }}>DANH SÁCH KHU VỰC</p>
                    {locations.map(loc => (
                        <div key={loc.id} onClick={() => setSelectedLoc(loc)} style={{ padding: '15px', borderRadius: '15px', backgroundColor: 'white', cursor: 'pointer', marginBottom: '12px', border: selectedLoc.id === loc.id ? '1.5px solid #38BDF8' : '1px solid #F1F5F9', boxShadow: '0 2px 4px rgba(0,0,0,0.02)', position: 'relative' }}>
                            <div style={{ fontWeight: '700', fontSize: '14px', color: '#1E293B' }}>
                                {loc.location_name} {loc.isNew && <span style={{color: '#E11D48', fontSize: '10px'}}>(Mới)</span>}
                            </div>
                            <div style={{ fontSize: '11px', color: '#94A3B8', margin: '4px 0 10px 0', display: 'flex', alignItems: 'center', gap: '4px' }}>
                                <MapPin size={12} /> {loc.branch_id ? `Nhánh: ${loc.branch_name}` : 'Chưa gắn'}
                            </div>
                            <div style={{ display: 'flex' }}><Badge label="GPS" active={loc.gps_status} /><Badge label="Wifi" active={loc.wifi_status} /></div>
                        </div>
                    ))}
                </div>

                <div style={{ flex: 1, backgroundColor: 'white', borderRadius: '20px', padding: '30px', boxShadow: '0 4px 6px -1px rgba(0,0,0,0.1)', display: 'flex', flexDirection: 'column', overflowY: 'auto' }}>
                    
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flex: 1 }}>
                            <div style={{ backgroundColor: '#F8FAFC', padding: '8px', borderRadius: '8px', border: '1px solid #E2E8F0' }}>
                                <Edit2 size={18} color="#0EA5E9" />
                            </div>
                            <input 
                                type="text"
                                value={selectedLoc.location_name}
                                onChange={(e) => updateField('location_name', e.target.value)}
                                style={{ fontSize: '22px', fontWeight: '700', color: '#0F172A', border: 'none', borderBottom: '2px solid transparent', padding: '4px 0', width: '70%', outline: 'none' }}
                                onFocus={(e) => e.target.style.borderBottom = '2px solid #38BDF8'}
                                onBlur={(e) => e.target.style.borderBottom = '2px solid transparent'}
                                placeholder="Nhập tên khu vực..."
                            />
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

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6 pb-6 border-b border-gray-100">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Loại địa điểm</label>
                            <select
                                value={selectedLoc.type}
                                onChange={(e) => updateField('type', e.target.value)}
                                style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid #E2E8F0', fontSize: '14px' }}
                            >
                                <option value="department_site">Trụ sở chính</option>
                                <option value="branch">Chi nhánh</option>
                                <option value="client_site">Đối tác</option>
                                <option value="wfh">Làm việc tại nhà</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Thuộc chi nhánh quản lý</label>
                            <select
                                value={selectedLoc.branch_id || ''}
                                onChange={(e) => updateField('branch_id', Number(e.target.value))}
                                style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid #E2E8F0', fontSize: '14px' }}
                            >
                                <option value="" disabled>-- Chọn chi nhánh --</option>
                                {branches.map((branch) => (
                                    <option key={branch.id} value={branch.id}>{branch.branch_name}</option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div style={{ display: 'flex', gap: '40px' }}>
                        <div style={{ flex: 1 }}>
                            <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '15px', color: '#334155' }}>
                                <div style={{ backgroundColor: '#F0F9FF', padding: '6px', borderRadius: '8px' }}><CheckCircle size={18} color="#0EA5E9" /></div> 
                                Cấu hình GPS
                            </h4>
                            <div style={{ marginTop: '20px' }}>
                                <label style={{ fontSize: '12px', color: '#64748B' }}>Vĩ độ</label>
                                <input type="number" value={selectedLoc.latitude || ''} onChange={(e) => updateField('latitude', Number(e.target.value))} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                            </div>
                            <div style={{ marginTop: '15px' }}>
                                <label style={{ fontSize: '12px', color: '#64748B' }}>Kinh độ</label>
                                <input type="number" value={selectedLoc.longitude || ''} onChange={(e) => updateField('longitude', Number(e.target.value))} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                            </div>
                            <div style={{ display: 'flex', gap: '15px', marginTop: '15px', alignItems: 'flex-end' }}>
                                <div style={{ flex: 1 }}>
                                    <label style={{ fontSize: '12px', color: '#64748B' }}>Bán kính (m)</label>
                                    <input type="number" value={selectedLoc.radius_meters || ''} onChange={(e) => updateField('radius_meters', Number(e.target.value))} style={{ width: '100%', padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0', marginTop: '5px' }} />
                                </div>
                                <button onClick={handleGetGPS} style={{ height: '45px', padding: '0 20px', backgroundColor: '#E0F2FE', color: '#0369A1', border: 'none', borderRadius: '10px', fontWeight: '600', display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
                                    <Navigation size={16} /> Lấy vị trí
                                </button>
                            </div>
                        </div>

                        <div style={{ width: '350px', height: '270px', borderRadius: '15px', overflow: 'hidden', marginTop: '45px', border: '1px solid #E2E8F0' }}>
                            {selectedLoc.latitude && selectedLoc.longitude ? (
                                <LocationMap lat={selectedLoc.latitude} lng={selectedLoc.longitude} radius={selectedLoc.radius_meters} />
                            ) : (
                                <div style={{width: '100%', height: '100%', backgroundColor: '#F1F5F9', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#94A3B8'}}>
                                    Chưa có tọa độ
                                </div>
                            )}
                        </div>
                    </div>

                    <div style={{ marginTop: '40px' }}>
                        <h4 style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '15px', color: '#334155' }}>
                            <div style={{ backgroundColor: '#F5F3FF', padding: '6px', borderRadius: '8px' }}><Wifi size={18} color="#7C3AED" /></div>
                            IP Wifi (Tùy chọn)
                        </h4>
                        <div style={{ display: 'flex', gap: '10px', marginTop: '15px' }}>
                            <input type="text" placeholder="Nhập IPv4..." value={ipInput} onChange={(e) => setIpInput(e.target.value)} style={{ flex: 1, padding: '12px', borderRadius: '10px', border: '1px solid #E2E8F0' }} />
                            <button onClick={handleAddIp} style={{ padding: '0 25px', backgroundColor: '#F5F3FF', color: '#7C3AED', border: 'none', borderRadius: '10px', fontWeight: 'bold', cursor: 'pointer' }}>Thêm IP</button>
                        </div>
                        <div style={{ marginTop: '15px', display: 'flex', flexWrap: 'wrap', gap: '10px' }}>
                            {selectedLoc.allowed_ips.map((ip, i) => (
                                <div key={i} style={{ backgroundColor: '#F8FAFC', padding: '8px 12px', borderRadius: '8px', border: '1px solid #E2E8F0', display: 'flex', alignItems: 'center', gap: '8px' }}>
                                    <span style={{ fontSize: '13px' }}>{ip}</span>
                                    <Trash2 size={14} color="#E11D48" style={{ cursor: 'pointer' }} onClick={() => handleRemoveIp(ip)} />
                                </div>
                            ))}
                        </div>
                    </div>

                    <div style={{ marginTop: 'auto', display: 'flex', justifyContent: 'space-between', borderTop: '1px solid #F1F5F9', paddingTop: '30px' }}>
                        <button onClick={handleDeleteLocation} style={{ padding: '12px 25px', color: '#E11D48', backgroundColor: 'transparent', border: '1px solid #FEE2E2', borderRadius: '10px', fontWeight: '600', cursor: 'pointer' }}>
                            Xóa khu vực
                        </button>
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