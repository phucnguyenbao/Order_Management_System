<?php
header("Access-Control-Allow-Methods: POST, PUT");
header("Access-Control-Allow-Headers: Content-Type");
include("db_connection.php");
// Lấy dữ liệu JSON từ yêu cầu POST
$data = json_decode(file_get_contents("php://input"), true);

// Kiểm tra dữ liệu đã được gửi đúng chưa
if (isset($data['MaDonHang'])) {
    // Lấy dữ liệu từ form
    $MaDonHang = $data['MaDonHang'];
    $NgayTao = $data['NgayTao'];
    $TongSoTien = $data['TongSoTien'];
    $TrangThaiDonHang = $data['TrangThaiDonHang'];
    $NhanVienXuLy = $data['NhanVienXuLy'];
    $KhoChua = $data['KhoChua'];
    $NguoiNhan = $data['NguoiNhan'];
    $CuaHangGui = $data['CuaHangGui'];
    $NgayThanhToan = $data['NgayThanhToan'];
    $PhuongThucThanhToan = $data['PhuongThucThanhToan'];

    // Kết nối cơ sở dữ liệu
    $conn = connectDB();

    // Chuẩn bị câu lệnh gọi stored procedure
    $sql = "EXEC UpdateDonHang
            :MaDonHang, 
            :NgayTao, 
            :TongSoTien, 
            :TrangThaiDonHang, 
            :NhanVienXuLy, 
            :KhoChua, 
            :NguoiNhan, 
            :CuaHangGui, 
            :NgayThanhToan, 
            :PhuongThucThanhToan";

    // Chuẩn bị câu lệnh SQL
    $stmt = $conn->prepare($sql);

    // Gắn giá trị vào các tham số trong câu lệnh
    $stmt->bindParam(':MaDonHang', $MaDonHang);
    $stmt->bindParam(':NgayTao', $NgayTao);
    $stmt->bindParam(':TongSoTien', $TongSoTien);
    $stmt->bindParam(':TrangThaiDonHang', $TrangThaiDonHang);
    $stmt->bindParam(':NhanVienXuLy', $NhanVienXuLy);
    $stmt->bindParam(':KhoChua', $KhoChua);
    $stmt->bindParam(':NguoiNhan', $NguoiNhan);
    $stmt->bindParam(':CuaHangGui', $CuaHangGui);
    $stmt->bindParam(':NgayThanhToan', $NgayThanhToan);
    $stmt->bindParam(':PhuongThucThanhToan', $PhuongThucThanhToan);

    try {
        // Thực thi câu lệnh
        $stmt->execute();

        // Kiểm tra kết quả thực thi câu lệnh
        if ($stmt->rowCount() > 0) {
            echo json_encode(['message' => 'Cập nhật đơn hàng thành công', 'success' => true]);
        } 

    } catch (PDOException $e) {
    // Lấy thông báo lỗi từ PDOException
    $errorMessage = $e->getMessage();

    // Loại bỏ phần "SQLSTATE" hoặc thông tin kỹ thuật
    if (strpos($errorMessage, '[SQL Server]') !== false) {
        $errorMessage = substr($errorMessage, strpos($errorMessage, '[SQL Server]') + 12); // Lấy phần sau "[SQL Server]"
    }

    // Trả về lỗi đơn giản hơn
    echo json_encode(['success' => false, 'error' => $errorMessage]);
    }
} else {
    echo json_encode(['message' => 'Dữ liệu không hợp lệ.']);
}
        // Đóng kết nối
        $stmt = null;
        $conn = null;
?>
