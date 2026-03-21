import React, { useEffect, useState } from "react";
import {
  RefreshCw,
  Users,
  UserCheck,
  UserX,
  Phone,
  Bell
} from "lucide-react";

export default function Dashboard() {
  const [presentEmployees, setPresentEmployees] = useState([]);
  const [absentEmployees, setAbsentEmployees] = useState([]);
  const [loading, setLoading] = useState(false);

  // 🚀 FETCH DATA
  const fetchData = () => {
    // PRESENT
    fetch("http://localhost:5000/api/dashboard/present")
      .then(res => res.json())
      .then(data => {
        const mapped = data.map(emp => ({
          name: emp.full_name,
          phone: emp.phone_number,
          time: emp.check_in_time?.slice(11, 16),
          lat: emp.check_in_latitude,
          lng: emp.check_in_longitude,
          location: emp.location_name || "Không rõ",
          status:
            emp.check_in_time?.slice(11, 16) <= "08:00"
              ? "on_time"
              : "late"
        }));
        setPresentEmployees(mapped);
      });

    // ABSENT
    fetch("http://localhost:5000/api/dashboard/absent")
      .then(res => res.json())
      .then(data => {
        const mapped = data.map(emp => ({
          name: emp.full_name,
          phone: emp.phone_number,
          status: emp.leave_status === "approved" ? "leave" : "absent"
        }));
        setAbsentEmployees(mapped);
      });
  };

  // LOAD LẦN ĐẦU
  useEffect(() => {
    fetchData();
  }, []);

  // 📊 STATS
  const total = presentEmployees.length + absentEmployees.length;
  const present = presentEmployees.length;
  const absent = absentEmployees.length;
  const performance = total === 0 ? 0 : Math.round((present / total) * 100);

  const getColor = () => {
    if (performance >= 80) return "from-green-400 to-green-600";
    if (performance >= 50) return "from-yellow-400 to-yellow-500";
    return "from-red-400 to-red-500";
  };

  return (
    <div className="space-y-6">

      {/* HEADER */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">
          Dashboard Giám đốc
        </h1>

        <button
          onClick={() => {
            setLoading(true);
            fetchData();
            setTimeout(() => setLoading(false), 800);
          }}
          className="flex items-center gap-2 bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-xl shadow"
        >
          <RefreshCw
            size={16}
            className={loading ? "animate-spin" : ""}
          />
          Làm mới
        </button>
      </div>

      {/* STATS */}
      <div className="grid grid-cols-4 gap-6">

        <div className="bg-white p-5 rounded-2xl shadow flex justify-between items-center">
          <div>
            <p className="text-gray-500 text-sm">Tổng nhân sự</p>
            <h2 className="text-3xl font-bold">{total}</h2>
          </div>
          <Users className="text-blue-500" />
        </div>

        <div className="bg-green-100 p-5 rounded-2xl flex justify-between items-center">
          <div>
            <p className="text-green-700 text-sm">Hiện diện</p>
            <h2 className="text-3xl font-bold">{present}</h2>
          </div>
          <UserCheck className="text-green-600" />
        </div>

        <div className="bg-red-100 p-5 rounded-2xl flex justify-between items-center">
          <div>
            <p className="text-red-700 text-sm">Vắng mặt</p>
            <h2 className="text-3xl font-bold">{absent}</h2>
          </div>
          <UserX className="text-red-600" />
        </div>

        <div className="bg-white p-5 rounded-2xl shadow flex flex-col justify-center">
          <p className="text-gray-500 text-sm">Hiệu suất</p>

          <h2 className="text-3xl font-bold">{performance}%</h2>

          <div className="w-full bg-gray-200 h-2 rounded-full mt-3 overflow-hidden">
            <div
              className={`bg-gradient-to-r ${getColor()} h-2 rounded-full transition-all duration-700`}
              style={{ width: `${performance}%` }}
            />
          </div>
        </div>

      </div>

      {/* TABLE */}
      <div className="grid grid-cols-2 gap-6">

        {/* PRESENT */}
        <div className="bg-white p-5 rounded-2xl shadow">
          <h2 className="font-semibold mb-4 flex items-center gap-2">
            <UserCheck className="text-green-500" size={18} />
            Đã check-in
          </h2>

          <div className="space-y-3 max-h-[400px] overflow-y-auto">
            {presentEmployees.map((emp, index) => (
              <div
                key={index}
                className="flex justify-between items-center p-3 border rounded-xl hover:bg-gray-50"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center font-bold text-green-600">
                    {emp.name?.charAt(0)}
                  </div>

                  <div>
                    <p className="font-medium">{emp.name}</p>
                    <p
                      className="text-xs text-gray-500 cursor-pointer hover:underline"
                      onClick={() =>
                        window.open(
                          `https://www.google.com/maps?q=${emp.lat},${emp.lng}`
                        )
                      }
                    >
                      📍 {emp.location}
                    </p>
                  </div>
                </div>

                <div className="text-right">
                  <p className="text-sm font-semibold">{emp.time}</p>
                  <span
                    className={`text-xs px-2 py-1 rounded-full ${
                      emp.status === "on_time"
                        ? "bg-green-100 text-green-600"
                        : "bg-yellow-100 text-yellow-600"
                    }`}
                  >
                    {emp.status === "on_time" ? "Đúng giờ" : "Trễ"}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* ABSENT */}
        <div className="bg-white p-5 rounded-2xl shadow">
          <h2 className="font-semibold mb-4 flex items-center gap-2">
            <UserX className="text-red-500" size={18} />
            Chưa check-in
          </h2>

          <div className="space-y-3 max-h-[400px] overflow-y-auto">
            {absentEmployees.map((emp, index) => {
              const isLeave = emp.status === "leave";

              return (
                <div
                  key={index}
                  className={`flex justify-between items-center p-3 border rounded-xl
                    ${isLeave ? "bg-yellow-50" : "hover:bg-red-50"}
                  `}
                >
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-10 h-10 rounded-full flex items-center justify-center font-bold
                      ${
                        isLeave
                          ? "bg-yellow-100 text-yellow-600"
                          : "bg-red-100 text-red-600"
                      }`}
                    >
                      {emp.name?.charAt(0)}
                    </div>

                    <div>
                      <p className="font-medium">{emp.name}</p>
                      <p
                        className={`text-xs ${
                          isLeave ? "text-yellow-600" : "text-red-500"
                        }`}
                      >
                        {isLeave
                          ? "Có phép"
                          : "Chưa có tín hiệu check-in"}
                      </p>
                    </div>
                  </div>

                  <div className="flex gap-2">

                    {/* PHONE POPUP */}
                    <div className="relative group">
                      <button className="p-2 bg-gray-100 hover:bg-gray-200 rounded-full">
                        <Phone size={16} />
                      </button>

                      <div className="absolute right-0 mt-2 hidden group-hover:block bg-black text-white text-xs px-3 py-1 rounded-lg shadow">
                        {emp.phone}
                      </div>
                    </div>

                    {/* NOTI */}
                    <button
                      onClick={() => alert("Đi tới gửi thông báo")}
                      className="p-2 bg-yellow-100 hover:bg-yellow-200 rounded-full"
                    >
                      <Bell size={16} />
                    </button>

                  </div>
                </div>
              );
            })}
          </div>
        </div>

      </div>
    </div>
  );
}