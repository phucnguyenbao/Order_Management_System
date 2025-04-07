<?php
include("db_connection.php");

// API lấy danh sách đơn hàng
if ($_SERVER['REQUEST_METHOD'] === 'GET' && strpos($_SERVER['REQUEST_URI'], 'fetch_orders.php') !== false) {
    $trangThai = $_GET['trangthai'] ?? '';
    $page = isset($_GET['page']) ? intval($_GET['page']) : 1;
    $maDonHang = $_GET['madonhang'] ?? ''; // Thêm mã đơn hàng nếu cần
    $pageSize = 10;
    $offset = ($page - 1) * $pageSize;
    // Nếu có trạng thái, xử lý chuyển chuỗi có dấu thành không dấu
if (!empty($trangThai)) {
    $trangThai = removeVietnameseAccents($trangThai);
}

    $pdo = connectDB();

    if (!empty($maDonHang)) {
        // Lấy chi tiết một đơn hàng cụ thể
        $stmt = $pdo->prepare("SELECT * FROM DonHang WHERE MaDonHang = :madonhang");
        $stmt->bindValue(':madonhang', $maDonHang, PDO::PARAM_STR);
        $stmt->execute();
        $orderDetails = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['order' => $orderDetails]);
        exit;
    }

    // Đếm tổng số đơn hàng
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM DonHang WHERE TrangThaiDonHang = :trangthai");
    $stmt->execute([':trangthai' => $trangThai]);
    $totalRecords = $stmt->fetchColumn();
    $totalPages = ceil($totalRecords / $pageSize);

    // Lấy danh sách đơn hàng theo trang
    $stmt = $pdo->prepare(
        "SELECT * FROM DonHang
        WHERE TrangThaiDonHang = :trangthai 
        ORDER BY MaDonHang 
        OFFSET :offset ROWS FETCH NEXT :pagesize ROWS ONLY"
    );
    $stmt->bindValue(':trangthai', $trangThai, PDO::PARAM_STR);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->bindValue(':pagesize', $pageSize, PDO::PARAM_INT);
    $stmt->execute();
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'orders' => $orders,
        'pagination' => ['currentPage' => $page, 'totalPages' => $totalPages]
    ]);
    exit;
}
?>