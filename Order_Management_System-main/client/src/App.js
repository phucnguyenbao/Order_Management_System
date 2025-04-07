import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';  // Import BrowserRouter
import { ToastContainer } from 'react-toastify';
import { Public, Home, Chitietnhanvien, Chitietcuahang } from './pages/public/index';
import { MemberLayout, CheckOrder, AddOrder} from './pages/member';
import path from './utils/path';
import Chitiet from './pages/public/Chitietnhanvien';

function App() {
  return (
    <Router> {/* Bao quanh Routes bằng Router */}
      <div className="font-main relative">
        <Routes>
          <Route path={path.PUBLIC} element={<Public />}>
            <Route path={path.HOME} element={<Home />} />
            <Route path = {path.CHITIETNHANVIEN} element={<Chitietnhanvien />} />
            <Route path = {path.CHITIETCUAHANG} element={<Chitietcuahang />} />
          </Route>
          
        <Route path={path.MEMBER} element={<MemberLayout />}>
          <Route path={path.CHECK_ORDER} element={<CheckOrder />}/>
          <Route path={path.Add_ORDER} element={<AddOrder />}/>
        </Route>

        </Routes>
        <ToastContainer
          position="top-right"
          autoClose={5000}
          hideProgressBar={true}
          newestOnTop={false}
          closeOnClick
          rtl={false}
          pauseOnFocusLoss
          draggable
          pauseOnHover
        />
        {/* Same as */}
        <ToastContainer />
      </div>
    </Router> 
  );
}

export default App;
