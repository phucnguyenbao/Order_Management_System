import React, { useState, useEffect } from "react";
import axios from "axios";

const Chitietcuahang = () => {
  const [storeCode, setStoreCode] = useState("");  // State cho mã cửa hàng
  const [orderStatus, setOrderStatus] = useState("Dang cho xu ly");  // State cho trạng thái đơn hàng
  const [deliveryData, setDeliveryData] = useState([]);  // State cho dữ liệu trả về
  const [filteredData, setFilteredData] = useState([]);  // State cho dữ liệu đã lọc
  const [loading, setLoading] = useState(false);  // State cho trạng thái tải dữ liệu
  const [districtSearch, setDistrictSearch] = useState("");  // State cho tìm kiếm theo Quận
  const [citySearch, setCitySearch] = useState("");  // State cho tìm kiếm theo Thành phố
  const [showSearch, setShowSearch] = useState(false); // State kiểm tra khi nào hiển thị ô tìm kiếm

  // Phân trang
  const [currentPage, setCurrentPage] = useState(1); // Trang hiện tại
  const [itemsPerPage] = useState(10); // Mỗi trang có 10 mục

  // Hàm để gọi API
  const handleFetchData = async () => {
    if (!storeCode || !orderStatus) {
      alert("Vui lòng nhập đầy đủ mã cửa hàng và chọn trạng thái đơn hàng!");
      return;
    }

    setLoading(true);
    try {
      const response = await axios.get("http://localhost:8000/get_delivery_status.php", {
        params: { storeID: storeCode, orderStatus: orderStatus },
        timeout: 5000,
      });

      console.log("Raw Response:", response.data);

      let data = response.data;
      if (typeof data === "string") {
        const jsonStartIndex = data.lastIndexOf("[");
        const jsonEndIndex = data.lastIndexOf("]") + 1;

        if (jsonStartIndex !== -1 && jsonEndIndex !== -1) {
          data = JSON.parse(data.slice(jsonStartIndex, jsonEndIndex));
        } else {
          throw new Error("Invalid JSON format in API response.");
        }
      }

      if (data && data.length > 0) {
        setDeliveryData(data);
        setFilteredData(data); // Set filteredData ban đầu
        setShowSearch(true); // Hiển thị ô tìm kiếm sau khi dữ liệu được tải
      } else {
        setDeliveryData([]);
        setFilteredData([]);
        setShowSearch(false); // Không hiển thị ô tìm kiếm nếu không có dữ liệu
      }
    } catch (error) {
      console.error("Lỗi khi lấy dữ liệu: ", error);
      setDeliveryData([]);
      setFilteredData([]);
      setShowSearch(false); // Không hiển thị ô tìm kiếm nếu có lỗi
    } finally {
      setLoading(false);
    }
  };

  // Hàm lọc dữ liệu theo Quận và Thành phố
  const handleSearch = () => {
    let filtered = deliveryData;

    if (districtSearch) {
      filtered = filtered.filter(item => item.Quan.toLowerCase().includes(districtSearch.toLowerCase()));
    }

    if (citySearch) {
      filtered = filtered.filter(item => item.ThanhPho.toLowerCase().includes(citySearch.toLowerCase()));
    }

    setFilteredData(filtered);
  };

  // Use effect để lọc dữ liệu mỗi khi người dùng thay đổi giá trị tìm kiếm
  useEffect(() => {
    handleSearch();
  }, [districtSearch, citySearch]);

  // Hàm phân trang
  const paginate = (data, currentPage, itemsPerPage) => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return data.slice(startIndex, endIndex);
  };

  // Tính tổng số trang
  const totalPages = Math.ceil(filteredData.length / itemsPerPage);

  return (
    <div className="bg-gradient-to-r from-orange-400 to-red-500 w-full min-h-screen flex flex-col items-center">
      {/* Title */}
      <div className="w-main h-[110px] py-[35px] flex items-center justify-center mb-4">
        <h2 className="text-2xl font-bold text-white">THỐNG KÊ ĐƠN HÀNG</h2>
      </div>

      {/* Input and Dropdown */}
      <div className="w-full max-w-2xl p-4 bg-white rounded-lg shadow-md">
        <div className="flex flex-col gap-4">
          {/* Mã cửa hàng */}
          <div className="flex flex-col">
            <label htmlFor="storeCode" className="text-sm font-semibold text-gray-600">
              Điền mã cửa hàng có dạng CH...
            </label>
            <input
              id="storeCode"
              type="text"
              placeholder="Nhập mã cửa hàng"
              value={storeCode}
              onChange={(e) => setStoreCode(e.target.value)}
              className="border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500"
            />
          </div>

          {/* Trạng thái đơn hàng */}
          <div className="flex flex-col">
            <label htmlFor="orderStatus" className="text-sm font-semibold text-gray-600">
              Chọn trạng thái đơn hàng
            </label>
            <select
              id="orderStatus"
              value={orderStatus}
              onChange={(e) => setOrderStatus(e.target.value)}
              className="border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500"
            >
              <option value="Dang cho xu ly">Đang chờ xử lý</option>
              <option value="Dang giao hang">Đang giao hàng</option>
              <option value="Da giao hang">Đã giao hàng</option>
              <option value="Da huy">Đã hủy</option>
            </select>
          </div>

          {/* Nút Tìm đơn hàng */}
          <button
            onClick={handleFetchData}
            className="bg-orange-500 text-white font-semibold py-2 rounded-md hover:bg-orange-600"
          >
            Tìm đơn hàng
          </button>
        </div>
      </div>

      {/* Tìm kiếm theo Quận và Thành phố chỉ hiển thị khi bảng đã có dữ liệu */}
{showSearch && (
  <div className="w-full max-w-2xl p-4 bg-white rounded-lg shadow-md mt-4">
    <div className="flex gap-4 justify-between">
      {/* Tìm kiếm theo Quận */}
      <div className="flex flex-col w-full">
        <label htmlFor="districtSearch" className="text-sm font-semibold text-gray-600">
          Tìm kiếm theo Quận
        </label>
        <input
          id="districtSearch"
          type="text"
          placeholder="Nhập Quận"
          value={districtSearch}
          onChange={(e) => setDistrictSearch(e.target.value)}
          className="border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-full"
        />
      </div>

      {/* Tìm kiếm theo Thành phố */}
      <div className="flex flex-col w-full">
        <label htmlFor="citySearch" className="text-sm font-semibold text-gray-600">
          Tìm kiếm theo Thành phố
        </label>
        <input
          id="citySearch"
          type="text"
          placeholder="Nhập Thành phố"
          value={citySearch}
          onChange={(e) => setCitySearch(e.target.value)}
          className="border border-gray-300 rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-orange-500 w-full"
        />
      </div>
    </div>
  </div>
)}


      {/* Bảng thống kê */}
      <div className="w-full max-w-4xl mt-8 p-4 bg-white rounded-lg shadow-md">
        <table className="w-full text-left border-collapse border border-gray-300">
          <thead className="bg-gray-200">
            <tr>
              <th className="border border-gray-300 px-4 py-2">Quận</th>
              <th className="border border-gray-300 px-4 py-2">Thành phố</th>
              <th className="border border-gray-300 px-4 py-2">Số lượng</th>
              <th className="border border-gray-300 px-4 py-2">Phần trăm</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="4" className="text-center py-4">Đang tải dữ liệu...</td>
              </tr>
            ) : (
              paginate(filteredData, currentPage, itemsPerPage).map((item, index) => (
                <tr key={index}>
                  <td className="border border-gray-300 px-4 py-2">{item.Quan}</td>
                  <td className="border border-gray-300 px-4 py-2">{item.ThanhPho}</td>
                  <td className="border border-gray-300 px-4 py-2">{item.SoLuong}</td>
                  <td className="border border-gray-300 px-4 py-2">{parseFloat(item.Percentage).toFixed(2)}%</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
        
        {/* Phân trang */}
        <div className="flex justify-center mt-4">
          <button
            onClick={() => setCurrentPage(prevPage => Math.max(prevPage - 1, 1))}
            className="px-4 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 disabled:bg-gray-300"
            disabled={currentPage === 1}
          >
            Trước
          </button>
          <span className="mx-4">{currentPage} / {totalPages}</span>
          <button
            onClick={() => setCurrentPage(prevPage => Math.min(prevPage + 1, totalPages))}
            className="px-4 py-2 bg-orange-500 text-white rounded-md hover:bg-orange-600 disabled:bg-gray-300"
            disabled={currentPage === totalPages}
          >
            Sau
          </button>
        </div>
      </div>
    </div>
  );
};

export default Chitietcuahang;
