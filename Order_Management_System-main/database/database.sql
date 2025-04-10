USE [master]
GO
/****** Object:  Database [database2]    Script Date: 4/7/2025 5:09:47 PM ******/
CREATE DATABASE [database2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'database2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\database2.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'database2_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\database2_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [database2] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [database2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [database2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [database2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [database2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [database2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [database2] SET ARITHABORT OFF 
GO
ALTER DATABASE [database2] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [database2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [database2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [database2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [database2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [database2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [database2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [database2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [database2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [database2] SET  DISABLE_BROKER 
GO
ALTER DATABASE [database2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [database2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [database2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [database2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [database2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [database2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [database2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [database2] SET RECOVERY FULL 
GO
ALTER DATABASE [database2] SET  MULTI_USER 
GO
ALTER DATABASE [database2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [database2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [database2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [database2] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [database2] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [database2] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'database2', N'ON'
GO
ALTER DATABASE [database2] SET QUERY_STORE = ON
GO
ALTER DATABASE [database2] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [database2]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateDeliveryStatusByStore]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE FUNCTION [dbo].[CalculateDeliveryStatusByStore] (
    @StoreID NVARCHAR(20),
    @OrderStatus NVARCHAR(50)
)
RETURNS @DeliveryStatusResult TABLE (
    Quan NVARCHAR(50),
    ThanhPho NVARCHAR(50),
    SoLuong INT,
    Percentage DECIMAL(5, 2)
)
AS
BEGIN
    -- Biến tổng số đơn hàng theo trạng thái
    DECLARE @TotalOrders INT;
    SET @TotalOrders = (
        SELECT COUNT(*)
        FROM DonHang AS DH
        WHERE DH.CuaHangGui = @StoreID AND DH.TrangThaiDonHang = @OrderStatus
    );

    -- Kiểm tra nếu không có đơn hàng thì trả về rỗng
    IF @TotalOrders = 0
        RETURN;

    -- Cursor để duyệt qua từng Quận và Thành phố
    DECLARE @CurrentQuan NVARCHAR(50), @CurrentThanhPho NVARCHAR(50);
    DECLARE @CurrentCount INT = 0;

    DECLARE QuanThanhPhoCursor CURSOR FOR
    SELECT DISTINCT N.Quan, N.ThanhPho
    FROM DonHang AS DH
    JOIN NguoiNhan AS NN ON DH.NguoiNhan = NN.CCCD
    JOIN Nguoi AS N ON NN.CCCD = N.CCCD
    WHERE DH.CuaHangGui = @StoreID;

    OPEN QuanThanhPhoCursor;
    FETCH NEXT FROM QuanThanhPhoCursor INTO @CurrentQuan, @CurrentThanhPho;

    -- LOOP qua từng Quận và Thành phố
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tính số lượng đơn hàng tại Quận và Thành phố hiện tại
        SELECT @CurrentCount = COUNT(*)
        FROM DonHang AS DH
        JOIN NguoiNhan AS NN ON DH.NguoiNhan = NN.CCCD
        JOIN Nguoi AS N ON NN.CCCD = N.CCCD
        WHERE DH.CuaHangGui = @StoreID
        AND N.Quan = @CurrentQuan
        AND N.ThanhPho = @CurrentThanhPho
        AND DH.TrangThaiDonHang = @OrderStatus;

        -- Nếu có đơn hàng, tính phần trăm và thêm vào bảng tạm
        IF @CurrentCount > 0
        BEGIN
            INSERT INTO @DeliveryStatusResult (Quan, ThanhPho, SoLuong, Percentage)
            VALUES (
                @CurrentQuan, 
                @CurrentThanhPho, 
                @CurrentCount, 
                CAST(@CurrentCount AS DECIMAL(5,2)) / CAST(@TotalOrders AS DECIMAL(5,2)) * 100
            );
        END;

        FETCH NEXT FROM QuanThanhPhoCursor INTO @CurrentQuan, @CurrentThanhPho;
    END;

    CLOSE QuanThanhPhoCursor;
    DEALLOCATE QuanThanhPhoCursor;

    RETURN;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[EvaluateEmployeeSkillCapacityByPosition]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[EvaluateEmployeeSkillCapacityByPosition]
(
    @ViTri NVARCHAR(50) -- Tham số vị trí của nhân viên
)
RETURNS @EmployeeSkillResult TABLE
(
    CCCD NVARCHAR(12),
    FullName NVARCHAR(100),
    SkillCount INT,
    SkillList NVARCHAR(MAX),
    SkillPointTotal INT,
    CapacityLevel NVARCHAR(50)
)
AS
BEGIN
    -- Khai báo các biến
    DECLARE @CurrentCCCD NVARCHAR(12);
    DECLARE @CurrentHo NVARCHAR(50);
    DECLARE @CurrentTen NVARCHAR(50);
    
    -- Bảng tạm lưu trữ thông tin kỹ năng của nhân viên
    DECLARE @EmployeeSkills TABLE (
        CCCD NVARCHAR(12),
        Ho NVARCHAR(50),
        Ten NVARCHAR(50),
        KyNang NVARCHAR(100),
        SkillPoint INT
    );

    -- Lấy dữ liệu kỹ năng của nhân viên vào bảng tạm
    INSERT INTO @EmployeeSkills
    SELECT 
        NV.CCCD, 
        NN.Ho, 
        NN.Ten, 
        KN.KyNang,
        CASE 
            WHEN KN.KyNang LIKE '%Quan li kho%' THEN 15
            WHEN KN.KyNang LIKE '%Dieu phoi va sap xep%' THEN 15
            WHEN KN.KyNang LIKE '%Cham soc khach hang%' THEN 20
            WHEN KN.KyNang LIKE '%Xu li khieu nai%' THEN 30
            WHEN KN.KyNang LIKE '%Van hanh he thong%' THEN 20
            ELSE 10
        END AS SkillPoint
    FROM NhanVien NV
    JOIN Nguoi NN ON NV.CCCD = NN.CCCD
    LEFT JOIN KyNangNhanVien KN ON NV.CCCD = KN.CCCD
    WHERE NV.ViTri = @ViTri; -- Lọc theo vị trí được truyền vào

    -- Con trỏ xử lý từng nhân viên với vị trí lọc theo tham số
    DECLARE EmployeeCursor CURSOR FOR 
    SELECT DISTINCT CCCD, Ho, Ten 
    FROM @EmployeeSkills;

    -- Mở con trỏ
    OPEN EmployeeCursor;

    -- Lấy dòng dữ liệu đầu tiên
    FETCH NEXT FROM EmployeeCursor INTO @CurrentCCCD, @CurrentHo, @CurrentTen;

    -- Vòng lặp xử lý dữ liệu
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Các biến để tính toán số lượng kỹ năng, tổng điểm kỹ năng và danh sách kỹ năng
        DECLARE @TotalSkillCount INT = 0;  -- Khởi tạo với giá trị mặc định là 0
        DECLARE @TotalSkillPoints INT = 0;  -- Khởi tạo với giá trị mặc định là 0
        DECLARE @ConcatenatedSkills NVARCHAR(MAX) = '';  -- Khởi tạo với giá trị mặc định là chuỗi rỗng

        -- Tính toán số liệu cho từng nhân viên
        SELECT 
            @TotalSkillCount = COUNT(KyNang),
            @TotalSkillPoints = SUM(SkillPoint),
            @ConcatenatedSkills = STRING_AGG(KyNang, ', ')
        FROM @EmployeeSkills
        WHERE CCCD = @CurrentCCCD;

        -- Chèn kết quả vào bảng kết quả trả về
        INSERT INTO @EmployeeSkillResult
        (
            CCCD, 
            FullName, 
            SkillCount, 
            SkillList, 
            SkillPointTotal,
            CapacityLevel
        )
        VALUES
        (
            @CurrentCCCD,
            @CurrentHo + ' ' + @CurrentTen,
            @TotalSkillCount,
            CASE WHEN @TotalSkillCount > 0 THEN @ConcatenatedSkills ELSE 'Khong co' END,
            @TotalSkillPoints,
            CASE 
                WHEN @TotalSkillPoints <= 50 THEN 'Nhan vien moi'
                WHEN @TotalSkillPoints > 50 AND @TotalSkillPoints <= 70 THEN 'Nhan vien tiem nang'
                WHEN @TotalSkillPoints > 70 THEN 'Nhan vien xuat sac'
                ELSE 'Khong xac dinh'
            END
        );

        -- Lấy dòng tiếp theo
        FETCH NEXT FROM EmployeeCursor INTO @CurrentCCCD, @CurrentHo, @CurrentTen;
    END

    -- Đóng và giải phóng con trỏ
    CLOSE EmployeeCursor;
    DEALLOCATE EmployeeCursor;

    -- Trả về kết quả
    RETURN;
END;
GO
/****** Object:  Table [dbo].[Nguoi]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Nguoi](
	[CCCD] [nvarchar](12) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[Ho] [nvarchar](50) NULL,
	[Ten] [nvarchar](50) NULL,
	[SDT] [nvarchar](15) NULL,
	[SoNha] [nvarchar](50) NULL,
	[Duong] [nvarchar](100) NULL,
	[Quan] [nvarchar](50) NULL,
	[ThanhPho] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NguoiNhan]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NguoiNhan](
	[CCCD] [nvarchar](12) NOT NULL,
	[LichSuDatHang] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DonHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DonHang](
	[MaDonHang] [nvarchar](20) NOT NULL,
	[NgayTao] [date] NULL,
	[TongSoTien] [int] NULL,
	[TrangThaiDonHang] [nvarchar](50) NULL,
	[NhanVienXuLy] [nvarchar](12) NULL,
	[KhoChua] [nvarchar](20) NULL,
	[NguoiNhan] [nvarchar](12) NULL,
	[CuaHangGui] [nvarchar](20) NULL,
	[NgayThanhToan] [date] NULL,
	[PhuongThucThanhToan] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDonHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[StatisticsByStore]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[StatisticsByStore] (@StoreID NVARCHAR(20))
RETURNS TABLE
AS
RETURN
    WITH OrderCounts AS (
        -- Tính tổng số đơn hàng theo Quận và Thành phố
        SELECT
            n.Quan,
            n.ThanhPho,
            COUNT(d.MaDonHang) AS OrderCount
        FROM
            DonHang d
        INNER JOIN NguoiNhan nn ON d.NguoiNhan = nn.CCCD
        INNER JOIN Nguoi n ON nn.CCCD = n.CCCD
        WHERE
            d.CuaHangGui = @StoreID
        GROUP BY
            n.Quan, n.ThanhPho
    ),
    TotalOrders AS (
        -- Tính tổng số đơn hàng của cửa hàng
        SELECT
            COUNT(d.MaDonHang) AS TotalOrders
        FROM
            DonHang d
        WHERE
            d.CuaHangGui = @StoreID
    )
   SELECT 
        oc.Quan + ', ' + oc.ThanhPho AS Address,
        ROUND(CAST(oc.OrderCount AS FLOAT) / CAST(t.TotalOrders AS FLOAT) * 100, 2) AS Percentage
    FROM
        OrderCounts oc
    CROSS JOIN TotalOrders t;
GO
/****** Object:  Table [dbo].[ChuyenGiaoHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChuyenGiaoHang](
	[MaChuyen] [nvarchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MaChuyen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CuaHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CuaHang](
	[MaCuaHang] [nvarchar](20) NOT NULL,
	[TenCuaHang] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[SoNha] [nvarchar](50) NULL,
	[Duong] [nvarchar](100) NULL,
	[Quan] [nvarchar](50) NULL,
	[ThanhPho] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaCuaHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GiamSat]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiamSat](
	[CCCD] [nvarchar](12) NOT NULL,
	[NguoiGiamSat] [nvarchar](12) NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Gom]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Gom](
	[MaSanPham] [nvarchar](20) NOT NULL,
	[MaDonHang] [nvarchar](20) NOT NULL,
	[SoLuong] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSanPham] ASC,
	[MaDonHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Kho]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Kho](
	[MaKho] [nvarchar](20) NOT NULL,
	[SucChuaToiDa] [int] NULL,
	[SoNha] [nvarchar](50) NULL,
	[Duong] [nvarchar](50) NULL,
	[Quan] [nvarchar](50) NULL,
	[ThanhPho] [nvarchar](50) NULL,
	[NhanVienQuanLy] [nvarchar](12) NULL,
	[SoLuongDonHang] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaKho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KyNangNhanVien]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KyNangNhanVien](
	[CCCD] [nvarchar](12) NOT NULL,
	[KyNang] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC,
	[KyNang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[CCCD] [nvarchar](12) NOT NULL,
	[ViTri] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SanPham]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SanPham](
	[MaSanPham] [nvarchar](20) NOT NULL,
	[TenSanPham] [nvarchar](100) NULL,
	[SoLuong] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSanPham] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SanPhamHoanTra]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SanPhamHoanTra](
	[MaDonHang] [nvarchar](20) NOT NULL,
	[MaSanPham] [nvarchar](20) NOT NULL,
	[NgayHoanTra] [date] NULL,
	[LyDoTra] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDonHang] ASC,
	[MaSanPham] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Shipper]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shipper](
	[CCCD] [nvarchar](12) NOT NULL,
	[LoaiXe] [nvarchar](50) NULL,
	[BienSo] [nvarchar](20) NULL,
	[KhuVucGiaoHang] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThucHienGiao]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThucHienGiao](
	[MaDonHang] [nvarchar](20) NOT NULL,
	[MaChuyen] [nvarchar](20) NULL,
	[CCCD] [nvarchar](12) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDonHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[ChuyenGiaoHang] ([MaChuyen]) VALUES (N'CG01')
INSERT [dbo].[ChuyenGiaoHang] ([MaChuyen]) VALUES (N'CG02')
INSERT [dbo].[ChuyenGiaoHang] ([MaChuyen]) VALUES (N'CG03')
INSERT [dbo].[ChuyenGiaoHang] ([MaChuyen]) VALUES (N'CG04')
GO
INSERT [dbo].[CuaHang] ([MaCuaHang], [TenCuaHang], [Email], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'CH01', N'Cua Hang Dien Tu Minh Anh', N'dienminhanh@email.com', N'5', N'Le Duan', N'Hoan Kiem', N'Ha Noi')
INSERT [dbo].[CuaHang] ([MaCuaHang], [TenCuaHang], [Email], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'CH02', N'Cua Hang Thoi Trang Thanh Hoa', N'thoitrangthanhhoa@email.com', N'10', N'Tran Phu', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[CuaHang] ([MaCuaHang], [TenCuaHang], [Email], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'CH03', N'Cua Hang Dien May Hoang Phat', N'dienmayhoangphat@email.com', N'20', N'Hoang Cau', N'Dong Da', N'Ha Noi')
INSERT [dbo].[CuaHang] ([MaCuaHang], [TenCuaHang], [Email], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'CH04', N'Cua Hang Do Gia Dung Nam Anh', N'giadungnamanh@email.com', N'25', N'Nguyen Trai', N'Thanh Xuan', N'Ha Noi')
INSERT [dbo].[CuaHang] ([MaCuaHang], [TenCuaHang], [Email], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'CH05', N'Cua Hang Dien May Sai Gon', N'dienmaysaigon@email.com', N'90', N'Nguyen Thi Minh Khai', N'Quan 1', N'Ho Chi Minh')
GO
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH01', CAST(N'2024-12-11' AS Date), 30000000, N'Da huy', N'300000000001', N'K01', N'200000000001', N'CH01', CAST(N'2024-12-11' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH02', CAST(N'2024-12-11' AS Date), 10, N'Da giao hang', N'300000000003', N'K03', N'200000000002', N'CH02', CAST(N'2024-12-11' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH03', CAST(N'2024-12-08' AS Date), 10, N'Da huy', N'300000000003', N'K05', N'200000000002', N'CH02', CAST(N'2024-12-08' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH04', CAST(N'2024-12-04' AS Date), 1200011, N'Da giao hang', N'300000000003', N'K05', N'200000000007', N'CH02', CAST(N'2024-12-05' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH06', CAST(N'2024-12-07' AS Date), 2500000, N'Dang cho xy ly', N'300000000005', N'K07', N'200000000004', N'CH02', CAST(N'2024-12-08' AS Date), N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH07', CAST(N'2024-12-10' AS Date), 3000087, N'Dang giao hang', N'300000000006', N'K08', N'200000000008', N'CH02', CAST(N'2024-12-10' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH08', CAST(N'2024-12-09' AS Date), 4000000, N'Dang cho xu ly', N'300000000007', N'K03', N'200000000009', N'CH02', NULL, N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH09', CAST(N'2024-12-10' AS Date), 1200000, N'Da giao hang', N'300000000008', N'K08', N'200000000010', N'CH02', CAST(N'2024-12-11' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH10', CAST(N'2024-12-11' AS Date), 5000000, N'Dang giao hang', N'300000000009', N'K03', N'200000000011', N'CH05', NULL, N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH11', CAST(N'2024-12-12' AS Date), 7000000, N'Da giao hang', N'300000000010', N'K02', N'200000000012', N'CH05', CAST(N'2024-12-13' AS Date), N'Chuyen khoan')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH12', CAST(N'2024-12-13' AS Date), 6000000, N'Dang giao hang', N'300000000011', N'K08', N'200000000013', N'CH01', CAST(N'2024-12-14' AS Date), N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH13', CAST(N'2024-12-08' AS Date), 3000000, N'Dang giao hang', N'300000000001', N'K08', N'200000000008', N'CH02', CAST(N'2024-12-08' AS Date), N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH17', CAST(N'2024-12-11' AS Date), 5000000, N'Dang cho xu ly', N'300000000002', N'K02', N'200000000002', N'CH02', CAST(N'2024-12-11' AS Date), N'Tien mat')
INSERT [dbo].[DonHang] ([MaDonHang], [NgayTao], [TongSoTien], [TrangThaiDonHang], [NhanVienXuLy], [KhoChua], [NguoiNhan], [CuaHangGui], [NgayThanhToan], [PhuongThucThanhToan]) VALUES (N'DH200', CAST(N'2024-12-11' AS Date), 500, N'Dang cho xu ly', N'300000000002', N'K01', N'200000000006', N'CH02', CAST(N'2024-12-11' AS Date), N'Tien mat')
GO
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP01', N'DH01', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP02', N'DH01', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP03', N'DH01', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP03', N'DH02', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP03', N'DH03', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP04', N'DH03', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP05', N'DH04', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP06', N'DH04', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP08', N'DH06', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP09', N'DH06', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP09', N'DH07', 3)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP10', N'DH08', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP11', N'DH09', 1)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP12', N'DH10', 2)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP12', N'DH11', 2)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP12', N'DH12', 2)
INSERT [dbo].[Gom] ([MaSanPham], [MaDonHang], [SoLuong]) VALUES (N'SP12', N'DH13', 2)
GO
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K01', 200, N'10', N'Nguyen Chi Thanh', N'Dong Da', N'Ha Noi', N'300000000002', 2)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K02', 3, N'5', N'Tran Duy Hung', N'Cau Giay', N'Ha Noi', N'300000000002', 2)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K03', 250, N'30', N'Le Van Luong', N'Thanh Xuan', N'Ha Noi', N'300000000003', 2)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K04', 180, N'12', N'Ngo Thi Nham', N'Hai Ba Trung', N'Ha Noi', N'300000000003', 0)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K05', 300, N'20', N'Nguyen Thi Minh Khai', N'Quan 1', N'Ho Chi Minh', N'300000000004', 2)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K06', 300, N'20', N'Nguyen Van Linh', N'Ninh Kieu', N'Can Tho', N'300000000007', 0)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K07', 300, N'35', N'Hoang Dieu', N'Le Chan', N'Hai Phong', N'300000000008', 1)
INSERT [dbo].[Kho] ([MaKho], [SucChuaToiDa], [SoNha], [Duong], [Quan], [ThanhPho], [NhanVienQuanLy], [SoLuongDonHang]) VALUES (N'K08', 300, N'20', N'Ly Tu Trong', N'Hai Chau', N'Da Nang', N'300000000009', 1)
GO
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000001', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000001', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000001', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000002', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000003', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000003', N'Quan li kho ')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000003', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000004', N'Lap ke hoach')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000005', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000006', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000006', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000006', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000007', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000007', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000007', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000007', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000008', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000008', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000008', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000009', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000009', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000009', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000010', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000010', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000010', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000011', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000011', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000011', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000012', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000012', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000012', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000013', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000013', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000013', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000014', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000014', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000014', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000015', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000015', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000015', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000016', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000016', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000016', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000016', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000017', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000017', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000017', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000018', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000018', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000018', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000019', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000019', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000019', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000020', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000020', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000020', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000021', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000021', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000021', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000022', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000022', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000022', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000023', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000023', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000023', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000024', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000024', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000024', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000025', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000025', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000025', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000026', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000026', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000026', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000027', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000027', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000027', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000027', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000028', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000028', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000028', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000029', N'Cham soc khach hang')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000029', N'Quan li kho')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000029', N'Xu li khieu nai')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000030', N'Dieu phoi va sap xep')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000030', N'Van hanh he thong')
INSERT [dbo].[KyNangNhanVien] ([CCCD], [KyNang]) VALUES (N'300000000030', N'Xu li khieu nai')
GO
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000001', N'shipper1@email.com', N'Nguyen', N'Van Hung', N'0912345678', N'10', N'Nguyen Trai', N'Thanh Xuan', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000002', N'shipper2@email.com', N'Tran', N'Van Minh', N'0912345679', N'20', N'Le Loi', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000003', N'shipper3@email.com', N'Pham', N'Thi Mai', N'0912345680', N'30', N'Kim Ma', N'Phu Nhuan', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000004', N'shipper4@email.com', N'Nguyen', N'Van Duy', N'0912345681', N'25', N'Pham Van Dong', N'Binh Thanh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000005', N'shipper5@email.com', N'Le', N'Van Phu', N'0912345682', N'18', N'Le Duc Tho', N'Dong Da', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000006', N'shipper6@email.com', N'Nguyen', N'Thanh Hieu', N'0941234567', N'15', N'Tran Hung Dao', N'Tan Binh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000007', N'shipper7@email.com', N'Le', N'Minh Hoang', N'0942234567', N'55', N'Vo Van Tan', N'Binh Thanh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000008', N'shipper8@email.com', N'Tran', N'Ngoc Hai', N'0943234567', N'8', N'Nguyen Van Cu', N'Quan 1', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000009', N'shipper9@email.com', N'Ho', N'Thanh Hoa', N'0944234567', N'12', N'Le Loi', N'Go Vap', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000010', N'shipper10@email.com', N'Vo', N'Van Long', N'0945234567', N'20', N'Vo Thi Sau', N'Quan 3', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000011', N'shipper11@email.com', N'Nguyen', N'Van Tam', N'0946234567', N'5', N'Ly Tu Trong', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000012', N'shipper12@email.com', N'Pham', N'Ngoc Lan', N'0947234567', N'35', N'Hoang Dieu', N'Le Chan', N'Hai Phong')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'100000000013', N'shipper13@email.com', N'Le', N'Quang Huy', N'0948234567', N'45', N'Nguyen Van Linh', N'Ninh Kieu', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000001', N'nguoinhan1@email.com', N'Le', N'Thi Huong', N'0922345678', N'15', N'Nguyen Du', N'Thanh Xuan', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000002', N'nguoinhan2@email.com', N'Hoang', N'Thi Anh', N'0922345679', N'30', N'Tran Hung Dao', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000003', N'nguoinhan3@email.com', N'Vu', N'Quoc Bao', N'0922345680', N'25', N'Doi Can', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000004', N'nguoinhan4@email.com', N'Bui', N'Thi Lan', N'0922345681', N'50', N'Nguyen Hoang', N'Dong Da', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000005', N'nguoinhan5@email.com', N'Tran', N'Minh Khoa', N'0922345682', N'8', N'Ha Dong', N'Dong Da', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000006', N'nguoinhan6@email.com', N'Tran', N'Ngoc Mai', N'0943234567', N'10', N'Nguyen Van Cu', N'Quan 1', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000007', N'nguoinhan7@email.com', N'Ho', N'Thi Thu', N'0944234567', N'90', N'Le Lai', N'Quan 3', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000008', N'nguoinhan8@email.com', N'Vo', N'Dinh Ky', N'0942345678', N'20', N'Tran Phu', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000009', N'nguoinhan9@email.com', N'Nguyen', N'Hoai Phong', N'0942345679', N'30', N'Le Duan', N'Thanh Khe', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000010', N'nguoinhan10@email.com', N'Do', N'Ngoc Quyen', N'0952345678', N'18', N'To Hieu', N'Le Chan', N'Hai Phong')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000011', N'nguoinhan11@email.com', N'Phan', N'Minh Triet', N'0952345679', N'10', N'Hoang Dieu', N'Ngo Quyen', N'Hai Phong')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000012', N'nguoinhan12@email.com', N'Ho', N'Van Kien', N'0962345678', N'25', N'Nguyen Trai', N'Ninh Kieu', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'200000000013', N'nguoinhan13@email.com', N'Le', N'Thanh Nga', N'0962345679', N'35', N'Ly Tu Trong', N'Cai Rang', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000001', N'nhanvien1@email.com', N'Pham', N'Van Hoa', N'0932345678', N'50', N'Hai Ba Trung', N'Cau Giay', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000002', N'nhanvien2@email.com', N'Dang', N'Van Phong', N'0932345679', N'70', N'Kim Ma', N'Dong Da', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000003', N'nhanvien3@email.com', N'Hoang', N'Thi Phuong', N'0932345681', N'60', N'Nguyen Khang', N'Cau Giay', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000004', N'nhanvien4@email.com', N'Pham', N'Quang Hung', N'0932345682', N'40', N'Banh Van Tran', N'Tan Binh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000005', N'nhanvien5@email.com', N'Nguyen', N'Quoc Anh', N'0945234567', N'45', N'Duong 3 Thang 2', N'Quan 10', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000006', N'nhanvien6@email.com', N'Le', N'Thu Hoai', N'0932345683', N'35', N'Le Duan', N'Thanh Xuan', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000007', N'nhanvien7@email.com', N'Tran', N'Thi Lan', N'0932345684', N'60', N'Xuan Thuy', N'Cau Giay', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000008', N'nhanvien8@email.com', N'Vu', N'Thi Lan', N'0932345685', N'45', N'Phan Chu Trinh', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000009', N'nhanvien9@email.com', N'Bui', N'Minh Thuan', N'0932345686', N'50', N'Le Loi', N'Son Tra', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000010', N'nhanvien10@email.com', N'Nguyen', N'Hoang Anh', N'0932345687', N'40', N'Tran Hung Dao', N'Ninh Kieu', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000011', N'nhanvien11@email.com', N'Pham', N'Thi Hoa', N'0932345688', N'65', N'Hoang Hoa Tham', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000012', N'nhanvien12@email.com', N'Tran', N'Minh Quan', N'0932345689', N'55', N'Nguyen Huu Canh', N'Quan 1', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000013', N'nhanvien13@email.com', N'Le', N'Thi Lan', N'0932345690', N'40', N'Nguyen Hue', N'Thua Thien Hue', N'Hue')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000014', N'nhanvien14@email.com', N'Nguyen', N'Thu Trang', N'0932345691', N'30', N'Vo Nguyen Giap', N'Son Tra', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000015', N'nhanvien15@email.com', N'Bui', N'Thi Lan', N'0932345692', N'60', N'Nguyen Trai', N'Hoan Kiem', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000016', N'nhanvien16@email.com', N'Le', N'Phuong Hoa', N'0932345693', N'50', N'Ly Thai To', N'Thanh Khe', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000017', N'nhanvien17@email.com', N'Nguyen', N'Thanh Son', N'0932345694', N'55', N'Hoang Dieu', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000018', N'nhanvien18@email.com', N'Pham', N'Tuan Anh', N'0932345695', N'30', N'Kim Ma', N'Ba Dinh', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000019', N'nhanvien19@email.com', N'Truong', N'Quang Anh', N'0932345696', N'50', N'Phan Dinh Phung', N'Ngo Quyen', N'Hai Phong')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000020', N'nhanvien20@email.com', N'Bui', N'Phuoc Minh', N'0932345697', N'45', N'Vo Thi Sau', N'Tan Binh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000021', N'nhanvien21@email.com', N'Nguyen', N'Tien Duy', N'0932345698', N'60', N'Ngo Gia Tu', N'Ninh Kieu', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000022', N'nhanvien22@email.com', N'Hoang', N'Tuan Anh', N'0932345699', N'50', N'Nguyen Tat Thanh', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000023', N'nhanvien23@email.com', N'Pham', N'Mai Hoa', N'0932345700', N'55', N'Tran Quang Khai', N'Ninh Kieu', N'Can Tho')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000024', N'nhanvien24@email.com', N'Truong', N'Tuan Anh', N'0932345701', N'60', N'Bach Dang', N'Hai Chau', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000025', N'nhanvien25@email.com', N'Bui', N'Thu Lan', N'0932345702', N'45', N'Nguyen Van Troi', N'Thanh Khe', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000026', N'nhanvien26@email.com', N'Nguyen', N'Mai Thi', N'0932345703', N'30', N'Le Thanh Ton', N'Quan 1', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000027', N'nhanvien27@email.com', N'Tran', N'Minh Hoa', N'0932345704', N'50', N'Phan Van Hon', N'Binh Chanh', N'Ho Chi Minh')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000028', N'nhanvien28@email.com', N'Le', N'Thanh Mai', N'0932345705', N'55', N'Tran Hung Dao', N'Hoan Kiem', N'Ha Noi')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000029', N'nhanvien29@email.com', N'Pham', N'Quang Kien', N'0932345706', N'60', N'Ngo Tat To', N'Thanh Khe', N'Da Nang')
INSERT [dbo].[Nguoi] ([CCCD], [Email], [Ho], [Ten], [SDT], [SoNha], [Duong], [Quan], [ThanhPho]) VALUES (N'300000000030', N'nhanvien30@email.com', N'Hoang', N'Phuoc Hoa', N'0932345707', N'50', N'Ly Nam De', N'Quan 5', N'Ho Chi Minh')
GO
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000001', N'DH01')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000002', N'DH02, DH17')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000003', N'DH05')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000004', N'DH06')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000005', NULL)
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000006', N'DH03, DH16, DH16, DH200')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000007', N'DH04')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000008', N'DH07')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000009', N'DH08')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000010', N'DH09')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000011', N'DH10')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000012', N'DH11')
INSERT [dbo].[NguoiNhan] ([CCCD], [LichSuDatHang]) VALUES (N'200000000013', N'DH12')
GO
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000001', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000002', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000003', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000004', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000005', N'Ho tro')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000006', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000007', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000008', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000009', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000010', N'Ho tro')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000011', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000012', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000013', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000014', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000015', N'Ho tro')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000016', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000017', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000018', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000019', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000020', N'Ho tro')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000021', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000022', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000023', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000024', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000025', N'Ho tro')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000026', N'Van hanh')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000027', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000028', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000029', N'Quan li')
INSERT [dbo].[NhanVien] ([CCCD], [ViTri]) VALUES (N'300000000030', N'Ho tro')
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP01', N'Dien Thoai iPhone 14', 99)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP02', N'May Tinh Laptop Dell Inspiron', 50)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP03', N'Ao Thun Nam', 200)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP04', N'Quan Jean Nu', 150)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP05', N'Ti Vi Samsung 55 Inch', 30)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP06', N'May Giat LG Inverter', 20)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP07', N'Ban Hoc Go', 50)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP08', N'Do Choi Tre Em', 150)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP09', N'May Loc Nuoc Karofi', 40)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP10', N'Tivi Sony 4K 65 Inch', 15)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP11', N'Ban An Go Cao Cap', 20)
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [SoLuong]) VALUES (N'SP12', N'Do Gia Dung Tien Dung', 100)
GO
INSERT [dbo].[SanPhamHoanTra] ([MaDonHang], [MaSanPham], [NgayHoanTra], [LyDoTra]) VALUES (N'DH01', N'SP01', CAST(N'2024-12-10' AS Date), N'San Pham Loi')
INSERT [dbo].[SanPhamHoanTra] ([MaDonHang], [MaSanPham], [NgayHoanTra], [LyDoTra]) VALUES (N'DH02', N'SP03', CAST(N'2024-12-12' AS Date), N'Khong Dung Y Mau Sac')
INSERT [dbo].[SanPhamHoanTra] ([MaDonHang], [MaSanPham], [NgayHoanTra], [LyDoTra]) VALUES (N'DH03', N'SP03', CAST(N'2024-12-09' AS Date), N'bla bla bla')
GO
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000001', N'XeMay', N'29A12345', N'11')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000002', N'XeTai', N'29B67890', N'Ba Dinh, Ha Noi')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000003', N'XeMay', N'KH123456', N'Phu Nhuan, Ho Chi Minh')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000004', N'XeMay', N'30A12346', N'Binh Thanh, Ho Chi Minh')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000005', N'XeMay', N'31A12347', N'Dong Da, Ha Noi')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000006', N'XeMay', N'59A67890', N'Quan 1, Ho Chi Minh')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000007', N'XeTai', N'50B12345', N'Quan 3, Ho Chi Minh')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000008', N'XeMay', N'59A15346', N'Hai Chau, Da Nang')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000009', N'XeMay', N'77A12497', N'Thanh Khe, Da Nang')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000010', N'XeMay', N'53A67390', N'Le Chan, Hai Phong')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000011', N'XeTai', N'50B19995', N'Ngo Quyen, Hai Phong')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000012', N'XeMay', N'34A67840', N'Ninh Kieu, Can Tho')
INSERT [dbo].[Shipper] ([CCCD], [LoaiXe], [BienSo], [KhuVucGiaoHang]) VALUES (N'100000000013', N'XeMay', N'51A67830', N'Cai Rang, Can Tho')
GO
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH01', N'CG01', N'100000000001')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH02', N'CG02', N'100000000002')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH03', N'CG03', N'100000000006')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH04', N'CG04', N'100000000007')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH06', N'CG02', N'100000000005')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH07', N'CG03', N'100000000008')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH08', N'CG04', N'100000000009')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH09', N'CG01', N'100000000010')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH10', N'CG02', N'100000000011')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH11', N'CG03', N'100000000012')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH12', N'CG04', N'100000000013')
INSERT [dbo].[ThucHienGiao] ([MaDonHang], [MaChuyen], [CCCD]) VALUES (N'DH13', N'CG03', N'100000000008')
GO
ALTER TABLE [dbo].[Kho] ADD  DEFAULT ((0)) FOR [SoLuongDonHang]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_CuaHang] FOREIGN KEY([CuaHangGui])
REFERENCES [dbo].[CuaHang] ([MaCuaHang])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_CuaHang]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_Kho] FOREIGN KEY([KhoChua])
REFERENCES [dbo].[Kho] ([MaKho])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_Kho]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_NguoiNhan] FOREIGN KEY([NguoiNhan])
REFERENCES [dbo].[NguoiNhan] ([CCCD])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_NguoiNhan]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_DonHang_NhanVien] FOREIGN KEY([NhanVienXuLy])
REFERENCES [dbo].[NhanVien] ([CCCD])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_DonHang_NhanVien]
GO
ALTER TABLE [dbo].[DonHang]  WITH CHECK ADD  CONSTRAINT [FK_NguoiNhan_ThanhToan] FOREIGN KEY([NguoiNhan])
REFERENCES [dbo].[NguoiNhan] ([CCCD])
GO
ALTER TABLE [dbo].[DonHang] CHECK CONSTRAINT [FK_NguoiNhan_ThanhToan]
GO
ALTER TABLE [dbo].[GiamSat]  WITH CHECK ADD  CONSTRAINT [FK_GiamSat_NhanVien] FOREIGN KEY([NguoiGiamSat])
REFERENCES [dbo].[NhanVien] ([CCCD])
GO
ALTER TABLE [dbo].[GiamSat] CHECK CONSTRAINT [FK_GiamSat_NhanVien]
GO
ALTER TABLE [dbo].[Gom]  WITH CHECK ADD  CONSTRAINT [FK_Gom_DonHang] FOREIGN KEY([MaDonHang])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[Gom] CHECK CONSTRAINT [FK_Gom_DonHang]
GO
ALTER TABLE [dbo].[Gom]  WITH CHECK ADD  CONSTRAINT [FK_Gom_SanPham] FOREIGN KEY([MaSanPham])
REFERENCES [dbo].[SanPham] ([MaSanPham])
GO
ALTER TABLE [dbo].[Gom] CHECK CONSTRAINT [FK_Gom_SanPham]
GO
ALTER TABLE [dbo].[Kho]  WITH CHECK ADD  CONSTRAINT [FK_Kho_NhanVien] FOREIGN KEY([NhanVienQuanLy])
REFERENCES [dbo].[NhanVien] ([CCCD])
GO
ALTER TABLE [dbo].[Kho] CHECK CONSTRAINT [FK_Kho_NhanVien]
GO
ALTER TABLE [dbo].[KyNangNhanVien]  WITH CHECK ADD  CONSTRAINT [FK_KyNangNhanVien_NhanVien] FOREIGN KEY([CCCD])
REFERENCES [dbo].[NhanVien] ([CCCD])
GO
ALTER TABLE [dbo].[KyNangNhanVien] CHECK CONSTRAINT [FK_KyNangNhanVien_NhanVien]
GO
ALTER TABLE [dbo].[NguoiNhan]  WITH CHECK ADD  CONSTRAINT [FK_NguoiNhan_Nguoi] FOREIGN KEY([CCCD])
REFERENCES [dbo].[Nguoi] ([CCCD])
GO
ALTER TABLE [dbo].[NguoiNhan] CHECK CONSTRAINT [FK_NguoiNhan_Nguoi]
GO
ALTER TABLE [dbo].[NhanVien]  WITH CHECK ADD  CONSTRAINT [FK_NhanVien_Nguoi] FOREIGN KEY([CCCD])
REFERENCES [dbo].[Nguoi] ([CCCD])
GO
ALTER TABLE [dbo].[NhanVien] CHECK CONSTRAINT [FK_NhanVien_Nguoi]
GO
ALTER TABLE [dbo].[SanPhamHoanTra]  WITH CHECK ADD  CONSTRAINT [FK_SanPhamHoanTra_DonHang] FOREIGN KEY([MaDonHang])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[SanPhamHoanTra] CHECK CONSTRAINT [FK_SanPhamHoanTra_DonHang]
GO
ALTER TABLE [dbo].[SanPhamHoanTra]  WITH CHECK ADD  CONSTRAINT [FK_SanPhamHoanTra_SanPham] FOREIGN KEY([MaSanPham])
REFERENCES [dbo].[SanPham] ([MaSanPham])
GO
ALTER TABLE [dbo].[SanPhamHoanTra] CHECK CONSTRAINT [FK_SanPhamHoanTra_SanPham]
GO
ALTER TABLE [dbo].[Shipper]  WITH CHECK ADD  CONSTRAINT [FK_Shipper_Nguoi] FOREIGN KEY([CCCD])
REFERENCES [dbo].[Nguoi] ([CCCD])
GO
ALTER TABLE [dbo].[Shipper] CHECK CONSTRAINT [FK_Shipper_Nguoi]
GO
ALTER TABLE [dbo].[ThucHienGiao]  WITH CHECK ADD  CONSTRAINT [FK_ThucHienGiao_Chuyen] FOREIGN KEY([MaChuyen])
REFERENCES [dbo].[ChuyenGiaoHang] ([MaChuyen])
GO
ALTER TABLE [dbo].[ThucHienGiao] CHECK CONSTRAINT [FK_ThucHienGiao_Chuyen]
GO
ALTER TABLE [dbo].[ThucHienGiao]  WITH CHECK ADD  CONSTRAINT [FK_ThucHienGiao_DonHang] FOREIGN KEY([MaDonHang])
REFERENCES [dbo].[DonHang] ([MaDonHang])
GO
ALTER TABLE [dbo].[ThucHienGiao] CHECK CONSTRAINT [FK_ThucHienGiao_DonHang]
GO
ALTER TABLE [dbo].[ThucHienGiao]  WITH CHECK ADD  CONSTRAINT [FK_ThucHienGiao_Nguoi] FOREIGN KEY([CCCD])
REFERENCES [dbo].[Nguoi] ([CCCD])
GO
ALTER TABLE [dbo].[ThucHienGiao] CHECK CONSTRAINT [FK_ThucHienGiao_Nguoi]
GO
/****** Object:  StoredProcedure [dbo].[DeleteDonHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[DeleteDonHang]
    @MaDonHang NVARCHAR(20)
AS
BEGIN
    -- Kiểm tra tồn tại đơn hàng
    IF NOT EXISTS (SELECT 1 FROM DonHang WHERE MaDonHang = @MaDonHang)
    BEGIN
        RAISERROR('Đơn hàng không tồn tại.', 16, 1);
        RETURN;
    END

    -- Xóa các sản phẩm có trong đơn hàng (bảng Gom)
    DELETE FROM Gom
    WHERE MaDonHang = @MaDonHang;

    -- Xóa các sản phẩm hoàn trả liên quan đến đơn hàng (bảng SanPhamHoanTra)
    DELETE FROM SanPhamHoanTra
    WHERE MaDonHang = @MaDonHang;

    -- Xóa các giao dịch thực hiện giao hàng liên quan đến đơn hàng (bảng ThucHienGiao)
    DELETE FROM ThucHienGiao
    WHERE MaDonHang = @MaDonHang;

    -- Xóa đơn hàng từ bảng DonHang
    DELETE FROM DonHang
    WHERE MaDonHang = @MaDonHang;
    
    PRINT 'Đơn hàng đã được xóa thành công.';
END;
GO
/****** Object:  StoredProcedure [dbo].[GetOrdersByStatusAndDate]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetOrdersByStatusAndDate]
    @TrangThai NVARCHAR(50)
AS
BEGIN
    SELECT 
        dh.MaDonHang,
        dh.NgayTao,
        dh.TongSoTien,
        dh.TrangThaiDonHang,
        ch.TenCuahang,
        STRING_AGG(COALESCE(sp.TenSanPham + ' (SL: ' + CAST(g.SoLuong AS NVARCHAR) + ')', 'Khong co san pham'), ', ') AS DanhSachSanPham
    FROM DonHang dh
    LEFT JOIN Cuahang ch ON dh.CuaHangGui = ch.MaCuaHang
    LEFT JOIN Gom g ON dh.MaDonHang = g.MaDonHang
    LEFT JOIN SanPham sp ON g.MaSanPham = sp.MaSanPham
    WHERE LOWER(dh.TrangThaiDonHang) = LOWER(@TrangThai) -- So sánh không phân biệt chữ hoa/thường
    GROUP BY dh.MaDonHang, dh.NgayTao, dh.TongSoTien, dh.TrangThaiDonHang, ch.TenCuahang
    ORDER BY dh.NgayTao DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetTotalProductsSoldByStore]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTotalProductsSoldByStore] 
@MinTotal INT 
AS 
BEGIN 
    SELECT 
        ch.TenCuaHang, 
        SUM(g.SoLuong) AS TongSoLuongBan 
    FROM Gom g 
    INNER JOIN DonHang dh ON g.MaDonHang = dh.MaDonHang 
    INNER JOIN CuaHang ch ON dh.CuaHangGui = ch.MaCuaHang 
    WHERE dh.TrangThaiDonHang = 'Da giao hang' 
    GROUP BY ch.TenCuaHang HAVING SUM(g.SoLuong) > @MinTotal 
    ORDER BY TongSoLuongBan DESC; 
    END; 
GO
/****** Object:  StoredProcedure [dbo].[InsertDonHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertDonHang]
    @MaDonHang NVARCHAR(20),
    @NgayTao DATE,
    @TongSoTien INT,
    @TrangThaiDonHang NVARCHAR(50),
    @NhanVienXuLy NVARCHAR(12),
    @KhoChua NVARCHAR(20),
    @NguoiNhan NVARCHAR(12),
    @CuaHangGui NVARCHAR(20),
    @NgayThanhToan DATE,
    @PhuongThucThanhToan NVARCHAR(50)
AS
BEGIN
	-- Kiểm tra Mã Đơn Hàng có bị trùng không
    IF EXISTS (SELECT 1 FROM DonHang WHERE MaDonHang = @MaDonHang)
    BEGIN
        RAISERROR('Mã đơn hàng đã tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Ngày Tạo không được sau ngày hiện tại
    IF @NgayTao > GETDATE()
    BEGIN
        RAISERROR('Ngày tạo phải là ngày hôm nay hoặc trước đó.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Tổng Số Tiền phải lớn hơn hoặc bằng 0
    IF @TongSoTien < 0
    BEGIN
        RAISERROR('Tổng số tiền phải là một số dương hoặc bằng 0.', 16, 1);
        RETURN;
    END

	-- Kiểm tra trạng thái đơn hàng phải thuộc danh sách giá trị hợp lệ
    IF @TrangThaiDonHang NOT IN ('Dang cho xu ly', 'Da giao hang', 'Da huy', 'Dang giao hang')
    BEGIN
        RAISERROR('Trạng thái đơn hàng phải thuộc "Dang cho xu ly", "Da giao hang", "Da huy", "Dang giao hang".', 16, 1);
        RETURN;
    END

	-- Kiểm tra tồn tại Nhân Viên xử lý
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE CCCD = @NhanVienXuLy)
    BEGIN
        RAISERROR('Nhân viên xử lý không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Kho
    IF NOT EXISTS (SELECT 1 FROM Kho WHERE MaKho = @KhoChua)
    BEGIN
        RAISERROR('Kho không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Người Nhận
    IF NOT EXISTS (SELECT 1 FROM NguoiNhan WHERE CCCD = @NguoiNhan)
    BEGIN
        RAISERROR('Người nhận không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Cửa Hàng
    IF NOT EXISTS (SELECT 1 FROM CuaHang WHERE MaCuaHang = @CuaHangGui)
    BEGIN
        RAISERROR('Cửa hàng không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Ngày Thanh Toán phải sau hoặc bằng Ngày Tạo
    IF @NgayThanhToan < @NgayTao
    BEGIN
        RAISERROR('Ngày thanh toán không thể trước ngày tạo.', 16, 1);
        RETURN;
    END

    -- Kiểm tra phương thức thanh toán phải thuộc danh sách giá trị hợp lệ
    IF @PhuongThucThanhToan NOT IN ('Tien mat', 'Chuyen khoan')
    BEGIN
        RAISERROR('Phương thức thanh toán phải thuộc "Tien mat", "Chuyen khoan" .', 16, 1);
        RETURN;
    END

    -- Thực hiện insert nếu tất cả kiểm tra hợp lệ
    INSERT INTO DonHang (MaDonHang, NgayTao, TongSoTien, TrangThaiDonHang, NhanVienXuLy, KhoChua, NguoiNhan, CuaHangGui, NgayThanhToan, PhuongThucThanhToan)
    VALUES (@MaDonHang, @NgayTao, @TongSoTien, @TrangThaiDonHang, @NhanVienXuLy, @KhoChua, @NguoiNhan, @CuaHangGui, @NgayThanhToan, @PhuongThucThanhToan);

    -- Thông báo thành công
    PRINT 'Thêm đơn hàng thành công.';
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateDonHang]    Script Date: 4/7/2025 5:09:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UpdateDonHang]
    @MaDonHang NVARCHAR(20),
    @NgayTao DATE,
    @TongSoTien INT,
    @TrangThaiDonHang NVARCHAR(50),
    @NhanVienXuLy NVARCHAR(12),
    @KhoChua NVARCHAR(20),
    @NguoiNhan NVARCHAR(12),
    @CuaHangGui NVARCHAR(20),
    @NgayThanhToan DATE,
    @PhuongThucThanhToan NVARCHAR(50)
AS
BEGIN
    -- Kiểm tra Mã Đơn Hàng có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM DonHang WHERE MaDonHang = @MaDonHang)
    BEGIN
        RAISERROR('Mã đơn hàng không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Ngày Tạo không được sau ngày hiện tại
    IF @NgayTao > GETDATE()
    BEGIN
        RAISERROR('Ngày tạo phải là ngày hôm nay hoặc trước đó.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Tổng Số Tiền phải lớn hơn hoặc bằng 0
    IF @TongSoTien < 0
    BEGIN
        RAISERROR('Tổng số tiền phải là một số dương hoặc bằng 0.', 16, 1);
        RETURN;
    END

    -- Kiểm tra trạng thái đơn hàng phải thuộc danh sách giá trị hợp lệ
    IF @TrangThaiDonHang NOT IN ('Dang cho xu ly', 'Da giao hang', 'Da huy', 'Dang giao hang')
    BEGIN
        RAISERROR('Trạng thái đơn hàng phải thuộc "Dang cho xu ly", "Da giao hang", "Da huy", "Dang giao hang".', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Nhân Viên xử lý
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE CCCD = @NhanVienXuLy)
    BEGIN
        RAISERROR('Nhân viên xử lý không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Kho
    IF NOT EXISTS (SELECT 1 FROM Kho WHERE MaKho = @KhoChua)
    BEGIN
        RAISERROR('Kho không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Người Nhận
    IF NOT EXISTS (SELECT 1 FROM NguoiNhan WHERE CCCD = @NguoiNhan)
    BEGIN
        RAISERROR('Người nhận không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra tồn tại Cửa Hàng
    IF NOT EXISTS (SELECT 1 FROM CuaHang WHERE MaCuaHang = @CuaHangGui)
    BEGIN
        RAISERROR('Cửa hàng không tồn tại.', 16, 1);
        RETURN;
    END

    -- Kiểm tra Ngày Thanh Toán phải sau hoặc bằng Ngày Tạo
    IF @NgayThanhToan < @NgayTao
    BEGIN
        RAISERROR('Ngày thanh toán không thể trước ngày tạo.', 16, 1);
        RETURN;
    END

    -- Kiểm tra phương thức thanh toán phải thuộc danh sách giá trị hợp lệ
    IF @PhuongThucThanhToan NOT IN ('Tien mat', 'Chuyen khoan')
    BEGIN
        RAISERROR('Phương thức thanh toán phải thuộc "Tien mat", "Chuyen khoan".', 16, 1);
        RETURN;
    END

    -- Kiểm tra trạng thái hiện tại và trạng thái mới
    DECLARE @TrangThaiHienTai NVARCHAR(50);
    SELECT @TrangThaiHienTai = TrangThaiDonHang FROM DonHang WHERE MaDonHang = @MaDonHang;

    -- Nếu trạng thái không thay đổi, chỉ cập nhật các trường khác
    IF @TrangThaiHienTai = @TrangThaiDonHang
    BEGIN
        -- Tạm thời vô hiệu hóa trigger trước khi cập nhật
        DISABLE TRIGGER KiemSoatTrangThaiDonHang ON DonHang;

        -- Cập nhật tất cả các trường khác (trừ trạng thái)
        UPDATE DonHang
        SET 
            NgayTao = @NgayTao,
            TongSoTien = @TongSoTien,
            NhanVienXuLy = @NhanVienXuLy,
            KhoChua = @KhoChua,
            NguoiNhan = @NguoiNhan,
            CuaHangGui = @CuaHangGui,
            NgayThanhToan = @NgayThanhToan,
            PhuongThucThanhToan = @PhuongThucThanhToan
        WHERE MaDonHang = @MaDonHang;

        -- Bật lại trigger sau khi cập nhật
        ENABLE TRIGGER KiemSoatTrangThaiDonHang ON DonHang;

        RETURN;
    END

    -- Nếu trạng thái thay đổi, thực hiện update và trigger sẽ hoạt động
    UPDATE DonHang
    SET 
        NgayTao = @NgayTao,
        TongSoTien = @TongSoTien,
        TrangThaiDonHang = @TrangThaiDonHang,
        NhanVienXuLy = @NhanVienXuLy,
        KhoChua = @KhoChua,
        NguoiNhan = @NguoiNhan,
        CuaHangGui = @CuaHangGui,
        NgayThanhToan = @NgayThanhToan,
        PhuongThucThanhToan = @PhuongThucThanhToan
    WHERE MaDonHang = @MaDonHang;
END;
GO
USE [master]
GO
ALTER DATABASE [database2] SET  READ_WRITE 
GO
