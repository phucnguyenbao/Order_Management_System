import React  from 'react'
import { Link } from 'react-router-dom';
import path from '../utils/path';
import { RiPhoneFill } from "react-icons/ri";
import { CgMail } from "react-icons/cg";

const Header = () => {
  

  return (
    <div className="bg-orange-400 w-full">
      <div className=" w-main h-[110px] py-[35px]  mx-auto flex items-center justify-start">
 
        {/* logo */}
        <Link to={path.HOME}>
        <img src="logogiao.png" alt="logo" className="h-[80px] w-auto cursor-pointer" />
      </Link>
         <div className = "flex text-[13px] ml-auto space-x-8">
          <div className = 'flex flex-col items-center'>
          <span className = 'flex gap-3 items-center'>
          <RiPhoneFill color = 'red' />
          <span className = 'font-semibold'>(+1800) 000 6606</span>
          </span>
          <span> Mon-Sat 9:00AM - 8:00PM </span>
          </div>
          <div className = 'flex flex-col items-center'>
          <span className = 'flex gap-3 items-center'>
          <CgMail color = 'red' />
          <span className = 'font-semibold'>ABCSUPPORT@GMAIL.COM</span>
          </span>
          <span> Online Support 24/7 </span>
          </div>
          </div> 
      </div>
    </div>
  );
};

export default Header
