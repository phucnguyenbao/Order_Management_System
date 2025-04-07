<?php


// Cấu hình kết nối
$connectionString = "sqlsrv:Server=$serverName;Database=$database";

try {
    // Tạo kết nối PDO
    $conn = new PDO($connectionString, $username, $password);
    
    // Thiết lập chế độ lỗi cho PDO
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Truy vấn dữ liệu từ bảng Shipper
    $sql = "SELECT * 
FROM dbo.EvaluateEmployeeSkillCapacityByPosition('Quan li');";
    $stmt = $conn->query($sql);

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        // Lặp qua tất cả các trường (cột) và hiển thị
        foreach ($row as $column => $value) {
            echo $column . ": " . $value . "<br>";
        }
        echo "<br>"; // Dòng trống giữa các bản ghi
    }
} catch (PDOException $e) {
    echo "Kết nối thất bại: " . $e->getMessage();
}