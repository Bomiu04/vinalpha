import { io } from 'socket.io-client';

/**
 * Socket dùng chung cho trang giám sát (tránh tạo nhiều kết nối khi HMR / re-mount).
 */
let sharedSocket = null;

export function getManagerSocket(socketUrl) {
  if (!sharedSocket) {
    sharedSocket = io(socketUrl, {
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 10000,
      timeout: 20000,
    });
  }
  return sharedSocket;
}

export function socketOriginFromApiBase(apiBase) {
  if (!apiBase || typeof apiBase !== 'string') return 'http://localhost:5000';
  return apiBase.replace(/\/api\/?$/, '') || 'http://localhost:5000';
}
