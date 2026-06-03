import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import toast, { Toaster, ToastBar } from "react-hot-toast";

// ==========================================
// 1. AUTHENTICATION PAGES
// ==========================================
import Login from './pages/Login';
import ForgotPassword from './pages/ForgotPassword';
import VerifyOTP from './pages/VerifyOTP';
import ResetPassword from './pages/ResetPassword';

// ==========================================
// 2. ADMIN PAGES
// ==========================================
import AdminDashboard from './pages/Admin/Dashboard';
import AdminUsers from './pages/Admin/Users';
import AdminAttendance from './pages/Admin/AdminAttendance';

// ==========================================
// 3. GIÁM ĐỐC (DIRECTOR) PAGES
// ==========================================
import GiamDocDashboard from './pages/GiamDoc/Dashboard';
import Contracts from './pages/GiamDoc/Contracts';
import Positions from './pages/GiamDoc/Positions';
import Approvals from './pages/GiamDoc/ApprovalsDirector';

// ==========================================
// 4. QUẢN LÝ (MANAGER) PAGES
// ==========================================
import ManagerDashboard from './pages/QuanLy/Dashboard';
import ManagerCheckIn from './pages/QuanLy/CheckIn';
import EmployeeManagement from './pages/QuanLy/Employees';
import ApprovalsQuanLy from './pages/QuanLy/Approvals';
import RewardsDiscipline from './pages/QuanLy/RewardsDiscipline';
import NotificationPage from './pages/QuanLy/NotificationPage';
import Payroll from './pages/QuanLy/Payroll/Payroll';
import AITurnoverDashboard from './pages/QuanLy/AI/AITurnoverDashboard';
import RecommendationList from './pages/QuanLy/AI/RecommendationList';

// ==========================================
// 5. NHÂN VIÊN (EMPLOYEE) PAGES
// ==========================================
import SalaryStats from './pages/QuanLy/statistics/SalaryStats';
import AttendanceStats from './pages/QuanLy/statistics/AttendanceStats';

// ===== NHÂN VIÊN =====
import EmployeeDashboard from './pages/NhanVien/Dashboard';
import CheckIn from './pages/NhanVien/CheckIn';
import PayrollEmployee from './pages/NhanVien/Payroll'; // Đổi tên local để tránh trùng với Manager
import Requests from './pages/NhanVien/Requests';
import Profile from './pages/NhanVien/Profile';
import Contract from "./pages/NhanVien/Contract";
import OvertimeRequest from "./pages/NhanVien/OvertimeRequest";
import Ae_request from "./pages/NhanVien/attendance_explanation_request";
// ==========================================
// 6. LAYOUT & CONTEXTS
// ==========================================
import MainLayout from './layouts/MainLayout';
import { AIProgressProvider } from './contexts/AIProgressContext';

function App() {
  return (
    <AIProgressProvider>
      <BrowserRouter>
      {/* 🔥 THÔNG BÁO TOAST TOÀN CỤC */}
      <Toaster
        position="bottom-right"
        gutter={10}
        containerStyle={{ zIndex: 11000 }}
        toastOptions={{
          duration: 2200,
          success: { duration: 2000 },
          error: { duration: 3200 },
          style: {
            borderRadius: '12px',
            background: '#333',
            color: '#fff',
            zIndex: 11000,
            cursor: 'pointer',
            boxShadow: '0 4px 14px rgba(0,0,0,0.2)',
          },
        }}
      >
        {(t) => (
          <div
            role="button"
            tabIndex={0}
            onClick={() => toast.dismiss(t.id)}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                toast.dismiss(t.id);
              }
            }}
            style={{ cursor: 'pointer' }}
          >
            <ToastBar toast={t} position={t.position || 'bottom-right'} />
          </div>
        )}
      </Toaster>

      <Routes>
        {/* Điều hướng mặc định về Login */}
        <Route path="/" element={<Navigate to="/login" replace />} />
        
        {/* Các trang không có Sidebar (Auth) */}
        <Route path="/login" element={<Login />} />
        <Route path="/forgot-password" element={<ForgotPassword />} />
        <Route path="/verify-otp" element={<VerifyOTP />} />
        <Route path="/reset-password" element={<ResetPassword />} />

        {/* ==========================================
            NHÓM CÁC TRANG CÓ SIDEBAR (MainLayout)
        ========================================== */}
        <Route element={<MainLayout />}>

          {/* --- ROUTES ADMIN --- */}
          <Route path="/Admin" element={<Navigate to="/Admin/dashboard" replace />} />
          <Route path="/Admin/dashboard" element={<AdminDashboard />} />
          <Route path="/Admin/users" element={<AdminUsers />} />
          <Route path="/Admin/attendance" element={<AdminAttendance />} />

          {/* --- ROUTES GIÁM ĐỐC --- */}
          <Route path="/GiamDoc/dashboard" element={<GiamDocDashboard />} />
          <Route path="/GiamDoc/contracts" element={<Contracts />} />
          <Route path="/GiamDoc/positions" element={<Positions />} />
          <Route path="/GiamDoc/approvals" element={<Approvals />} />

          {/* --- ROUTES QUẢN LÝ (MANAGER) --- */}
          <Route path="/QuanLy/dashboard" element={<ManagerDashboard />} />
          <Route path="/QuanLy/CheckIn" element={<ManagerCheckIn />} />
          <Route path="/QuanLy/Employees" element={<EmployeeManagement />} />
          <Route path="/QuanLy/approvals" element={<ApprovalsQuanLy />} />
          <Route path="/QuanLy/Payroll/payroll" element={<Payroll />} />
          <Route path="/QuanLy/rewards-discipline" element={<RewardsDiscipline />} />
          <Route path="/QuanLy/AI/recommendations" element={<RecommendationList />} />
          <Route path="/QuanLy/notifications" element={<NotificationPage />} />
          <Route path="/QuanLy/statistics">
            <Route path="attendance" element={<AttendanceStats />} />
            <Route path="salary" element={<SalaryStats />} />
          </Route>
          <Route path="/QuanLy/AI/AITurnoverDashboard" element={<AITurnoverDashboard />} />

          {/* --- ROUTES NHÂN VIÊN (EMPLOYEE) --- */}
          <Route path="/NhanVien/dashboard" element={<EmployeeDashboard />} />
          <Route path="/NhanVien/checkin" element={<CheckIn />} /> {/* giữ để tránh sai URL */}
          <Route path="/NhanVien/payroll" element={<PayrollEmployee />} />
          
          <Route path="/NhanVien/profile" element={<Profile />} />
          <Route path="/profile/:id" element={<Profile />} />
          <Route path="/NhanVien/contracts" element={<Contract />} />
          <Route path="/NhanVien/requests/leave" element={<Requests />} />
          <Route path="/NhanVien/requests/overtime" element={<OvertimeRequest />} />
          <Route path="/NhanVien/requests/ae_request" element={<Ae_request />} />
          

        </Route>

        {/* Bất kỳ link nào không tồn tại đều đẩy về Login */}
        <Route path="*" element={<Navigate to="/login" replace />} />

      </Routes>
    </BrowserRouter>
    </AIProgressProvider>
  );
}

export default App;
