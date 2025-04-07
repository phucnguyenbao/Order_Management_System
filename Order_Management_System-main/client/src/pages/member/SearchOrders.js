
import React, { useState, useEffect } from "react";
import "./SearchOrders.css";


const SearchOrders = () => {
  const [orders, setOrders] = useState([]); // Dữ liệu đơn hàng
  const [status, setStatus] = useState("Da giao hang"); // Trạng thái mặc định
  const [searchQuery, setSearchQuery] = useState(""); // Tìm kiếm theo mã đơn hàng
  const [sortOrder, setSortOrder] = useState("asc"); // Sắp xếp theo ngà
  const [error, setError] = useState(null);
  const [isEditing, setIsEditing] = useState(false); // Trạng thái chỉnh sửa
  const [formData, setFormData] = useState({}); // Dữ liệu chỉnh sửa
  const [editingOrder, setEditingOrder] = useState(null); // Đơn hàng đang được chỉnh sửa

  // Hàm fetch dữ liệu từ API
  const fetchOrders = async () => {
    try {
      const response = await fetch(
        `http://localhost:8000/get_procedure.php?TrangThai=${status}`
      );
      if (!response.ok) {
        throw new Error("Failed to fetch data");
      }
      const data = await response.json();
      //console.log("Dữ liệu trả về từ API:", data); // Kiểm tra dữ liệu
      setOrders(data); // Cập nhật state với dữ liệu đơn hàng
    } catch (err) {
      setError(err.message); // Cập nhật lỗi
    }
  };

  useEffect(() => {
    fetchOrders();
  }, [status]);

    //Lọc và sắp xếp dữ liệu
  const filteredOrders = orders
    .filter((order) =>
      order.MaDonHang.toLowerCase().includes(searchQuery.toLowerCase())
    )
    .sort((a, b) => {
      const dateA = new Date(a.NgayTao);
      const dateB = new Date(b.NgayTao);
      return sortOrder === "asc" ? dateA - dateB : dateB - dateA;
    });

    //Chỉnh sửa đơn hàng
    const handleEdit = async (order) => {
        setIsEditing(true);
      
        try {
          const response = await fetch(
            `http://localhost:8000/fetch_orders.php?madonhang=${order.MaDonHang}`
          );
          const data = await response.json();
          console.log("data:",data)
      
          if (response.ok && data.order) {
            setEditingOrder(data.order);
      
            // Chỉ cần giữ lại các trường cần hiển thị trên form
            setFormData({
              MaDonHang: data.order.MaDonHang,
              NgayTao: data.order.NgayTao,
              TongSoTien: data.order.TongSoTien,
              TrangThaiDonHang: data.order.TrangThaiDonHang,
            });
          } else {
            alert("Không thể lấy thông tin chi tiết đơn hàng!");
          }
        } catch (error) {
          alert("Lỗi khi lấy thông tin đơn hàng.");
        }
      };
    
      const handleFormChange = (e) => {
        const { name, value } = e.target;
        setFormData((prevData) => ({ ...prevData, [name]: value }));
      };
    
      const handleSubmitEdit = async (e) => {
        e.preventDefault();
        const updatedOrderData = {
            MaDonHang: formData.MaDonHang,
            NgayTao: formData.NgayTao || editingOrder.NgayTao,
            TongSoTien: formData.TongSoTien || editingOrder.TongSoTien,
            TrangThaiDonHang: formData.TrangThaiDonHang || editingOrder.TrangThaiDonHang,
            CuaHangGui: editingOrder.CuaHangGui, // Dữ liệu từ editingOrder
            KhoChua: editingOrder.KhoChua,
            NguoiNhan: editingOrder.NguoiNhan,
            NhanVienXuLy: editingOrder.NhanVienXuLy,
            NgayThanhToan: editingOrder.NgayThanhToan,
            PhuongThucThanhToan: editingOrder.PhuongThucThanhToan,
        };
        
          console.log("Dữ liệu gửi đi:", updatedOrderData);

        try {
          const response = await fetch("http://localhost:8000/edit_orders.php", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(updatedOrderData),
          });
          //console.log("Dữ liệu form:", formData);
          if (response.ok) {
            console.log("Cập nhật thành công");
            fetchOrders(); // Refresh dữ liệu
            setIsEditing(false); // Đóng form chỉnh sửa
          } else {
            const errorData = await response.json();
            // alert(`Cập nhật thất bại: ${errorData.message || "Unknown error"}`);
            alert(`Lỗi: ${errorData.error || "Có lỗi xảy ra khi cập nhật đơn hàng"}`);
          }
        } catch (err) {
        //   alert("Có lỗi xảy ra khi cập nhật");
        alert(`Lỗi: Không thể kết nối đến server. Chi tiết: ${error.message}`);
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
        if (response.ok) fetchOrders(); // Refresh dữ liệu
        else alert("Xóa thất bại");
      } catch (err) {
        alert("Có lỗi xảy ra khi xóa");
      }
    }
    };

  return (
    <div className="container">
      <h2 className="text-center">Tra cứu đơn hàng</h2>
      {/* Bộ lọc trạng thái */}
      <div className="filter">
        <label htmlFor="status">Trạng thái: </label>
        <select
          id="status"
          value={status}
          onChange={(e) => setStatus(e.target.value)}
        >
          <option value="Dang giao hang">Đang giao hàng</option>
          <option value="Da giao hang">Đã giao hàng</option>
          <option value="Dang cho xu ly">Đang chờ xử lý</option>
          <option value="Da huy">Đã hủy</option>
        </select>
      </div>

      {/* Thanh tìm kiếm */}
      <div className="mb-4">
        <label className="block mb-2">Tìm kiếm theo mã đơn hàng</label>
        <input
          type="text"
          className="w-full p-2 border rounded"
          placeholder="Nhập mã đơn hàng..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      {/* Bộ sắp xếp */}
      <div className="mb-4">
        <label className="block mb-2">Sắp xếp theo ngày tạo</label>
        <select
          className="w-full p-2 border rounded"
          value={sortOrder}
          onChange={(e) => setSortOrder(e.target.value)}
        >
          <option value="asc">Ngày cũ nhất trước</option>
          <option value="desc">Ngày mới nhất trước</option>
        </select>
      </div>

      {/* Hiển thị lỗi nếu có */}
      {error && <p className="text-danger">Lỗi: {error}</p>}

      {/* Hiển thị form chỉnh sửa */}
      {isEditing && (
  <div
    className="bg-white p-6 rounded shadow-md border-2 border-blue-500"
    style={{
      backgroundColor: "#f0f8ff",
      margin: "20px auto",
      maxWidth: "600px",
    }}
  >
    <h2 className="text-xl font-bold mb-4 text-center">Chỉnh sửa đơn hàng</h2>
    <form onSubmit={handleSubmitEdit}>
      <div className="mb-4">
        <label className="block mb-2">Mã đơn hàng</label>
        <input
          type="text"
          name="MaDonHang"
          value={formData.MaDonHang}
          readOnly
          className="w-full p-2 border rounded bg-gray-200"
        />
      </div>

      <div className="mb-4">
        <label className="block mb-2">Ngày tạo</label>
        <input
          type="date"
          name="NgayTao"
          value={formData.NgayTao}
          onChange={(e) =>
            setFormData({ ...formData, NgayTao: e.target.value })
          }
          className="w-full p-2 border rounded"
        />
      </div>

      <div className="mb-4">
        <label className="block mb-2">Tổng tiền (VND)</label>
        <input
          type="number"
          name="TongSoTien"
          value={formData.TongSoTien}
          onChange={(e) =>
            setFormData({ ...formData, TongSoTien: e.target.value })
          }
          className="w-full p-2 border rounded"
        />
      </div>

      <div className="mb-4">
        <label className="block mb-2">Trạng thái</label>
        <select
          name="TrangThaiDonHang"
          value={formData.TrangThaiDonHang}
          onChange={(e) =>
            setFormData({ ...formData, TrangThaiDonHang: e.target.value })
          }
          className="w-full p-2 border rounded"
        >
          <option value="Dang giao hang">Đang giao hàng</option>
          <option value="Da giao hang">Đã giao hàng</option>
          <option value="Dang cho xu ly">Đang chờ xử lý</option>
          <option value="Da huy">Đã hủy</option>
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


      {/* Bảng hiển thị danh sách đơn hàng */}
      <table className="min-w-full bg-white border border-gray-300">
        <thead>
          <tr className="bg-gray-100">
            <th className="px-4 py-2 border">Mã đơn hàng</th>
            <th className="px-4 py-2 border">Ngày tạo</th>
            <th className="px-4 py-2 border">Tổng số tiền</th>
            <th className="px-4 py-2 border">Trạng thái</th>
            <th className="px-4 py-2 border">Cửa hàng gửi</th>
            <th className="px-4 py-2 border">Danh sách sản phẩm</th>
            <th className="px-4 py-2 border">Thao tác</th>
          </tr>
        </thead>
        <tbody>
    {filteredOrders.length > 0 ? (
    filteredOrders.map((order) => (
      <tr key={order.MaDonHang}>
        <td className="px-4 py-2 border">{order.MaDonHang}</td>
        <td className="px-4 py-2 border">{order.NgayTao}</td>
        <td className="px-4 py-2 border">{order.TongSoTien}</td>
        <td className="px-4 py-2 border">{order.TrangThaiDonHang}</td>
        <td className="px-4 py-2 border">{order.TenCuahang}</td>
        <td className="px-4 py-2 border">{order.DanhSachSanPham}</td>
        <td className="px-4 py-2 text-center border-b">
  <div
    style={{
      border: "2px solid #ccc", // Viền
      borderRadius: "8px", // Bo góc
      display: "inline-block", // Giữ nút gọn trong 1 khối
      backgroundColor: "#f9f9f9", // Màu nền
      padding: "8px", // Khoảng cách bên trong
    }}
  >
    <button
      onClick={() => handleEdit(order)}
      style={{
        backgroundColor: "#007bff",
        color: "white",
        padding: "8px 12px",
        borderRadius: "4px",
        marginRight: "8px",
        border: "none",
        cursor: "pointer",
      }}
    >
      Chỉnh sửa
    </button>
    <button
      onClick={() => handleDelete(order.MaDonHang)}
      style={{
        backgroundColor: "#dc3545",
        color: "white",
        padding: "8px 12px",
        borderRadius: "4px",
        border: "none",
        cursor: "pointer",
      }}
    >
      Xóa
    </button>
  </div>
</td>
      </tr>
    ))
    ) : (
    <tr>
      <td colSpan="6" className="px-4 py-2 text-center border">
        Không có đơn hàng nào thỏa mãn.
      </td>
    </tr>
    )}
    </tbody>
      </table>
    </div>
  );
};

export default SearchOrders;
