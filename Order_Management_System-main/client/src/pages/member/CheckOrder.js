import React, { useState, useEffect } from "react";
import SearchOrders from "./SearchOrders";

const CheckOrder = () => {
  const [activeTab, setActiveTab] = useState("Đang chờ xử lý"); // Tab hiện tại
  const [orders, setOrders] = useState([]); // Danh sách đơn hàng
  const [pagination, setPagination] = useState({
    currentPage: 1,
    totalPages: 1,
  }); // Thông tin phân trang
  const [loading, setLoading] = useState(false); // Trạng thái đang tải
  const [error, setError] = useState(null); // Thông báo lỗi API
  const [isEditing, setIsEditing] = useState(false); // Trạng thái chỉnh sửa
  const [editingOrder, setEditingOrder] = useState(null); // Đơn hàng đang chỉnh sửa
  const [formData, setFormData] = useState({
    MaDonHang: "",
    NgayTao: "",
    TongSoTien: "",
    TrangThaiDonHang: "",
    NhanVienXuLy: "",
    KhoChua: "",
    NguoiNhan: "",
    CuaHangGui: "",
    NgayThanhToan: "",
    PhuongThucThanhToan: "",
  });

  // Hàm lấy dữ liệu từ API
  const fetchOrders = async (trangThai, page = 1) => {
    setLoading(true);
    setError(null); // Reset lỗi
    try {
      const response = await fetch(
        `http://localhost:8000/fetch_orders.php?trangthai=${encodeURIComponent(
          trangThai
        )}&page=${page}`
      );
      const data = await response.json();

      if (response.ok) {
        setOrders(data.orders || []); // Lưu dữ liệu đơn hàng vào state
        setPagination(data.pagination || { currentPage: 1, totalPages: 1 });
      } else {
        setError("Không thể tải dữ liệu. Vui lòng thử lại.");
      }
    } catch (error) {
      setError("Có lỗi xảy ra khi kết nối tới API.");
    }
    setLoading(false);
  };

  // Hàm chỉnh sửa đơn hàng
  const handleEdit = (order) => {
    setIsEditing(true);
    setEditingOrder(order);
    setFormData({
      MaDonHang: order.MaDonHang,
      NgayTao: order.NgayTao,
      TongSoTien: order.TongSoTien,
      TrangThaiDonHang: order.TrangThaiDonHang,
      NhanVienXuLy: order.NhanVienXuLy,
      KhoChua: order.KhoChua,
      NguoiNhan: order.NguoiNhan,
      CuaHangGui: order.CuaHangGui,
      NgayThanhToan: order.NgayThanhToan,
      PhuongThucThanhToan: order.PhuongThucThanhToan,
    });
  };


  // Hàm xử lý khi người dùng thay đổi thông tin trong form
  const handleFormChange = (e) => {
    const { name, value } = e.target;
    console.log("Đang thay đổi:", name, value); // Xem giá trị khi người dùng nhập
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  // Hàm xử lý khi người dùng gửi form chỉnh sửa
  const handleSubmitEdit = async (e) => {
    e.preventDefault();
  
    // Hiển thị hộp thoại xác nhận
    if (window.confirm("Bạn có chắc chắn muốn cập nhật đơn hàng này không?")) {
      // Chuyển dữ liệu từ formData sang định dạng mà PHP có thể xử lý
      const updatedOrderData = {
        MaDonHang: formData.MaDonHang,
        NgayTao: formData.NgayTao,
        TongSoTien: formData.TongSoTien,
        TrangThaiDonHang: formData.TrangThaiDonHang,
        NhanVienXuLy: formData.NhanVienXuLy,
        KhoChua: formData.KhoChua,
        NguoiNhan: formData.NguoiNhan,
        CuaHangGui: formData.CuaHangGui,
        NgayThanhToan: formData.NgayThanhToan,
        PhuongThucThanhToan: formData.PhuongThucThanhToan,
      };

  try {
    // Gửi yêu cầu API tới PHP
    const response = await fetch("http://localhost:8000/edit_orders.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(updatedOrderData), // Gửi dữ liệu vào body
    });

    console.log("Phản hồi từ server:", response);
    const data = await response.json();
    if (response.ok && data.success) {
      alert("Đơn hàng đã được cập nhật thành công!");
      fetchOrders(activeTab, pagination.currentPage); // Lấy lại danh sách đơn hàng sau khi chỉnh sửa
      setIsEditing(false); // Đóng form chỉnh sửa
    } else {
      alert('Có lỗi xảy ra: ' + (data.message || data.error || 'Không rõ lý do.'));
    }
  } catch (error) {
    console.error("Lỗi khi gửi API:", error);
    alert("Có lỗi xảy ra khi cập nhật đơn hàng.");
  }}
  else {
    // Xử lý khi người dùng hủy việc cập nhật
    alert("Cập nhật đơn hàng đã bị hủy.");
  }
};


  

  // Hàm xóa đơn hàng
  const handleDelete = async (MaDonHang) => {
    if (window.confirm("Bạn có chắc chắn muốn xóa đơn hàng này không?")) {
      try {
        const response = await fetch(
          `http://localhost:8000/delete_orders.php?MaDonHang=${MaDonHang}`,
          { method: "DELETE" }
        );

        if (response.ok) {
          fetchOrders(activeTab, pagination.currentPage); // Lấy lại danh sách đơn hàng sau khi xóa
        } else {
          alert("Xóa đơn hàng thất bại. Vui lòng thử lại.");
        }
      } catch (error) {
        alert("Có lỗi xảy ra khi xóa đơn hàng.");
      }
    }
  };

  // Gọi API khi tab hoặc trang thay đổi
  useEffect(() => {
    fetchOrders(activeTab, pagination.currentPage);
  }, [activeTab, pagination.currentPage]);

  // Hàm thay đổi tab
  const handleTabChange = (tab) => {
    setActiveTab(tab);
    setPagination({ ...pagination, currentPage: 1 }); // Reset về trang đầu
  };

  // Hàm thay đổi trang
  const changePage = (page) => {
    setPagination((prev) => ({ ...prev, currentPage: page }));
  };

  // Hàm xử lý nút thoát
  const handleExit = () => {
    window.location.href = "http://localhost:3000/";
  };

  // Phân trang
  const renderPagination = () => {
    const { currentPage, totalPages } = pagination;
    const paginationElements = [];

    // Hiển thị trang đầu và dấu "..." nếu cần
    if (currentPage > 3) {
      paginationElements.push(
        <button
          key={1}
          className={`px-4 py-2 mx-1 rounded ${
            currentPage === 1 ? "bg-blue-500 text-white" : "bg-gray-300"
          }`}
          onClick={() => changePage(1)}
        >
          1
        </button>
      );
      if (currentPage > 4) {
        paginationElements.push(
          <span key="dots-start" className="px-4 py-2 mx-1">
            ...
          </span>
        );
      }
    }

    // Hiển thị các trang gần với trang hiện tại
    for (
      let i = Math.max(1, currentPage - 2);
      i <= Math.min(totalPages, currentPage + 2);
      i++
    ) {
      paginationElements.push(
        <button
          key={i}
          className={`px-4 py-2 mx-1 rounded ${
            currentPage === i ? "bg-blue-500 text-white" : "bg-gray-300"
          }`}
          onClick={() => changePage(i)}
        >
          {i}
        </button>
      );
    }

    // Hiển thị trang cuối và dấu "..." nếu cần
    if (currentPage < totalPages - 2) {
      if (currentPage < totalPages - 3) {
        paginationElements.push(
          <span key="dots-end" className="px-4 py-2 mx-1">
            ...
          </span>
        );
      }
      paginationElements.push(
        <button
          key={totalPages}
          className={`px-4 py-2 mx-1 rounded ${
            currentPage === totalPages
              ? "bg-blue-500 text-white"
              : "bg-gray-300"
          }`}
          onClick={() => changePage(totalPages)}
        >
          {totalPages}
        </button>
      );
    }

    return (
      <div className="flex justify-center mt-4">
        {/* Trang trước */}
        <button
          className="px-4 py-2 mx-1 bg-gray-300 rounded"
          disabled={currentPage === 1}
          onClick={() => changePage(currentPage - 1)}
        >
          «
        </button>
        {paginationElements}
        {/* Trang sau */}
        <button
          className="px-4 py-2 mx-1 bg-gray-300 rounded"
          disabled={currentPage === totalPages}
          onClick={() => changePage(currentPage + 1)}
        >
          »
        </button>
      </div>
    );
  };

  return (
    <div className="bg-orange-400 w-full min-h-screen flex" >
      {/* Sidebar */}
      <div className="w-1/4 bg-orange-500 p-4" style={{ width: '20%' }}>
        {["Đang chờ xử lý", "Đang giao hàng", "Đã giao hàng", "Đã hủy", "Tra cứu"].map(
          (status) => (
            <button
              key={status}
              className={`w-full py-3 mb-4 text-white font-bold rounded ${
                activeTab === status ? "bg-red-600" : "bg-red-400"
              }`}
              onClick={() => handleTabChange(status)}
            >
              {status}
            </button>
          )
        )}
        <button
          className="w-full py-3 text-white font-bold bg-gray-600 rounded"
          onClick={handleExit}
        >
          Thoát
        </button>
      </div>

      {/* Nội dung */}
      <div className="w-3/4 bg-orange-200 p-6">
        {loading ? (
          <div>Đang tải...</div>
        ) : error ? (
          <div className="text-red-500">{error}</div>
        ) : activeTab === "Tra cứu" ? (
          <SearchOrders /> // Gọi component "Tra cứu"
        ) : (
          <div className="bg-white p-4 rounded shadow-md">
            <h2 className="text-xl font-bold mb-4">Danh sách đơn hàng</h2>

            {/* Form chỉnh sửa */}
            {isEditing && (
              <div className="bg-white p-4 rounded shadow-md">
                <h2 className="text-xl font-bold mb-4">Chỉnh sửa đơn hàng</h2>
                <form onSubmit={handleSubmitEdit}>
  <div className="mb-4">
    <label className="block mb-2">Mã đơn hàng</label>
    <input
      type="text"
      name="MaDonHang"
      value={formData.MaDonHang}
      readOnly
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Ngày tạo</label>
    <input
      type="date"
      name="NgayTao"
      value={formData.NgayTao}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Tổng tiền (VND)</label>
    <input
      type="number"
      name="TongSoTien"
      value={formData.TongSoTien}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Trạng thái</label>
    <select
      name="TrangThaiDonHang"
      value={formData.TrangThaiDonHang}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    >
      <option value="Dang cho xu ly">Đang chờ xử lý</option>
      <option value="Dang giao hang">Đang giao hàng</option>
      <option value="Da giao hang">Đã giao hàng</option>
      <option value="Da huy">Đã hủy</option>
    </select>
  </div>

  <div className="mb-4">
    <label className="block mb-2">Nhân viên xử lý</label>
    <input
      type="text"
      name="NhanVienXuLy"
      value={formData.NhanVienXuLy}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Kho chứa</label>
    <input
      type="text"
      name="KhoChua"
      value={formData.KhoChua}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Người nhận</label>
    <input
      type="text"
      name="NguoiNhan"
      value={formData.NguoiNhan}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Cửa hàng gửi</label>
    <input
      type="text"
      name="CuaHangGui"
      value={formData.CuaHangGui}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Ngày thanh toán</label>
    <input
      type="date"
      name="NgayThanhToan"
      value={formData.NgayThanhToan}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    />
  </div>

  <div className="mb-4">
    <label className="block mb-2">Phương thức thanh toán</label>
    <select
      name="PhuongThucThanhToan"
      value={formData.PhuongThucThanhToan}
      onChange={handleFormChange}
      className="w-full p-2 border rounded"
    >
      <option value="Tien mat">Tiền mặt</option>
      <option value="Chuyen khoan">Chuyển khoản</option>
    </select>
  </div>

  <div className="flex justify-end">
    <button
      type="submit"
      className="bg-blue-500 text-white px-4 py-2 rounded"
    >
      Cập nhật
    </button>
    <button
      type="button"
      onClick={() => setIsEditing(false)}
      className="ml-2 bg-gray-500 text-white px-4 py-2 rounded"
    >
      Hủy
    </button>
  </div>
</form>                  

              </div>
            )}

            {!isEditing && (
              <table className="min-w-full bg-white border border-gray-300">
                <thead>
                  <tr className="bg-gray-100">
                  <th className="px-4 py-2 text-center border-b">Mã đơn hàng</th>
                  <th className="px-4 py-2 text-center border-b">Ngày tạo</th>
                  <th className="px-4 py-2 text-center border-b">Tổng tiền (VND)</th>
                  <th className="px-4 py-2 text-center border-b">Nhân viên xử lý</th>
                  <th className="px-4 py-2 text-center border-b">Kho chứa</th>
                  <th className="px-4 py-2 text-center border-b">Người nhận</th>
                  <th className="px-4 py-2 text-center border-b">Cửa hàng gửi</th>
                  <th className="px-4 py-2 text-center border-b">Ngày thanh toán</th>
                  <th className="px-4 py-2 text-center border-b">Phương thức thanh toán</th>
                  <th className="px-4 py-2 text-center border-b">Thao tác</th>  
                  </tr>
                </thead>
                <tbody>
                  {orders.length > 0 ? (
                    orders.map((order) => (
                      <tr key={order.MaDonHang}>
                        <td className="px-4 py-2 text-center border-b">{order.MaDonHang}</td>
                        <td className="px-4 py-2 text-center border-b">{order.NgayTao}</td>
                        <td className="px-4 py-2 text-center border-b">{order.TongSoTien}</td>
                        <td className="px-4 py-2 text-center border-b">{order.NhanVienXuLy}</td>
                        <td className="px-4 py-2 text-center border-b">{order.KhoChua}</td>
                        <td className="px-4 py-2 text-center border-b">{order.NguoiNhan}</td>
                        <td className="px-4 py-2 text-center border-b">{order.CuaHangGui}</td>
                        <td className="px-4 py-2 text-center border-b">{order.NgayThanhToan}</td>
                        <td className="px-4 py-2 text-center border-b">
                          {order.PhuongThucThanhToan === 'Tien mat' ? 'Tiền mặt' : 
                           order.PhuongThucThanhToan === 'Chuyen khoan' ? 'Chuyển khoản' : 
                           order.PhuongThucThanhToan}
                        </td>

                        <td className="px-4 py-2 text-center border-b"> 
                          <button
                            onClick={() => handleEdit(order)}
                            className="bg-blue-500 text-white px-4 py-2 rounded w-20"
                          >
                            Chỉnh
                          </button>
                          <button
                            onClick={() => handleDelete(order.MaDonHang)}
                            className="bg-red-500 text-white px-4 py-2 rounded w-20"
                          >
                            Xóa 
                          </button>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan="10" className="px-4 py-2 text-center">
                        Không có đơn hàng nào.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            )}

            {/* Phân trang */}
            {renderPagination()}
          </div>
        )}
      </div>
    </div>
  );
};

export default CheckOrder; 