<?php
include("db_connection.php");

// Đảm bảo là phương thức GET
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Kiểm tra xem tham số 'position' có tồn tại trong request hay không
    if (isset($_GET['position'])) {
        $position = $_GET['position'];
        
        try {
            // Kết nối cơ sở dữ liệu
            $conn = connectDB();

            // Chuẩn bị câu lệnh SQL với tham số động
            $sql = "SELECT * FROM dbo.EvaluateEmployeeSkillCapacityByPosition(:position)";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':position', $position, PDO::PARAM_STR); // Bó buộc tham số 'position'
            $stmt->execute();

            // Lấy dữ liệu và trả về dưới dạng JSON
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($data);
        } catch (PDOException $e) {
            echo json_encode(['error' => 'Lỗi truy vấn cơ sở dữ liệu: ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['error' => 'Thiếu tham số "position".']);
    }
} else {
    echo json_encode(['error' => 'Phương thức không được hỗ trợ. Chỉ hỗ trợ GET.']);
}
?>
