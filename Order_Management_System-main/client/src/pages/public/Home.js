import React from 'react'
import { Banner} from '../../components/index'
import { SearchOrder } from '../../components';
// import { useSelector, useDispatch } from 'react-redux'
// import {getProduct} from '../../store/product/asyncActions'
// import {apiGetProduct, apiGetPhone } from '../../apis'
const Home = () => {
    return (
        <>
       <div className="w-full flex flex-col ">
  <Banner />
</div>
<div className="w-full flex flex-col mt-0">
  <SearchOrder />
</div>
       </>
      );
  }
  export default Home