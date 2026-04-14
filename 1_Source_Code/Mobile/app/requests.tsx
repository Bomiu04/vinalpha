import React, { useState, useEffect, useCallback } from 'react';
import { 
  View, Text, StyleSheet, TouchableOpacity, ScrollView, TextInput, 
  ActivityIndicator, RefreshControl, Dimensions, Alert 
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import * as DocumentPicker from 'expo-document-picker';
import { API_URL } from '@/config/env';
import { SwipeableSheet } from '@/components/SwipeableSheet';

const { width } = Dimensions.get('window');

interface RequestItem {
  id: string | number;
  type: string;
  type_label: string;
  start_datetime: string;
  end_datetime?: string;
  reason: string;
  status: 'pending' | 'approved' | 'rejected';
  created_at?: string;
}

export default function RequestsScreen() {
  const [view, setView] = useState<'list' | 'form'>('list');
  const [requestType, setRequestType] = useState('annual'); 
  // 'annual' | 'sick' | 'unpaid' | 'maternity' | 'bereavement' | 'attendance_error' | 'late_excuse' | 'overtime'
  
  const [requests, setRequests] = useState<RequestItem[]>([]);
  const [approvers, setApprovers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [leaveUsed, setLeaveUsed] = useState(0);
  const [otHours, setOtHours] = useState(0);
  const [otCount, setOtCount] = useState(0);
  
  // Form State
  const [approverId, setApproverId] = useState('');
  const [startDate, setStartDate] = useState(new Date().toISOString().split('T')[0]);
  const [endDate, setEndDate] = useState(new Date().toISOString().split('T')[0]);
  const [reason, setReason] = useState('');
  const [attachment, setAttachment] = useState<any>(null);
  
  // Sheet state
  const [showTypeSheet, setShowTypeSheet] = useState(false);
  const [showApproverSheet, setShowApproverSheet] = useState(false);

  const fetchRequests = useCallback(async () => {
    try {
      if (isRefreshing) return;
      const empId = await AsyncStorage.getItem('employeeId');
      if (!empId) return;

      // Lấy đơn xin nghỉ/giải trình
      const resLeave = await axios.get(`${API_URL}/employee/leave-request/${empId}`);
      // Lấy đơn OT
      const resOt = await axios.get(`${API_URL}/employee/overtime-request/${empId}`);

      const leaveData = (resLeave.data || []).map((r: any) => ({
        ...r,
        type: r.leave_type,
        type_label: getLeaveTypeText(r.leave_type)
      }));

      const otData = (resOt.data || []).map((r: any) => ({
        ...r,
        type: 'overtime',
        type_label: 'Đăng ký tăng ca / OT',
        start_datetime: r.date + 'T' + r.start_time,
        end_datetime: r.date + 'T' + r.end_time,
      }));

      const combined = [...leaveData, ...otData].sort((a, b) => {
        return new Date(b.created_at || b.start_datetime).getTime() - new Date(a.created_at || a.start_datetime).getTime();
      });

      // Calculate logic for Annual Leave
      let lUsed = 0;
      leaveData.forEach((r: any) => {
        if (r.leave_type === 'annual' && r.status === 'approved') {
           let start = new Date(r.start_datetime);
           let end = new Date(r.end_datetime);
           if (!isNaN(start.getTime()) && !isNaN(end.getTime())) {
              let curr = new Date(start);
              curr.setHours(0,0,0,0);
              let e = new Date(end);
              e.setHours(0,0,0,0);
              while (curr <= e) {
                 const day = curr.getDay();
                 if (curr.getFullYear() === new Date().getFullYear() && day !== 0 && day !== 6) {
                    lUsed++;
                 }
                 curr.setDate(curr.getDate() + 1);
              }
           }
        }
      });
      setLeaveUsed(lUsed);

      // Calculate logic for Overtime
      let otH = 0; let otC = 0;
      const curMonth = new Date().getMonth();
      const curYear = new Date().getFullYear();
      otData.forEach((r: any) => {
        if (r.status === 'approved') {
          let d = new Date(r.date || r.start_datetime);
          if (d.getMonth() === curMonth && d.getFullYear() === curYear) {
            otC++;
            if (r.start_time && r.end_time) {
               let st = r.start_time.split(':');
               let et = r.end_time.split(':');
               let dh = parseInt(et[0]) - parseInt(st[0]);
               let dm = parseInt(et[1]) - parseInt(st[1]);
               let h = dh + dm/60;
               if (h > 0) otH += h;
            }
          }
        }
      });
      setOtHours(otH);
      setOtCount(otC);

      setRequests(combined);
    } catch (error) {
      console.log('Error fetching requests', error);
    }
  }, [isRefreshing]);

  const fetchApprovers = useCallback(async () => {
    try {
      const empId = await AsyncStorage.getItem('employeeId');
      if (!empId) return;
      const res = await axios.get(`${API_URL}/employee/approvers/${empId}`);
      setApprovers(res.data?.data || res.data || []);
    } catch {}
  }, []);

  useEffect(() => {
    fetchRequests();
    fetchApprovers();
  }, [fetchRequests, fetchApprovers]);

  const onRefresh = async () => {
    setIsRefreshing(true);
    await fetchRequests();
    setIsRefreshing(false);
  };

  const getLeaveTypeText = (type: string) => {
    const types: any = {
      annual: "Nghỉ phép năm",
      sick: "Nghỉ ốm",
      unpaid: "Nghỉ không lương",
      maternity: "Nghỉ thai sản",
      bereavement: "Nghỉ tang",
      attendance_error: "Báo lỗi chấm công",
      late_excuse: "Giải trình đi muộn",
      overtime: "Tăng ca (OT)"
    };
    return types[type] || type;
  };

  const getStatusStyle = (status: string) => {
    if (status === 'approved') return { bg: '#d1fae5', text: '#059669', label: 'Đã duyệt' };
    if (status === 'rejected') return { bg: '#ffe4e6', text: '#e11d48', label: 'Từ chối' };
    return { bg: '#fef3c7', text: '#d97706', label: 'Chờ duyệt' };
  };

  const handleSubmit = async () => {
    if (!approverId) return Alert.alert('Lỗi', 'Vui lòng chọn người kiểm duyệt!');
    if (!reason.trim()) return Alert.alert('Lỗi', 'Vui lòng nhập lý do!');
    if (!startDate) return Alert.alert('Lỗi', 'Vui lòng chọn ngày!');

    setIsLoading(true);
    try {
      const empId = await AsyncStorage.getItem('employeeId');
      const formData = new FormData();
      formData.append('userId', empId as string);
      formData.append('approverId', approverId);
      formData.append('reason', reason);

      if (requestType === 'overtime') {
        const payload = {
          userId: empId,
          approverId,
          reason,
          date: startDate,
          start_time: '18:00', // Đơn giản hoá nhập liệu trên mobile
          end_time: '20:00'
        };
        await axios.post(`${API_URL}/employee/overtime-request`, payload);
      } else {
        formData.append('leave_type', requestType);
        formData.append('start_datetime', `${startDate} 00:00:00`);
        formData.append('end_datetime', `${endDate} 23:59:59`);
        if (attachment) {
          formData.append('attachment', {
            uri: attachment.uri,
            name: attachment.name || `file_${Date.now()}`,
            type: attachment.mimeType || 'application/octet-stream'
          } as any);
        }
        
        await axios.post(`${API_URL}/employee/leave-request`, formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
      }

      Alert.alert('Thành công', 'Đơn từ đã được gửi!');
      setReason('');
      setAttachment(null);
      setView('list');
      fetchRequests();
    } catch (error: any) {
      Alert.alert('Lỗi', error?.response?.data?.message || 'Không thể tạo đơn!');
    } finally {
      setIsLoading(false);
    }
  };

  const handleOpenForm = (type: string) => {
    setRequestType(type);
    setView('form');
  };

  const pickDocument = async () => {
    try {
      const res = await DocumentPicker.getDocumentAsync({
        type: '*/*',
        copyToCacheDirectory: true,
      });
      if (!res.canceled && res.assets && res.assets.length > 0) {
        setAttachment(res.assets[0]);
      }
    } catch (err) {
      console.log('Error picking file', err);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* HEADER */}
      <View style={styles.header}>
        {view === 'form' ? (
          <TouchableOpacity onPress={() => setView('list')} style={styles.backBtn}>
            <Feather name="chevron-left" size={24} color="#64748b" />
          </TouchableOpacity>
        ) : (
          <View style={styles.iconWrap}>
            <Feather name="file-text" size={22} color="#00b4d8" />
          </View>
        )}
        <Text style={styles.headerTitle}>{view === 'list' ? 'Đơn từ & Giải trình' : 'Tạo yêu cầu mới'}</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView 
        contentContainerStyle={[styles.content, view === 'form' && { paddingBottom: 100 }]}
        refreshControl={<RefreshControl refreshing={isRefreshing} onRefresh={onRefresh} />}
      >
        {view === 'list' && (
          <View style={styles.listContainer}>
            <View style={styles.quickActions}>
              <TouchableOpacity onPress={() => handleOpenForm('annual')} style={styles.actionBtn}>
                <View style={[styles.actionIcon, { backgroundColor: '#ecfdf5' }]}>
                  <Feather name="calendar" size={24} color="#10b981" />
                </View>
                <Text style={styles.actionText}>Nghỉ Phép</Text>
              </TouchableOpacity>

              <TouchableOpacity onPress={() => handleOpenForm('overtime')} style={styles.actionBtn}>
                <View style={[styles.actionIcon, { backgroundColor: '#eff6ff' }]}>
                  <Feather name="briefcase" size={24} color="#3b82f6" />
                </View>
                <Text style={styles.actionText}>Tăng Ca</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.quickActions}>
              <TouchableOpacity onPress={() => handleOpenForm('attendance_error')} style={[styles.actionBtn, styles.actionBtnLarge]}>
                <View style={[styles.actionIcon, { backgroundColor: '#fff1f2' }]}>
                  <Feather name="alert-triangle" size={24} color="#f43f5e" />
                </View>
                <Text style={styles.actionText}>Lỗi Chấm Công</Text>
              </TouchableOpacity>

              <TouchableOpacity onPress={() => handleOpenForm('late_excuse')} style={[styles.actionBtn, styles.actionBtnLarge]}>
                <View style={[styles.actionIcon, { backgroundColor: '#fffbeb' }]}>
                  <Feather name="clock" size={24} color="#f59e0b" />
                </View>
                <Text style={styles.actionText}>Khai Báo Đi Muộn</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.listHeader}>
              <Feather name="clock" size={16} color="#94a3b8" />
              <Text style={styles.listTitle}>LỊCH SỬ YÊU CẦU</Text>
            </View>

            {requests.map((req, idx) => {
              const statusStyle = getStatusStyle(req.status);
              return (
                <View key={idx} style={styles.requestCard}>
                  <View style={styles.reqTop}>
                    <Text style={styles.reqType}>{req.type_label}</Text>
                    <View style={[styles.statusBadge, { backgroundColor: statusStyle.bg }]}>
                      <Text style={[styles.statusText, { color: statusStyle.text }]}>{statusStyle.label}</Text>
                    </View>
                  </View>
                  <Text style={styles.reqDate}>
                    {new Date(req.start_datetime).toLocaleDateString('vi-VN')} {req.end_datetime && `- ${new Date(req.end_datetime).toLocaleDateString('vi-VN')}`}
                  </Text>
                  <Text style={styles.reqReason} numberOfLines={2}>&quot;{req.reason}&quot;</Text>
                </View>
              );
            })}
            
            {requests.length === 0 && (
              <Text style={styles.emptyText}>Bạn chưa tạo đơn nào.</Text>
            )}
          </View>
        )}

        {view === 'form' && (
          <View style={styles.formContainer}>
            {requestType === 'annual' && (
              <View style={[styles.summaryCard, { backgroundColor: '#10b981', alignSelf: 'center', marginBottom: 25 }]}>
                <View style={styles.cardTitleWrap}>
                  <Feather name="clock" size={16} color="#fff" />
                  <Text style={styles.cardTitle}> Quỹ phép năm {new Date().getFullYear()}</Text>
                </View>
                <View style={styles.cardValWrap}>
                  <Text style={styles.cardValLarge}>{(12 - leaveUsed).toFixed(1)}</Text>
                  <Text style={styles.cardValSmall}> / 12 ngày</Text>
                </View>
                <Text style={styles.cardSubtitle}>Số phép còn lại có thể sử dụng</Text>
                <View style={styles.cardFooter}>
                  <Text style={styles.cardFooterText}>Đã dùng: {leaveUsed.toFixed(1)} ngày</Text>
                  <Text style={styles.cardFooterText}>{Math.round((leaveUsed/12)*100)}%</Text>
                </View>
                <View style={styles.cardProgressBg}>
                  <View style={[styles.cardProgressFill, { width: `${Math.min((leaveUsed/12)*100, 100)}%` }]} />
                </View>
                <Feather name="umbrella" size={100} color="rgba(255,255,255,0.15)" style={styles.cardBgIcon} />
              </View>
            )}

            {requestType === 'overtime' && (
              <View style={[styles.summaryCard, { backgroundColor: '#0ea5e9', alignSelf: 'center', marginBottom: 25 }]}>
                <View style={styles.cardTitleWrap}>
                  <Feather name="calendar" size={16} color="#fff" />
                  <Text style={styles.cardTitle}> Tăng ca tháng {(new Date().getMonth() + 1).toString().padStart(2, '0')}/{new Date().getFullYear()}</Text>
                </View>
                <View style={styles.cardValWrap}>
                  <Text style={styles.cardValLarge}>{otHours.toFixed(1)}</Text>
                  <Text style={styles.cardValSmall}> giờ</Text>
                </View>
                <Text style={styles.cardSubtitle}>Tổng giờ tăng ca của bạn trong tháng này</Text>
                <View style={styles.cardFooter}>
                  <Text style={styles.cardFooterText}>Số đơn được duyệt: {otCount}</Text>
                </View>
                <View style={styles.cardProgressBg}>
                  <View style={[styles.cardProgressFill, { width: '100%', backgroundColor: 'rgba(255,255,255,0.4)' }]} />
                </View>
                <Feather name="briefcase" size={100} color="rgba(255,255,255,0.15)" style={styles.cardBgIcon} />
              </View>
            )}

            <TouchableOpacity onPress={() => setShowTypeSheet(true)} style={styles.inputGroup}>
              <Text style={styles.label}>LOẠI ĐƠN</Text>
              <View style={styles.pickerBox}>
                <Text style={styles.pickerText}>{getLeaveTypeText(requestType)}</Text>
                <Feather name="chevron-down" size={20} color="#64748b" />
              </View>
            </TouchableOpacity>

            <TouchableOpacity onPress={() => setShowApproverSheet(true)} style={styles.inputGroup}>
              <Text style={styles.label}>NGƯỜI KIỂM DUYỆT</Text>
              <View style={styles.pickerBox}>
                <Text style={[styles.pickerText, !approverId && { color: '#94a3b8' }]}>
                  {approvers.find(a => a.id === approverId)?.full_name || 'Chọn người duyệt...'}
                </Text>
                <Feather name="chevron-down" size={20} color="#64748b" />
              </View>
            </TouchableOpacity>

            <View style={styles.inputSplit}>
              <View style={[styles.inputGroup, { flex: 1 }]}>
                <Text style={styles.label}>TỪ NGÀY</Text>
                <TextInput 
                  style={styles.pickerBox} 
                  value={startDate} 
                  onChangeText={setStartDate} 
                  placeholder="YYYY-MM-DD"
                  placeholderTextColor="#94a3b8"
                />
              </View>
              {requestType !== 'attendance_error' && requestType !== 'late_excuse' && requestType !== 'overtime' && (
                <View style={[styles.inputGroup, { flex: 1, marginLeft: 15 }]}>
                  <Text style={styles.label}>ĐẾN NGÀY</Text>
                  <TextInput 
                    style={styles.pickerBox} 
                    value={endDate} 
                    onChangeText={setEndDate} 
                    placeholder="YYYY-MM-DD"
                    placeholderTextColor="#94a3b8"
                  />
                </View>
              )}
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>LÝ DO CHI TIẾT</Text>
              <TextInput
                style={styles.textArea}
                multiline
                numberOfLines={4}
                value={reason}
                onChangeText={setReason}
                placeholder="Nhập lý do cụ thể..."
                placeholderTextColor="#cbd5e1"
              />
            </View>

            {requestType !== 'overtime' && (
              <View style={styles.inputGroup}>
                <Text style={styles.label}>TÀI LIỆU MINH CHỨNG ĐÍNH KÈM</Text>
                <TouchableOpacity style={styles.attachBtn} onPress={pickDocument}>
                  <View style={styles.attachIconWrap}>
                    <Feather name="paperclip" size={20} color="#64748b" />
                  </View>
                  <View style={{ flex: 1, marginLeft: 10 }}>
                    <Text style={[styles.attachText, !attachment && { color: '#94a3b8' }]} numberOfLines={1}>
                      {attachment ? attachment.name : 'Nhấn để chọn file...'}
                    </Text>
                    {!attachment && <Text style={styles.attachSub}>PNG, JPG, PDF, DOCX (Tối đa 10MB)</Text>}
                  </View>
                  {attachment && (
                    <TouchableOpacity onPress={() => setAttachment(null)} style={{ padding: 5 }}>
                      <Feather name="x-circle" size={20} color="#e11d48" />
                    </TouchableOpacity>
                  )}
                </TouchableOpacity>
              </View>
            )}

            <TouchableOpacity style={styles.submitBtn} onPress={handleSubmit} disabled={isLoading}>
              {isLoading ? <ActivityIndicator color="#fff" /> : (
                <>
                  <Feather name="send" size={18} color="#fff" />
                  <Text style={styles.submitText}>GỬI YÊU CẦU</Text>
                </>
              )}
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      {/* Sheets Cần thiết */}
      <SwipeableSheet visible={showTypeSheet} onClose={() => setShowTypeSheet(false)} maxHeightRatio={0.6}>
        <View style={styles.sheetContent}>
          <Text style={styles.sheetTitle}>Chọn Loại Đơn</Text>
          <ScrollView>
            {['annual', 'sick', 'unpaid', 'overtime', 'attendance_error', 'late_excuse'].map((type) => (
              <TouchableOpacity key={type} style={styles.sheetItem} onPress={() => { setRequestType(type); setShowTypeSheet(false); }}>
                <Text style={[styles.sheetItemText, requestType === type && { color: '#00b4d8', fontWeight: 'bold' }]}>
                  {getLeaveTypeText(type)}
                </Text>
                {requestType === type && <Feather name="check" size={20} color="#00b4d8" />}
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
      </SwipeableSheet>

      <SwipeableSheet visible={showApproverSheet} onClose={() => setShowApproverSheet(false)} maxHeightRatio={0.5}>
        <View style={styles.sheetContent}>
          <Text style={styles.sheetTitle}>Chọn Người Kiểm Duyệt</Text>
          <ScrollView>
            {approvers.map((appr) => (
              <TouchableOpacity key={appr.id} style={styles.sheetItem} onPress={() => { setApproverId(appr.id); setShowApproverSheet(false); }}>
                <Text style={[styles.sheetItemText, approverId === appr.id && { color: '#00b4d8', fontWeight: 'bold' }]}>
                  {appr.full_name} ({appr.position_name})
                </Text>
                {approverId === appr.id && <Feather name="check" size={20} color="#00b4d8" />}
              </TouchableOpacity>
            ))}
            {approvers.length === 0 && <Text style={{ textAlign: 'center', marginTop: 20, color: '#94a3b8' }}>Không có người duyệt.</Text>}
          </ScrollView>
        </View>
      </SwipeableSheet>

    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#f8fafc' },
  header: {
    flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
    paddingHorizontal: 20, paddingTop: 10, paddingBottom: 15,
    backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#f1f5f9'
  },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#f1f5f9', justifyContent: 'center', alignItems: 'center' },
  iconWrap: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#e0f2fe', justifyContent: 'center', alignItems: 'center' },
  headerTitle: { fontSize: 18, fontWeight: '900', color: '#0f172a' },
  content: { padding: 20 },
  
  cardScroller: { paddingRight: 20, marginBottom: 20, gap: 15 },
  summaryCard: {
    width: width * 0.85, borderRadius: 24, padding: 20, overflow: 'hidden', position: 'relative'
  },
  cardTitleWrap: { flexDirection: 'row', alignItems: 'center', marginBottom: 15 },
  cardTitle: { color: '#fff', fontSize: 13, fontWeight: '600' },
  cardValWrap: { flexDirection: 'row', alignItems: 'baseline', marginBottom: 8 },
  cardValLarge: { color: '#fff', fontSize: 40, fontWeight: '900' },
  cardValSmall: { color: '#fff', fontSize: 15, fontWeight: '600', opacity: 0.9 },
  cardSubtitle: { color: '#fff', fontSize: 13, opacity: 0.9, marginBottom: 15 },
  cardFooter: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 8 },
  cardFooterText: { color: '#fff', fontSize: 12, fontWeight: '600', opacity: 0.9 },
  cardProgressBg: { width: '100%', height: 4, backgroundColor: 'rgba(255,255,255,0.2)', borderRadius: 2 },
  cardProgressFill: { height: 4, backgroundColor: '#fff', borderRadius: 2 },
  cardBgIcon: { position: 'absolute', right: -20, bottom: -20 },

  listContainer: { flex: 1 },
  quickActions: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 15 },
  actionBtn: { 
    flex: 1, backgroundColor: '#fff', padding: 15, borderRadius: 24, 
    alignItems: 'center', marginHorizontal: 5, shadowColor: '#000', 
    shadowOpacity: 0.03, shadowRadius: 10, elevation: 2, borderWidth: 1, borderColor: '#f1f5f9' 
  },
  actionBtnLarge: { marginHorizontal: 5 },
  actionIcon: { width: 50, height: 50, borderRadius: 16, justifyContent: 'center', alignItems: 'center', marginBottom: 10 },
  actionText: { fontSize: 13, fontWeight: '800', color: '#334155' },
  
  listHeader: { flexDirection: 'row', alignItems: 'center', marginTop: 20, marginBottom: 15, paddingHorizontal: 5 },
  listTitle: { fontSize: 12, fontWeight: '900', color: '#94a3b8', marginLeft: 8 },
  
  requestCard: { 
    backgroundColor: '#fff', padding: 20, borderRadius: 24, marginBottom: 15,
    borderWidth: 1, borderColor: '#f1f5f9', shadowColor: '#000', shadowOpacity: 0.02, shadowRadius: 8, elevation: 1
  },
  reqTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 5 },
  reqType: { fontSize: 15, fontWeight: '800', color: '#0f172a' },
  statusBadge: { paddingHorizontal: 10, paddingVertical: 4, borderRadius: 12 },
  statusText: { fontSize: 11, fontWeight: '800' },
  reqDate: { fontSize: 12, color: '#64748b', fontWeight: '500', marginBottom: 8 },
  reqReason: { fontSize: 13, color: '#475569', fontStyle: 'italic', lineHeight: 20 },
  emptyText: { textAlign: 'center', color: '#94a3b8', marginTop: 40, fontStyle: 'italic' },
  
  formContainer: { flex: 1 },
  inputGroup: { marginBottom: 20 },
  inputSplit: { flexDirection: 'row', justifyContent: 'space-between' },
  label: { fontSize: 11, fontWeight: '900', color: '#94a3b8', marginBottom: 8, marginLeft: 5 },
  pickerBox: {
    flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
    backgroundColor: '#fff', padding: 16, borderRadius: 16, borderWidth: 1, borderColor: '#e2e8f0'
  },
  pickerText: { fontSize: 15, fontWeight: '600', color: '#0f172a' },
  textArea: {
    backgroundColor: '#fff', padding: 18, borderRadius: 16, borderWidth: 1, borderColor: '#e2e8f0',
    fontSize: 15, color: '#0f172a', textAlignVertical: 'top', fontWeight: '500'
  },
  attachBtn: {
    flexDirection: 'row', alignItems: 'center', backgroundColor: '#f8fafc', padding: 15, borderRadius: 16, 
    borderWidth: 2, borderColor: '#e2e8f0', borderStyle: 'dashed'
  },
  attachIconWrap: { width: 40, height: 40, borderRadius: 20, backgroundColor: '#f1f5f9', justifyContent: 'center', alignItems: 'center' },
  attachText: { fontSize: 14, fontWeight: '600', color: '#0f172a' },
  attachSub: { fontSize: 11, color: '#94a3b8', marginTop: 2 },
  
  submitBtn: {
    backgroundColor: '#00b4d8', padding: 18, borderRadius: 16, flexDirection: 'row',
    justifyContent: 'center', alignItems: 'center', marginTop: 10, shadowColor: '#00b4d8', shadowOpacity: 0.3, shadowRadius: 10, elevation: 5
  },
  submitText: { color: '#fff', fontSize: 14, fontWeight: '900', marginLeft: 10 },

  sheetContent: { padding: 20, paddingBottom: 50 },
  sheetTitle: { fontSize: 18, fontWeight: '900', color: '#0f172a', marginBottom: 20, textAlign: 'center' },
  sheetItem: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 18, borderBottomWidth: 1, borderBottomColor: '#f1f5f9' },
  sheetItemText: { fontSize: 16, fontWeight: '600', color: '#334155' }
});
