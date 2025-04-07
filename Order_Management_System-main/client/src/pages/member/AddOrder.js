import React, { useState } from 'react';

function AddOrder() {
  // Hàm xử lý nút thoát
  const handleExit = () => {
    window.location.href = "http://localhost:3000/";
  };

  // State để lưu trữ dữ liệu từ form
  const [MaDonHang, setMaDonHang] = useState('');
  const [NgayTao, setNgayTao] = useState('');
  const [TongSoTien, setTongSoTien] = useState('');
  const [TrangThai, setTrangThai] = useState('');
  const [NhanVienXuLy, setNhanVienXuLy] = useState('');
  const [KhoChua, setKhoChua] = useState('');
  const [NguoiNhan, setNguoiNhan] = useState('');
  const [CuaHangGui, setCuaHangGui] = useState('');
  const [NgayThanhToan, setNgayThanhToan] = useState('');
  const [PhuongThucThanhToan, setPhuongThucThanhToan] = useState('');
  const [message, setMessage] = useState('');

  const trangThaiMap= {
    'Dang cho xu ly': 'Đang chờ xử lý',
    'Da giao hang': 'Đã giao hàng',
    'Da huy': 'Đã hủy',
    'Dang giao hang': 'Đang giao hàng',
  };
  
  const phuongThucThanhToanMap = {
    'Tien mat': 'Tiền mặt', 
    'Chuyen khoan': 'Chuyển khoản'
  };


  // Hàm xử lý khi người dùng gửi form
  const handleSubmit = (event) => {
    event.preventDefault();
  
    // Hiển thị hộp thoại xác nhận
    if (window.confirm("Bạn có chắc chắn muốn thêm đơn hàng này không?")) {
      const formData = new FormData();
      formData.append('MaDonHang', MaDonHang);
      formData.append('NgayTao', NgayTao);
      formData.append('TongSoTien', TongSoTien);
      formData.append('TrangThai', TrangThai);
      formData.append('NhanVienXuLy', NhanVienXuLy);
      formData.append('KhoChua', KhoChua);
      formData.append('NguoiNhan', NguoiNhan);
      formData.append('CuaHangGui', CuaHangGui);
      formData.append('NgayThanhToan', NgayThanhToan);
      formData.append('PhuongThucThanhToan', PhuongThucThanhToan);
  
      fetch("http://localhost:8000/add_orders.php", {
        method: 'POST',
        body: formData,
      })
        .then((response) => {
          if (!response.ok) {
            throw new Error('Server trả về lỗi');
          }
          return response.json();
        })
        .then((data) => {
          if (data.success) {
            // Hiển thị thông báo thành công
            alert("Đơn hàng đã được thêm thành công!");
  
            // Reset các giá trị của form
            resetForm();
          } else {
            alert('Có lỗi xảy ra: ' + (data.message || data.error || 'Không rõ lý do.'));
          }
        })
        .catch((error) => {
          console.error('Lỗi:', error);
          alert('Có lỗi xảy ra trong quá trình gửi yêu cầu.');
        });
    } else {
      // Nếu người dùng không xác nhận, không thực hiện gửi dữ liệu
      alert('Thêm đơn hàng đã bị hủy.');
    }
  };
  

  // Hàm reset form
  const resetForm = () => {
    setMaDonHang('');
    setNgayTao('');
    setTongSoTien('');
    setTrangThai('');
    setNhanVienXuLy('');
    setKhoChua('');
    setNguoiNhan('');
    setCuaHangGui('');
    setNgayThanhToan('');
    setPhuongThucThanhToan('');
  };

  return (
    <div className="bg-orange-400 w-full min-h-screen flex">
      {/* Sidebar */}
      <div className="w-1/4 bg-orange-500 p-4">
        <button
          className="w-full py-3 text-white font-bold bg-gray-600 rounded"
          onClick={handleExit}
        >
          Thoát
        </button>
      </div>
      <div style={{ padding: '20px', width: '500px', margin: '0 auto', backgroundColor: '#fff', borderRadius: '8px', boxShadow: '0 4px 8px rgba(0, 0, 0, 0.1)' }}>
        <h2 style={{ textAlign: 'center', color: '#4CAF50', fontWeight: 'bold' }}>Thêm Đơn Hàng</h2>
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Mã Đơn Hàng:</label>
            <input
              type="text"
              value={MaDonHang}
              onChange={(e) => setMaDonHang(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Ngày Tạo:</label>
            <input
              type="date"
              value={NgayTao}
              onChange={(e) => setNgayTao(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Tổng Số Tiền:</label>
            <input
              type="number"
              value={TongSoTien}
              onChange={(e) => setTongSoTien(e.target.value)}
              // step="0.01"
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Trạng Thái:</label>
            <select
              value={TrangThai}
              onChange={(e) => setTrangThai(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            >
            <option value="">Chọn trạng thái</option>
            {Object.keys(trangThaiMap).map((trangThai, index) => (
            <option key={index} value={trangThai}>
            {trangThaiMap[trangThai]}  {/* Hiển thị giá trị có dấu */}
            </option>
             ))}
            </select>
          </div>



          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Nhân Viên Xử Lý:</label>
            <input
              type="text"
              value={NhanVienXuLy}
              onChange={(e) => setNhanVienXuLy(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Kho Chứa:</label>
            <input
              type="text"
              value={KhoChua}
              onChange={(e) => setKhoChua(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Người Nhận:</label>
            <input
              type="text"
              value={NguoiNhan}
              onChange={(e) => setNguoiNhan(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Cửa Hàng Gửi:</label>
            <input
              type="text"
              value={CuaHangGui}
              onChange={(e) => setCuaHangGui(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Ngày Thanh Toán:</label>
            <input
              type="date"
              value={NgayThanhToan}
              onChange={(e) => setNgayThanhToan(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            />
          </div>

          <div style={{ marginBottom: '15px' }}>
            <label style={{ fontWeight: 'bold', marginBottom: '8px', display: 'block' }}>Phương Thức Thanh Toán:</label>
            <select
              value={PhuongThucThanhToan}
              onChange={(e) => setPhuongThucThanhToan(e.target.value)}
              required
              style={{ width: '100%', padding: '8px', border: '1px solid #ccc', borderRadius: '4px' }}
            >
              <option value="">Chọn phương thức thanh toán</option>
              {Object.keys(phuongThucThanhToanMap).map((phuongthuc, index) => (
              <option key={index} value={phuongthuc}>
              {phuongThucThanhToanMap[phuongthuc]}  
              </option>
                ))}
            </select>
          </div>
          <button
            type="submit"
            style={{
              width: '100%',
              padding: '10px',
              backgroundColor: '#4CAF50',
              color: '#fff',
              border: 'none',
              borderRadius: '4px',
              cursor: 'pointer',
              fontSize: '16px',
            }}
          >
            Lưu
          </button>
        </form>
        <div style={{ marginTop: '20px', textAlign: 'center', color: 'red' }}>
          {message && <p>{message}</p>}
        </div>
      </div>
    </div>
  );
}

export default AddOrder;
