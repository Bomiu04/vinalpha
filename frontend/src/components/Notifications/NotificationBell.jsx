import React, { useState, useRef, useEffect, useCallback } from "react";
import { Bell, CheckCircle2, ChevronDown, ChevronUp } from "lucide-react";
import axios from "axios";
import NotificationDetailModal from "./NotificationDetailModal";

// BỔ SUNG: Import đầy đủ thư viện Icon đa dạng để đồng bộ với trang Quản lý
import { 
  FaInfoCircle, FaExclamationTriangle, FaCogs, 
  FaMoneyBillWave, FaUmbrellaBeach, FaSnowflake,
  FaBirthdayCake, FaGift, FaClock, FaPlane, 
  FaHeartbeat, FaBullhorn
} from "react-icons/fa";
import { MdEventNote, MdGroups } from "react-icons/md";

export default function NotificationBell() {
  const [isOpen, setIsOpen] = useState(false);
  const [isExpanded, setIsExpanded] = useState(false); 
  const dropdownRef = useRef(null);
  
  const [selectedNoti, setSelectedNoti] = useState(null);
  const [notifications, setNotifications] = useState([]);

  // Lấy User và đảm bảo lấy ĐÚNG employee_id của Database
  const userString = localStorage.getItem('user');
  const user = userString ? JSON.parse(userString) : {};
  // myUserId đảm bảo lấy đúng ID để Backend thực hiện lệnh UPDATE is_read
  const myUserId = user.employee_id || user.id; 

  const fetchMyNotifications = useCallback(async () => {
    if (!myUserId) return;
    try {
      const response = await axios.get(`http://localhost:5000/api/notifications/my-bell/${myUserId}`);
      setNotifications(response.data);
    } catch (error) {
      console.error("Lỗi khi lấy chuông thông báo:", error);
    }
  }, [myUserId]);

  useEffect(() => {
    fetchMyNotifications();
    const interval = setInterval(fetchMyNotifications, 30000); // Tự động làm mới mỗi 30s
    return () => clearInterval(interval);
  }, [fetchMyNotifications]);

  // LẮNG NGHE TÍN HIỆU TỪ TRANG QUẢN LÝ ĐỂ CẬP NHẬT TỨC THÌ
  useEffect(() => {
    const handleNewNotification = () => {
      fetchMyNotifications(); 
    };
    
    window.addEventListener("newNotificationCreated", handleNewNotification);
    return () => window.removeEventListener("newNotificationCreated", handleNewNotification);
  }, [fetchMyNotifications]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
        setIsExpanded(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const markAllAsRead = async () => {
    try {
      // Cập nhật UI trước cho mượt
      setNotifications(notifications.map(n => ({ ...n, is_read: true })));
      await axios.put(`http://localhost:5000/api/notifications/read-all/${myUserId}`);
    } catch (error) {
      console.error("Lỗi khi đánh dấu đọc tất cả:", error);
    }
  };

  const handleViewNotification = async (noti) => {
    const d = new Date(noti.created_at);
    const timeStr = d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
    const dateStr = d.toLocaleDateString('vi-VN');

    const { icon, bg, textColor } = getSmartIcon(noti.title, noti.notification_type);

    setSelectedNoti({ 
      ...noti, 
      fullTime: `${timeStr}, ${dateStr}`,
      target: "Cá nhân",
      icon: icon,
      bg: bg,
      textColor: textColor
    });
    
    setIsOpen(false);
    setIsExpanded(false);

    // Gửi tín hiệu đã đọc xuống Backend bằng Axios
    if (!noti.is_read) {
      try {
        // Cập nhật UI ngay lập tức để mất chấm xanh
        setNotifications(prev => prev.map(n => n.id === noti.id ? { ...n, is_read: true } : n));
        // Gọi API Backend để lưu vào DB (Đảm bảo F5 không bị hiện lại)
        await axios.put(`http://localhost:5000/api/notifications/read/${noti.id}`, { userId: myUserId });
      } catch (error) {
         console.error("Lỗi không cập nhật được trạng thái Đã Đọc:", error);
      }
    }
  };

  // --- HÀM TẠO ICON THÔNG MINH (Đã đồng bộ với trang Quản lý) ---
  const getSmartIcon = (title, type) => {
    const lowerTitle = title?.toLowerCase() || "";
    
    if (lowerTitle.includes('hè') || lowerTitle.includes('biển') || lowerTitle.includes('du lịch')) return { icon: <FaUmbrellaBeach size={16} />, bg: "bg-orange-100", textColor: "text-orange-500" };
    if (lowerTitle.includes('đông') || lowerTitle.includes('lạnh')) return { icon: <FaSnowflake size={16} />, bg: "bg-cyan-100", textColor: "text-cyan-600" };
    if (lowerTitle.includes('lương') || lowerTitle.includes('thưởng') || lowerTitle.includes('tiền')) return { icon: <FaMoneyBillWave size={16} />, bg: "bg-green-100", textColor: "text-green-600" };
    if (lowerTitle.includes('sinh nhật') || lowerTitle.includes('kỷ niệm')) return { icon: <FaBirthdayCake size={16} />, bg: "bg-fuchsia-100", textColor: "text-fuchsia-600" };
    if (lowerTitle.includes('quà') || lowerTitle.includes('tặng')) return { icon: <FaGift size={16} />, bg: "bg-rose-100", textColor: "text-rose-600" };
    
    if (lowerTitle.includes('họp') || lowerTitle.includes('meeting') || lowerTitle.includes('giao ban')) return { icon: <MdGroups size={18} />, bg: "bg-indigo-100", textColor: "text-indigo-600" };
    if (lowerTitle.includes('nghỉ') || lowerTitle.includes('lễ') || lowerTitle.includes('phép')) return { icon: <MdEventNote size={16} />, bg: "bg-pink-100", textColor: "text-pink-600" };
    if (lowerTitle.includes('giờ') || lowerTitle.includes('chấm công') || lowerTitle.includes('ca làm')) return { icon: <FaClock size={16} />, bg: "bg-purple-100", textColor: "text-purple-600" };
    if (lowerTitle.includes('công tác') || lowerTitle.includes('chuyến đi')) return { icon: <FaPlane size={16} />, bg: "bg-sky-100", textColor: "text-sky-600" };
    if (lowerTitle.includes('sức khỏe') || lowerTitle.includes('khám') || lowerTitle.includes('bảo hiểm')) return { icon: <FaHeartbeat size={16} />, bg: "bg-red-50", textColor: "text-red-400" };
    if (lowerTitle.includes('thông báo') || lowerTitle.includes('tin tức')) return { icon: <FaBullhorn size={16} />, bg: "bg-yellow-100", textColor: "text-yellow-600" };

    if (type === 'warning') return { icon: <FaExclamationTriangle size={16} />, bg: "bg-red-100", textColor: "text-red-500" };
    if (type === 'system') return { icon: <FaCogs size={16} />, bg: "bg-gray-200", textColor: "text-gray-600" };
    
    return { icon: <FaInfoCircle size={16} />, bg: "bg-blue-100", textColor: "text-blue-500" };
  };

  const stripHtml = (html) => {
    let tmp = document.createElement("DIV");
    tmp.innerHTML = html;
    return (tmp.textContent || tmp.innerText || "").substring(0, 60) + "...";
  };

  const unreadCount = notifications.filter(n => !n.is_read).length;
  const displayedNotifications = isExpanded ? notifications : notifications.slice(0, 4);

  return (
    <div className="relative inline-block font-sans" ref={dropdownRef}>
      
      {/* NÚT CHUÔNG */}
      <button 
        onClick={() => {
          setIsOpen(!isOpen);
          if (isOpen) setIsExpanded(false);
        }}
        className="relative p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-full transition-all focus:outline-none"
      >
        <Bell size={24} />
        {unreadCount > 0 && (
          <span className="absolute top-1 right-1 flex items-center justify-center w-4 h-4 text-[10px] font-bold text-white bg-red-500 border-2 border-white rounded-full">
            {unreadCount}
          </span>
        )}
      </button>

      {/* DROPDOWN DANH SÁCH THÔNG BÁO */}
      {isOpen && (
        <div className="absolute right-0 mt-3 w-80 sm:w-96 bg-white rounded-2xl shadow-2xl border border-gray-100 z-50 overflow-hidden animate-in fade-in slide-in-from-top-4 duration-200 flex flex-col">
          
          <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-gray-50/50">
            <h3 className="font-bold text-gray-800">Thông báo ({notifications.length})</h3>
            {unreadCount > 0 && (
              <button 
                onClick={markAllAsRead}
                className="text-xs text-blue-600 hover:text-blue-800 font-medium flex items-center gap-1 transition-colors"
              >
                <CheckCircle2 size={14} /> Đánh dấu đã đọc
              </button>
            )}
          </div>

          <div className={`overflow-y-auto transition-all duration-300 ${isExpanded ? "max-h-[550px]" : "max-h-[380px]"}`}>
            {displayedNotifications.length > 0 ? (
              <div className="flex flex-col">
                {displayedNotifications.map((noti) => {
                  const d = new Date(noti.created_at);
                  const timeStr = d.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
                  
                  // Lấy Icon và màu sắc động dựa trên tiêu đề và type
                  const { icon, bg, textColor } = getSmartIcon(noti.title, noti.notification_type);

                  return (
                    <div 
                      key={noti.id}
                      onClick={() => handleViewNotification(noti)}
                      className={`flex items-start gap-3.5 p-4 border-b border-gray-50 cursor-pointer transition-colors ${
                        noti.is_read ? "bg-white hover:bg-gray-50" : "bg-blue-50/40 hover:bg-blue-50"
                      }`}
                    >
                      <div className={`w-10 h-10 mt-0.5 flex items-center justify-center rounded-full ${bg} ${textColor} shrink-0 shadow-sm`}>
                        {icon}
                      </div>
                      
                      <div className="flex-1 min-w-0">
                        <p className={`text-[13.5px] leading-tight truncate flex items-center gap-2 ${noti.is_read ? "text-gray-700 font-semibold" : "text-gray-900 font-bold"}`}>
                          {noti.title}
                          {/* HIỂN THỊ TAG NẾU THÔNG BÁO ĐÃ ĐƯỢC SỬA */}
                          {noti.status === 'Đã chỉnh sửa' && (
                            <span className="text-[9px] bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded shadow-sm shrink-0">Cập nhật m</span>
                          )}
                        </p>
                        <p className="text-xs text-gray-500 mt-1 line-clamp-2 leading-relaxed">
                          {stripHtml(noti.content)}
                        </p>
                        <p className="text-[11px] font-medium text-gray-400 mt-1.5">{timeStr}</p>
                      </div>

                      {!noti.is_read && <div className="shrink-0 w-2.5 h-2.5 mt-1.5 bg-blue-600 rounded-full shadow-sm"></div>}
                    </div>
                  );
                })}
              </div>
            ) : (
              <div className="p-8 flex flex-col items-center justify-center text-center">
                <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center text-gray-400 mb-3">
                  <Bell size={28} />
                </div>
                <p className="text-gray-500 text-sm font-medium">Bạn không có thông báo nào mới.</p>
              </div>
            )}
          </div>

          <button 
            onClick={() => setIsExpanded(!isExpanded)}
            className="p-3.5 border-t border-gray-100 text-center bg-gray-50/50 hover:bg-gray-100 transition-colors cursor-pointer w-full"
          >
            <div className="text-sm font-semibold text-blue-600 flex items-center justify-center gap-2">
              {isExpanded ? (
                <>Thu gọn <ChevronUp size={16} /></>
              ) : (
                <>Xem tất cả thông báo ({notifications.length}) <ChevronDown size={16} /></>
              )}
            </div>
          </button>
        </div>
      )}

      {/* MODAL CHI TIẾT */}
      <NotificationDetailModal isOpen={!!selectedNoti} onClose={() => setSelectedNoti(null)} notification={selectedNoti} />
    </div>
  );
}