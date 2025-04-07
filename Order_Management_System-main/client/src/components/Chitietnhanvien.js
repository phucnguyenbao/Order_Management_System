import React, { useState, useEffect } from "react";
import axios from "axios"; // Ensure axios is installed

const Chitietnhanvien = () => {
  const [position, setPosition] = useState(""); // Store selected position
  const [searchTerm, setSearchTerm] = useState(""); // Store full name search term
  const [employeeData, setEmployeeData] = useState([]); // Store employee data
  const [filteredData, setFilteredData] = useState([]); // Store filtered data based on name
  const [error, setError] = useState(null); // Store any fetch errors
  const [currentPage, setCurrentPage] = useState(1); // Store current page
  const [itemsPerPage] = useState(5); // Set the number of items per page
  
  const totalPages = Math.ceil(filteredData.length / itemsPerPage); // Calculate total pages

  // Function to fetch employee data from PHP backend based on position
  const fetchEmployeeData = async (position) => {
    try {
      const response = await axios.get('http://localhost:8000/get_employee_skills.php', {
        params: { position },
        timeout: 5000,
      });
  
      console.log("Raw Response:", response.data);
  
      // Kiểm tra nếu phản hồi là chuỗi JSON
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
  
      setEmployeeData(data); // Set all employee data based on position
      setFilteredData(data); // Initially, show all data without filtering by name
      setCurrentPage(1); // Reset to the first page when position changes
      setError(null);
    } catch (error) {
      console.error("Error fetching employee data:", error);
      setError("Failed to fetch employee data");
      setEmployeeData([]);
      setFilteredData([]);
    }
  };

  // UseEffect to fetch data when position changes
  useEffect(() => {
    if (position) {
      fetchEmployeeData(position);
    }
  }, [position]);

  // Handle searching by full name
  const handleSearchByName = () => {
    if (searchTerm) {
      const filtered = employeeData.filter((employee) =>
        employee.FullName.toLowerCase().includes(searchTerm.toLowerCase())
      );
      setFilteredData(filtered);
      setCurrentPage(1); // Reset to the first page after search
    } else {
      setFilteredData(employeeData); // If searchTerm is empty, show all data
      setCurrentPage(1); // Reset to the first page
    }
  };

  // Get data for current page
  const getCurrentPageData = () => {
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    return filteredData.slice(startIndex, endIndex);
  };

  // Handle page navigation
  const handlePageChange = (page) => {
    if (page >= 1 && page <= totalPages) {
      setCurrentPage(page);
    }
  };

  return (
    <div className="bg-gradient-to-r from-orange-400 to-red-500 w-full min-h-screen flex flex-col items-center">
      {/* Title */}
      <div className="w-main h-[110px] py-[35px] flex items-center justify-center mb-4">
        <h2 className="text-2xl font-bold text-white">NHÂN VIÊN XUẤT SẮC NHẤT</h2>
      </div>

      {/* Main content area */}
      <div className="bg-white shadow-lg rounded-lg p-6 relative  w-11/12 max-w-6xl">
        {/* Position selection buttons */}
        <div className="absolute -top-10 left-1/2 transform -translate-x-1/2 flex space-x-4">
          <button
            onClick={() => setPosition("Quan li")}
            className={`w-40 h-16 flex items-center justify-center px-4 py-2 rounded-full shadow-md transition-transform transform ${
              position === "Quan li"
                ? "bg-indigo-600 text-white scale-110"
                : "bg-gray-100 text-gray-800 hover:bg-gray-200"
            }`}
          >
            Nhân viên<br />quản lí
          </button>
          <button
            onClick={() => setPosition("Ho tro")}
            className={`w-40 h-16 flex items-center justify-center px-4 py-2 rounded-full shadow-md transition-transform transform ${
              position === "Ho tro"
                ? "bg-teal-600 text-white scale-110"
                : "bg-gray-100 text-gray-800 hover:bg-gray-200"
            }`}
          >
            Nhân viên<br />hỗ trợ
          </button>
          <button
            onClick={() => setPosition("Van hanh")}
            className={`w-40 h-16 flex items-center justify-center px-4 py-2 rounded-full shadow-md transition-transform transform ${
              position === "Van hanh"
                ? "bg-yellow-600 text-white scale-110"
                : "bg-gray-100 text-gray-800 hover:bg-gray-200"
            }`}
          >
            Nhân viên<br />vận hành
          </button>
        </div>

      {/* Search input for full name */}
<div className="mt-6 flex justify-center">
  <div className="flex items-center w-full max-w-md">
    <input
      type="text"
      placeholder="Tìm kiếm theo họ và tên"
      value={searchTerm}
      onChange={(e) => setSearchTerm(e.target.value)}
      onKeyDown={(e) => e.key === "Enter" && handleSearchByName()}
      className="px-4 py-2 border rounded-l-lg flex-grow"
    />
    <button
      onClick={handleSearchByName}
      className="px-4 py-2 bg-blue-500 text-white rounded-r-lg"
    >
      Tìm kiếm
    </button>
  </div>
</div>


        {/* Table content */}
        {error && (
          <div className="mt-12 text-red-500 text-center">
            {error}
          </div>
        )}

        {filteredData.length > 0 ? (
          <>
            <table className="w-full table-auto bg-white shadow-md rounded-lg mt-12">
              <thead>
                <tr>
                  <th className="px-4 py-2 border text-left">CCCD</th>
                  <th className="px-4 py-2 border text-left w-1/5">Họ và Tên</th>
                  <th className="px-4 py-2 border text-center w-30">Số Kỹ Năng</th>
                  <th className="px-4 py-2 border text-left w-100">Danh Sách Kỹ Năng</th>
                  <th className="px-4 py-2 border text-left">Tổng Điểm Kỹ Năng</th>
                  <th className="px-4 py-2 border text-left w-1/5">Mức Độ Năng Lực</th>
                </tr>
              </thead>
              <tbody>
                {getCurrentPageData().map((employee) => (
                  <tr key={employee.CCCD}>
                    <td className="px-4 py-2 border">{employee.CCCD}</td>
                    <td className="px-4 py-2 border">{employee.FullName}</td>
                    <td className="px-4 py-2 border text-center">{employee.SkillCount}</td>
                    <td className="px-4 py-2 border">{employee.SkillList}</td>
                    <td className="px-4 py-2 border text-center">{employee.SkillPointTotal}</td>
                    <td className="px-4 py-2 border">{employee.CapacityLevel}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* Pagination controls */}
            <div className="flex justify-center mt-6">
              <button
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg mr-2"
              >
                &#8592; Trước
              </button>
              <span className="flex items-center justify-center px-4 py-2 text-lg font-semibold">
                Trang {currentPage} / {totalPages}
              </span>
              <button
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg ml-2"
              >
                Tiếp theo &#8594;
              </button>
            </div>
          </>
        ) : (
          <div className="mt-12 text-gray-500 text-center">
            Chưa có dữ liệu.
          </div>
        )}
      </div>
    </div>
  );
};

export default Chitietnhanvien;
