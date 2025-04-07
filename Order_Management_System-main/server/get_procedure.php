<?php

header('Access-Control-Allow-Origin: *'); // Cho phép truy cập từ mọi nguồn
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Cho phép các phương thức HTTP
header('Access-Control-Allow-Headers: Content-Type'); // Cho phép các header
header('Content-Type: application/json'); // Định dạng JSON cho output

include 'db_connection.php'; // Import các hàm kết nối và xử lý

// Lấy tham số TrangThai từ URL
$trangThai = isset($_GET['TrangThai']) ? $_GET['TrangThai'] : '';

if (!$trangThai) {
    // Nếu không có tham số TrangThai, trả về lỗi
    echo json_encode(['error' => 'Tham số TrangThai không được cung cấp']);
    exit;
}

// Loại bỏ dấu tiếng Việt trước khi truyền vào procedure (nếu cần)
$trangThai = removeVietnameseAccents($trangThai);

try {
    // Kết nối cơ sở dữ liệu
    $conn = connectDB();

    // Thực thi stored procedure với tham số
    $query = "EXEC GetOrdersByStatusAndDate @TrangThai = :TrangThai";
    $stmt = $conn->prepare($query);
    $stmt->bindParam(':TrangThai', $trangThai, PDO::PARAM_STR);
    $stmt->execute();

    // Lấy kết quả trả về
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Trả về dữ liệu dưới dạng JSON
    echo json_encode($result);
} catch (PDOException $e) {
    // Nếu có lỗi, trả về lỗi dưới dạng JSON
    echo json_encode(['error' => $e->getMessage()]);
}
?>
