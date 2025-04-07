<?php
include("db_connection.php");

// Kiểm tra nếu có tham số position
if (isset($_GET['position'])) {
    $position = $_GET['position'];

    try {
        // Kết nối cơ sở dữ liệu
        $conn = connectDB();

        // Gọi function SQL để lấy dữ liệu nhân viên theo vị trí
        $sql = "SELECT * FROM dbo.EvaluateEmployeeSkillCapacityByPosition(:position)";
        $stmt = $conn->prepare($sql);
        $stmt->bindParam(':position', $position, PDO::PARAM_STR);

        if ($stmt->execute()) {
            $employees = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode($employees);
        } else {
            echo json_encode(["error" => "Không thể lấy dữ liệu"]);
        }
    } catch (Exception $e) {
        echo json_encode(['error' => 'Lỗi thực thi: ' . $e->getMessage()]);
    }
} else {
    echo json_encode(["error" => "Thiếu tham số position"]);
}
?>
