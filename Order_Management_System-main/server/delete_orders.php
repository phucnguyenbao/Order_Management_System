<?php
header("Access-Control-Allow-Methods: DELETE");
include("db_connection.php");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header("HTTP/1.1 200 OK");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Authorization");
    exit();
}
// Kết nối cơ sở dữ liệu
$conn = connectDB();

// Lấy Mã đơn hàng từ URL
$maDonHang = isset($_GET['MaDonHang']) ? $_GET['MaDonHang'] : '';

if ($maDonHang) {
    try {
        // Câu lệnh SQL để xóa đơn hàng
        $deleteQuery = "EXEC DeleteDonHang @MaDonHang = :maDonHang";
        $stmt = $conn->prepare($deleteQuery);
        $stmt->bindParam(':maDonHang', $maDonHang, PDO::PARAM_INT);
        $stmt->execute();

        // Trả về kết quả thành công
        echo json_encode(['message' => 'Xóa đơn hàng thành công.']);
    } catch (PDOException $e) {
        // Trả về lỗi nếu có vấn đề khi xóa đơn hàng
        echo json_encode(['error' => 'Lỗi khi xóa đơn hàng: ' . $e->getMessage()]);
    }
} else {
    // Trả về lỗi nếu thiếu mã đơn hàng
    echo json_encode(['error' => 'Mã đơn hàng không hợp lệ.']);
}
?>
