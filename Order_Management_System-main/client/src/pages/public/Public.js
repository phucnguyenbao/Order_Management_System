import React from 'react'
import { Outlet } from 'react-router-dom'
import {  Header, Navigation } from '../../components/index'

const Public = () => {
  return (
    <div className='w-full flex flex-col items-center'>
      <Header />
      <Navigation />
      <div className='w-full'>
        <Outlet />
      </div>
  {/*    <Footer /> */}
    </div>
  )
}

export default Public