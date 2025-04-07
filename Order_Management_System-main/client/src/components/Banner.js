import React, { useRef } from 'react';
import Slider from "react-slick";

const Banner = () => {
    const sliderRef = useRef(null); 
  
    const settings = {
      dots: true,         
      infinite: true,     
      speed: 600,         
      slidesToShow: 1,    
      slidesToScroll: 1,  
      autoplay: true,         // Tự động chuyển đổi
      autoplaySpeed: 2000,    // Tốc độ tự động chuyển đổi (ms)
    };

    const goToSlide = (index) => {
        if (sliderRef.current) {
          sliderRef.current.slickGoTo(index); // Gọi slickGoTo khi sliderRef không null
        }
      };

      return (
        <div className="w-full  relative">
          <Slider ref={sliderRef} {...settings}>
            {/* Slide 1 */}
            <div>
              <img  
                src="banner1.jpg"
                alt="banner 1"
                className="w-full h-[420px] object-cover"
              />
            </div>
            {/* Slide 2 */}
            <div>
              <img  
                src="banner2.jpg"
                alt="banner 2"
                className="w-full h-[420px] object-cover"
              />
            </div>
            {/* Slide 3 */}
            <div>
              <img  
                src="banner3.jpg"
                alt="banner 3"
                className="w-full h-[420px] object-cover"
              />
            </div>
          </Slider>
          <style jsx>{`
          .slick-list {
                    height: 420px; /* Đặt chiều cao cố định cho slick-list */
                    overflow: hidden; /* Ẩn phần thừa nếu có */
                }
          .slick-dots {
            position: absolute;
            bottom: 20px; /* Điều chỉnh vị trí chấm */
            left: 50%;
            transform: translateX(-50%);
            z-index: 10;
          }
          .slick-dots li button:before {
            font-size: 16px; /* Điều chỉnh kích thước chấm */
            color: white; /* Màu sắc chấm */
          }
        `}</style>
        </div>
      );
      
    
  
}

export default Banner;