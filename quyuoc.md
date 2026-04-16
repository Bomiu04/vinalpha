# Quy ước Làm Việc Dự Án GR63

Tài liệu này tổng hợp từ:
- `README FINAL.md`
- `dataKhang.sql`
- `[QUY ƯỚC BẮT BUỘC] Khi làm chức năn (1).txt`

## 1. Quy tắc bắt buộc khi code

- Không hardcode URL API hoặc socket.
- Frontend chỉ gọi API qua `axiosClient` với `import.meta.env.VITE_API_URL`.
- Frontend chỉ lấy socket qua `import.meta.env.VITE_SOCKET_URL`.
- Endpoint mới phải dùng path tương đối.
- Không viết trực tiếp:
  - `http://localhost:5000`
  - `https://kltn-gps-api.onrender.com`
- Backend không hardcode DB config hoặc SSL.
- Backend chỉ đọc cấu hình từ `process.env`.
- Chỉ bật SSL khi `NODE_ENV === 'production'`.
- Phải dùng UTF-8 tiếng Việt đúng chuẩn.
- Tên biến, tên hàm phải rõ nghĩa, đúng chuẩn.
- Nếu cài thêm thư viện ở frontend hoặc backend thì phải báo trước.
- Luồng xử lý phải logic, đúng tuần tự.

## 2. Quy trình Git và GitHub

- Áp dụng Git Flow rút gọn.
- `main`: nhánh sạch, ổn định, chỉ leader hoặc mentor được merge.
- `develop`: nhánh tích hợp chính để test chung.
- Mỗi task phải tách nhánh từ `develop`.

### Đặt tên nhánh

- Nhánh tính năng: `feature/[ten-sinh-vien]/[ten-tinh-nang]`
- Nhánh sửa lỗi: `fix/[ten-sinh-vien]/[ten-loi]`

Ví dụ:
- `feature/hoi/haversine-logic`
- `feature/linh/login-screen`

### Commit message

Phải dùng Conventional Commits:
- `feat:`
- `fix:`
- `docs:`
- `style:`
- `refactor:`

Với task có issue, ưu tiên format:
- `#<issue> - feat: ...`

Ví dụ:
- `#12 - feat: chinh sua giao dien giam doc`

### Pull Request

- Không `git push origin develop` trực tiếp.
- Luôn `git pull origin develop` trước khi code.
- Tạo branch riêng rồi mới code.
- Push branch riêng lên GitHub.
- Tạo Pull Request để merge vào `develop`.
- Gán mentor và ít nhất 1 reviewer.
- Chỉ merge khi đã được approve.

### Merge conflict

- Tự xử lý conflict trên máy cá nhân trước.
- Test lại kỹ sau khi resolve.
- Nếu conflict phức tạp, báo mentor.
- Không tự ý xóa code của người khác.

## 3. Quy ước coding và cấu trúc

### Naming convention

- Folder/File: `kebab-case`
- Biến/Hàm: `camelCase`
- Class/Component: `PascalCase`

### Công cụ khuyến nghị

- Cài ESLint
- Cài Prettier

### Cấu trúc thư mục chính

- `backend/src/controllers`: xử lý request/response
- `backend/src/services`: xử lý nghiệp vụ, tính toán
- `backend/src/routes`: khai báo API
- `backend/src/utils`: hàm dùng chung
- `frontend/src/pages`: các trang chính
- `frontend/src/components`: component UI
- `frontend/src/services`: hàm gọi API
- `frontend/src/hooks`: custom hooks

## 4. Quy tắc môi trường chạy

### Frontend

- Local dùng `.env.development`
- Production dùng biến môi trường trên môi trường deploy
- Không sửa code để đổi môi trường

### Backend

- Dùng `.env`
- Chỉ đọc qua `process.env`

### Trước khi push

- Tìm và xóa toàn bộ URL hardcode trong `frontend/src`
- Đảm bảo service mới dùng `axiosClient` hoặc `socketClient`

## 5. Tổng quan dữ liệu từ `dataKhang.sql`

Hệ thống đang dùng PostgreSQL và có các nhóm dữ liệu chính sau:

### Nhóm nhân sự

- `employee`
- `user_account`
- `contract`
- `position`
- `department`
- `branch`

### Nhóm chấm công và địa điểm

- `attendance`
- `work_location`
- `location_assignment`

### Nhóm đơn từ và phê duyệt

- `leave_request`
- `overtime_request`
- `payroll`
- `hr_decision`

### Nhóm thông báo và cấu hình

- `notification`
- `notification_recipient`
- `system_config`

## 6. Enum quan trọng trong database

### Trạng thái đơn

- `request_status`: `pending`, `approved`, `rejected`

### Loại nghỉ phép

- `leave_type`:
  - `annual`
  - `sick`
  - `unpaid`
  - `ot`
  - `maternity`
  - `bereavement`

### Trạng thái bảng lương

- `payroll_status`:
  - `draft`
  - `pending_approval`
  - `approved`
  - `paid`

### Cấp bậc chức vụ

- `position_level`:
  - `intern`
  - `fresher`
  - `junior`
  - `middle`
  - `senior`
  - `manager`
  - `director`

## 7. Các quan hệ nghiệp vụ cần nhớ

- Nhân viên thuộc một `position`.
- `position` thuộc một `department`.
- `department` thuộc một `branch`.
- `leave_request` và `overtime_request` gắn với `employee`.
- `payroll` gắn với `employee`.
- `attendance` có thể liên kết `payroll`.
- `notification_recipient` dùng để xác định người nhận thông báo.

## 8. Lưu ý khi làm chức năng mới

- Đọc đúng luồng nghiệp vụ trước khi sửa.
- Không sửa lan sang file đang ảnh hưởng nhiều người nếu chưa trao đổi trước.
- Ưu tiên sửa đúng chỗ, phạm vi nhỏ, ít rủi ro.
- Với chức năng đơn từ, phải bám đúng người nhận phê duyệt theo logic hiện tại của hệ thống.
- Với dữ liệu hiển thị, ưu tiên map đúng từ backend thay vì hardcode ở frontend.
