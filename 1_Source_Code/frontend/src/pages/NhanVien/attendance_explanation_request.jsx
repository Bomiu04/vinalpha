import React, { useState, useEffect } from 'react';
import axiosClient from "../../api/axiosClient";
import { HiMiniXCircle } from "react-icons/hi2";
import { MdChatBubbleOutline } from "react-icons/md";
import { IoCloudUploadOutline } from "react-icons/io5";
import { BsSend } from "react-icons/bs";
import { PiClockCounterClockwise } from "react-icons/pi";
import { FaUser, FaRegFileAlt, FaRegClock } from "react-icons/fa";
import { employeeService } from "../../services/employeeService";
import { IoArrowBack } from "react-icons/io5";
import { GoCheckCircle } from "react-icons/go";
import { MdCalendarMonth } from "react-icons/md";
import { CiSearch } from "react-icons/ci";
import { LuClock2 } from "react-icons/lu";
import { GoBlocked } from "react-icons/go";
import './ae_request.css'
const attendance_explanation_request = () => {
    return(
        <div className="request-container">
            <div className="request-left">
                <div className="request-left-header">
                    <div className="header-left">
                         <h2 style={{color:"#ef4444"}} >Tạo đơn xin giải trình</h2>
                        <p>Tạo và báo cáo giải trình của bạn.</p>
                    </div>
                    <div className="header-right">
                        <button className="btn-cannel" onClick={() => setShowConfirmCancel(true)}>
                            <HiMiniXCircle  /> Hủy
                        </button>
                    </div>
                </div>
                <div className="request-left-content">
                    <div className="info-section">
                        
                        <h3 className="section-title">
                            <FaRegFileAlt className="icon" style={{ color: "red" }}/> Thông tin chung
                        </h3>
                        
                        <div className="input-grid">
                            <div className="input-group">
                                <label>Ngày cần giải trình</label>
                                <input
                                    type="date"
                                    className="input-option"

                                />
                            </div>
                            <div className="input-group">
                                <label>Loại giải trình</label>
                                <select
                                    className="input-option"
                                
                                >
                                    <option value="">-- Chọn loại giải trình --</option>
                                    <option value="FORGOT_CHECKIN">Quên chấm công vào</option>
                                    <option value="FORGOT_CHECKOUT">Quên chấm công ra</option>
                                    <option value="SYSTEM_ERROR">Lỗi hệ thống</option>
                                    <option value="LATE">Đi muộn</option>
                                    <option value="EARLY_LEAVE">Về sớm</option>
                                </select>
                            </div>
                            
                        </div>
                        <div className="info-section-bottom-ae-request">
                            <div className="info-section-bottom-ae-request-left">
                                <p>Người kiểm duyệt:</p>
                            </div>
                            <div className="info-section-bottom-ae-request-right">
                                <select
                                    className="input-option"
                                    
                                >
                                    <option value="">-- Người kiểm duyệt --</option>
                                    <option value="FORGOT_CHECKIN">Lỉnh</option>
                                    <option value="FORGOT_CHECKOUT">Lỉnh</option>
                                    <option value="SYSTEM_ERROR">Lỉnh đẹp trai</option>
                                    <option value="LATE">Lỉnh Trần</option>
                                    
                                </select>
                            </div>
                        </div>
                    </div>
                    <div className="info-section">
                        <h3 className="section-title">
                            <FaRegClock className="icon" style={{ color: "red" }}/> Thời gian thực tế
                        </h3>
                        <div className="input-grid">
                            <div className="input-group">
                                <label>Thời gian vào</label>
                                <input
                                    type="time"
                                    className="input-option"

                                />
                            </div>
                            <div className="input-group">
                                <label>Thời gian ra</label>
                                <input
                                    type="time"
                                    className="input-option"

                                />
                            </div>
                        </div>
                        
                        
                    </div>
                    <div className="info-section">
                        <h3 className="section-title">
                            <MdChatBubbleOutline className="icon" style={{ color: "red" }}/> Giải trình
                        </h3>
                        <div className="input-grid-1">
                            <div className="input-group" style={{ marginTop: "10px" }}>
                            <label>Lý do cụ thể</label>
                            <textarea
                                className="input-option-1"
                                
                                placeholder="Giải trình lý do cụ thể..."

                            />
                            </div>
                            <div className="input-group" style={{ marginTop: "20px" }}>
                                          <label>Đính kèm tài liệu</label>
                                          <label htmlFor="file-upload" className="file-uploader">
                                            <IoCloudUploadOutline className="file-icon" style={{color:"red"}} />
                                            <div className="file-text">
                                              <span className="file-bold" style={{color:"red"}}>Nhấn để chọn file</span>
                                            </div>
                                            <div className="file-note">
                                              PNG, JPG, PDF, Word (Max 10MB)
                                            </div>
                                            <input  id="file-upload" type="file" hidden />
                                          </label>
                            </div>
                        </div>
                    </div>
                    
                </div>

                <div className="acction-footer">
                    <button className="btn-request" style={{background:"red"}} >
                        <BsSend /> Gửi
                    </button>
                </div>
            </div>
            <div className="request-right">

                <div className="card-request-top" style={{background:"linear-gradient(135deg, #ef4444 40%, #f97316 100%)"}}></div>

                <div className="card-request-bot" style={{minHeight:"765px"}}>
                    <div className="card-header-bot">
                            <h3 className="card-header-bot-2">
                            <PiClockCounterClockwise
                                style={{ fontSize: "17px", color: "red" }}
                            />
                                Đơn gần đây
                            </h3>
                            <button className="btn-all" style={{color:"red"}} >Xem tất cả</button>
                    </div>
                </div>
            </div>
        </div>



    );
};

export default attendance_explanation_request;