import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";

export default function DepartmentCreate() {
  const navigate = useNavigate();

  const [branches, setBranches] = useState([]);

  const [form, setForm] = useState({
    department_name: "",
    department_code: "",
    description: "",
    branch_id: "",
    manager_id: "", // vẫn giữ nhưng không dùng
    is_active: true
  });

  // 👉 CHỈ LOAD CHI NHÁNH (KHÔNG LOAD EMPLOYEE NỮA)
  useEffect(() => {
    fetchBranches();
  }, []);

  const fetchBranches = async () => {
    try {
      const res = await axios.get("http://localhost:5000/api/branches");
      setBranches(res.data || []);
    } catch (err) {
      console.error("Lỗi load chi nhánh:", err);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm({
      ...form,
      [name]: type === "checkbox" ? checked : value
    });
  };

  const handleSubmit = async () => {
    try {
      const res = await axios.post(
        "http://localhost:5000/api/departments",
        {
          department_name: form.department_name,
          department_code: form.department_code,
          branch_id: form.branch_id || null,
          is_active: form.is_active
        }
      );
  
      console.log("✅ Created:", res.data);
  
      alert("Tạo phòng ban thành công!");
  
      // ⏳ delay để tránh redirect lỗi
      setTimeout(() => {
        navigate("/departments");
      }, 300);
  
    } catch (err) {
      console.log("🔥 ERROR:", err.response?.data);
      alert(err.response?.data?.message || "Lỗi tạo phòng ban");
    }
  };

  return (
    <div className="bg-gray-100 min-h-screen p-6">

      <div className="max-w-5xl mx-auto bg-white rounded-3xl shadow-lg p-6 space-y-6">

        {/* HEADER */}
        <div className="flex justify-between items-center">
          <div>
            <div className="flex items-center gap-2">
              <button onClick={() => navigate(-1)}>
                <ArrowLeft size={18} />
              </button>
              <h1 className="text-xl font-semibold">
                Thêm phòng ban mới
              </h1>
            </div>
            <p className="text-sm text-gray-400 mt-1">
              Thiết lập thông tin cơ bản, cơ cấu quản lý và chức năng phòng ban.
            </p>
          </div>

          <button
            onClick={() => navigate("/departments")}
            className="px-4 py-2 bg-gray-100 rounded-lg text-sm"
          >
            ← Quay lại danh sách
          </button>
        </div>

        {/* SECTION 1 */}
        <div className="border rounded-2xl p-5 space-y-4">
          <h2 className="font-semibold text-gray-700">
            Thông tin cơ bản
          </h2>

          <div className="grid grid-cols-2 gap-4">

            <div>
              <label className="text-sm font-medium">
                Tên phòng ban *
              </label>
              <input
                name="department_name"
                placeholder="Ví dụ: Phòng Kỹ thuật..."
                className="mt-1 w-full border rounded-xl p-3"
                onChange={handleChange}
              />
            </div>

            <div>
              <label className="text-sm font-medium">
                Mã phòng ban
              </label>
              <input
                name="department_code"
                placeholder="Tự động nếu để trống"
                className="mt-1 w-full border rounded-xl p-3"
                onChange={handleChange}
              />
            </div>

            <div className="col-span-2">
              <label className="text-sm font-medium">
                Mô tả chức năng
              </label>
              <textarea
                name="description"
                placeholder="Nhập mô tả phòng ban..."
                className="mt-1 w-full border rounded-xl p-3 h-24"
                onChange={handleChange}
              />
            </div>

          </div>
        </div>

        {/* SECTION 2 */}
        <div className="border rounded-2xl p-5 space-y-4">
          <h2 className="font-semibold text-gray-700">
            Cơ cấu & Quản lý
          </h2>

          <div className="grid grid-cols-2 gap-4">

            {/* ✅ CHỈ GIỮ CHI NHÁNH */}
            <div>
              <label className="text-sm font-medium">
                Chi nhánh *
              </label>
              <select
                name="branch_id"
                className="mt-1 w-full border rounded-xl p-3"
                value={form.branch_id}
                onChange={(e) =>
                  setForm({ ...form, branch_id: Number(e.target.value) })
                }
              >
                <option value="">-- Chọn chi nhánh --</option>
                {branches.map((b) => (
                  <option key={b.id} value={b.id}>
                    {b.branch_name}
                  </option>
                ))}
              </select>
            </div>

            {/* ❌ GIỮ UI nhưng disable */}
            <div>
              <label className="text-sm font-medium">
                Trưởng phòng (tùy chọn)
              </label>
              <input
                disabled
                placeholder="Sẽ bổ nhiệm sau"
                className="mt-1 w-full border rounded-xl p-3 bg-gray-100"
              />
            </div>

          </div>
        </div>

        {/* STATUS */}
        <div className="bg-blue-50 rounded-2xl p-5 flex justify-between items-center">
          <div>
            <p className="font-medium text-gray-700">
              Trạng thái phòng ban
            </p>
            <p className="text-sm text-gray-400">
              Quyết định phòng ban có hoạt động hay không
            </p>
          </div>

          <label className="inline-flex items-center cursor-pointer">
            <input
              type="checkbox"
              name="is_active"
              checked={form.is_active}
              onChange={handleChange}
              className="sr-only peer"
            />
            <div className="w-11 h-6 bg-gray-300 rounded-full peer peer-checked:bg-blue-500 relative">
              <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full transition peer-checked:translate-x-5"></div>
            </div>
          </label>
        </div>

        {/* ACTION */}
        <div className="flex justify-end gap-3 pt-4">
          <button
            onClick={() => navigate(-1)}
            className="px-5 py-2 bg-gray-200 rounded-xl"
          >
            Hủy bỏ
          </button>

          <button
            onClick={handleSubmit}
            className="px-6 py-2 bg-blue-500 text-white rounded-xl shadow"
          >
            + Tạo phòng ban
          </button>
        </div>

      </div>
    </div>
  );
}