import React from 'react'
import { Link } from "react-router-dom";
import { FaSearch, FaShoppingCart , FaFileAlt  } from "react-icons/fa";

function SearchOrder() {
    console.log("call Search"); 
    
    return (
        <div className="bg-gradient-to-r from-orange-500 via-red-500 to-orange-600 w-full h-[900px]">
            <div className = " flex flex-col items-center justify-between">
            {/* Thanh tìm kiếm */}
            <div className="h-[100px] py-2 flex items-center justify-center w-full px-4 mb-6 pt-20">
                <div className="flex items-center space-x-2 w-full max-w-xl">
                    <input
                        type="text"
                        placeholder="Nhập mã đơn hàng để tra cứu"
                        className="w-full px-4 py-3 rounded-full text-black"
                    />
                    <button className="bg-white p-3 rounded-full">
                        <FaSearch className="text-gray-600" />
                    </button>
                </div>
            </div>

            {/* Nút tạo đơn hàng, đơn hàng của bạn và giỏ hàng */}
            <div className="flex items-center justify-center space-x-6 w-full  max-w-lg mb-6 mt-5">
                {/* Nút tạo đơn hàng */}
                <Link 
            to="/member/add-order" 
                className="bg-white px-8 py-3 rounded-full text-black text-xl flex items-center space-x-2">
                    <FaShoppingCart className="text-black text-xl" />
                    <span>Tạo đơn hàng</span>
                </Link>
                {/* Nút "Đơn hàng của bạn" */}
                <Link 
            to="/member/check-order" 
            className="bg-white flex items-center space-x-2 px-8 py-3 rounded-full text-black text-xl" >
            <FaFileAlt className="text-black text-xl" />
            <span>Đơn hàng của bạn</span>
        </Link>
            </div>
            </div>
        </div>
    );
}

export default SearchOrder