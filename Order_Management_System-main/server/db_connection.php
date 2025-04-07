<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

header('Access-Control-Allow-Origin: *'); // Cho phép truy cập từ mọi nguồn
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Cho phép các phương thức HTTP
header('Access-Control-Allow-Headers: Content-Type'); // Cho phép các header
header('Content-Type: application/json'); // Định dạng JSON cho output
// Kết nối cơ sở dữ liệu
function connectDB() {
    $serverName = "DESKTOP-4CDMDCJ"; 
    $database = "database2";        
    $username = "";                
    $password = "";              

    try {
        $pdo = new PDO("sqlsrv:Server=$serverName;Database=$database", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        // echo "Kết nối cơ sở dữ liệu thành công!";
        return $pdo;
    } catch (PDOException $e) {
        die(json_encode(['error' => 'Lỗi kết nối cơ sở dữ liệu: ' . $e->getMessage()]));
    }
}
// // Gọi hàm kết nối để kiểm tra
// connectDB();


// Hàm loại bỏ dấu tiếng Việt
function removeVietnameseAccents($str) {
    $accents = [
        'a' => ['à', 'á', 'ạ', 'ả', 'ã', 'â', 'ầ', 'ấ', 'ậ', 'ẩ', 'ẫ', 'ă', 'ằ', 'ắ', 'ặ', 'ẳ', 'ẵ'],
        'e' => ['è', 'é', 'ẹ', 'ẻ', 'ẽ', 'ê', 'ề', 'ế', 'ệ', 'ể', 'ễ'],
        'i' => ['ì', 'í', 'ị', 'ỉ', 'ĩ'],
        'o' => ['ò', 'ó', 'ọ', 'ỏ', 'õ', 'ô', 'ồ', 'ố', 'ộ', 'ổ', 'ỗ', 'ơ', 'ờ', 'ớ', 'ợ', 'ở', 'ỡ'],
        'u' => ['ù', 'ú', 'ụ', 'ủ', 'ũ', 'ư', 'ừ', 'ứ', 'ự', 'ử', 'ữ'],
        'y' => ['ỳ', 'ý', 'ỵ', 'ỷ', 'ỹ'],
        'd' => ['đ'],
        'A' => ['À', 'Á', 'Ạ', 'Ả', 'Ã', 'Â', 'Ầ', 'Ấ', 'Ậ', 'Ẩ', 'Ẫ', 'Ă', 'Ằ', 'Ắ', 'Ặ', 'Ẳ', 'Ẵ'],
        'E' => ['È', 'É', 'Ẹ', 'Ẻ', 'Ẽ', 'Ê', 'Ề', 'Ế', 'Ệ', 'Ể', 'Ễ'],
        'I' => ['Ì', 'Í', 'Ị', 'Ỉ', 'Ĩ'],
        'O' => ['Ò', 'Ó', 'Ọ', 'Ỏ', 'Õ', 'Ô', 'Ồ', 'Ố', 'Ộ', 'Ổ', 'Ỗ', 'Ơ', 'Ờ', 'Ớ', 'Ợ', 'Ở', 'Ỡ'],
        'U' => ['Ù', 'Ú', 'Ụ', 'Ủ', 'Ũ', 'Ư', 'Ừ', 'Ứ', 'Ự', 'Ử', 'Ữ'],
        'Y' => ['Ỳ', 'Ý', 'Ỵ', 'Ỷ', 'Ỹ'],
        'D' => ['Đ'],
    ];

    foreach ($accents as $nonAccent => $accentsArray) {
        $str = str_replace($accentsArray, $nonAccent, $str);
    }

    return $str;
}
?>