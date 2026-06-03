import { useState, useEffect } from 'react';
import { Send, History, Bell, AlertTriangle, CheckCircle2, Loader2, Image as ImageIcon } from 'lucide-react';
import { collection, addDoc, query, orderBy, limit, getDocs, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';

const NotificationCenter = () => {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [sending, setSending] = useState(false);
  const [history, setHistory] = useState([]);
  const [loadingHistory, setLoadingHistory] = useState(true);
  const [status, setStatus] = useState(null); // { type: 'success' | 'error', message: string }

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      setLoadingHistory(true);
      const q = query(collection(db, 'notifications'), orderBy('sentAt', 'desc'), limit(10));
      const snapshot = await getDocs(q);
      const items = [];
      snapshot.forEach(doc => items.push({ id: doc.id, ...doc.data() }));
      setHistory(items);
    } catch (error) {
      console.error('Error fetching notification history:', error);
    } finally {
      setLoadingHistory(false);
    }
  };

  const handleSend = async (e) => {
    e.preventDefault();
    if (!title || !body) return;

    setSending(true);
    setStatus(null);

    try {
      // Note: In a real app, this collection would trigger a Cloud Function
      // that actually sends the Push Notification via FCM.
      await addDoc(collection(db, 'notifications'), {
        title,
        body,
        imageUrl,
        sentAt: serverTimestamp(),
        status: 'queued', // The Cloud Function will update this to 'sent'
        recipients: 'all_users'
      });

      setStatus({ 
        type: 'success', 
        message: 'Notification queued successfully! A background process will deliver it shortly.' 
      });
      
      setTitle('');
      setBody('');
      setImageUrl('');
      fetchHistory();
    } catch (error) {
      console.error('Error queuing notification:', error);
      setStatus({ type: 'error', message: 'Failed to queue notification. Please check your connection.' });
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="max-w-6xl mx-auto space-y-8">
      <div className="flex flex-col gap-1">
        <h1 className="text-2xl font-bold text-slate-900">Push Notification Center</h1>
        <p className="text-slate-500">Communicate directly with your users via mobile alerts.</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Composer */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="p-6 border-b border-slate-200 bg-slate-50/50">
            <h2 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <Send className="w-5 h-5 text-primary-600" />
              Compose Broadcast
            </h2>
          </div>
          
          <form onSubmit={handleSend} className="p-6 space-y-6">
            {status && (
              <div className={`p-4 rounded-xl flex items-start gap-3 ${
                status.type === 'success' ? 'bg-emerald-50 text-emerald-800' : 'bg-red-50 text-red-800'
              }`}>
                {status.type === 'success' ? <CheckCircle2 className="w-5 h-5 shrink-0" /> : <AlertTriangle className="w-5 h-5 shrink-0" />}
                <p className="text-sm font-medium">{status.message}</p>
              </div>
            )}

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Notification Title</label>
                <input 
                  type="text" 
                  required
                  placeholder="e.g., Morning Adhkar Time"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full p-2.5 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Message Body</label>
                <textarea 
                  required
                  rows={4}
                  placeholder="Type your message here..."
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  className="w-full p-2.5 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Image URL (Optional)</label>
                <div className="relative">
                  <ImageIcon className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
                  <input 
                    type="url" 
                    placeholder="https://example.com/image.jpg"
                    value={imageUrl}
                    onChange={(e) => setImageUrl(e.target.value)}
                    className="w-full pl-10 pr-4 py-2.5 border border-slate-200 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-sm"
                  />
                </div>
              </div>
            </div>

            <button
              type="submit"
              disabled={sending}
              className="w-full bg-slate-900 text-white font-bold py-3 rounded-xl hover:bg-slate-800 transition-all flex items-center justify-center gap-2 disabled:opacity-50"
            >
              {sending ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Sending Broadcast...
                </>
              ) : (
                <>
                  <Send className="w-5 h-5" />
                  Send to All Users
                </>
              )}
            </button>
          </form>
        </div>

        {/* History */}
        <div className="bg-white rounded-2xl border border-slate-200 shadow-sm flex flex-col h-full">
          <div className="p-6 border-b border-slate-200 flex items-center justify-between">
            <h2 className="text-lg font-bold text-slate-900 flex items-center gap-2">
              <History className="w-5 h-5 text-slate-400" />
              Recent Notifications
            </h2>
            <Bell className="w-5 h-5 text-slate-300" />
          </div>

          <div className="flex-1 overflow-y-auto p-6 space-y-4">
            {loadingHistory ? (
              <div className="h-full flex items-center justify-center">
                <Loader2 className="w-8 h-8 animate-spin text-slate-300" />
              </div>
            ) : history.length === 0 ? (
              <div className="h-full flex flex-col items-center justify-center text-slate-400 gap-2">
                <Bell className="w-12 h-12 opacity-20" />
                <p>No distribution history found.</p>
              </div>
            ) : (
              history.map((item) => (
                <div key={item.id} className="p-4 border border-slate-100 rounded-xl hover:bg-slate-50 transition-colors group">
                  <div className="flex justify-between items-start mb-2">
                    <h3 className="font-bold text-slate-900 group-hover:text-primary-700 transition-colors">{item.title}</h3>
                    <span className="text-[10px] uppercase tracking-wider font-bold bg-slate-100 text-slate-500 px-2 py-1 rounded">
                      {item.status || 'Sent'}
                    </span>
                  </div>
                  <p className="text-sm text-slate-600 line-clamp-2 mb-3">{item.body}</p>
                  <div className="flex items-center gap-2 text-[10px] text-slate-400 font-medium">
                    <History className="w-3 h-3" />
                    {item.sentAt?.toDate ? item.sentAt.toDate().toLocaleString() : 'Just now'}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="p-6 bg-blue-50 rounded-2xl border border-blue-100 flex items-start gap-4">
        <div className="w-10 h-10 rounded-xl bg-blue-600 text-white flex items-center justify-center shrink-0 shadow-lg shadow-blue-200">
          <Bell className="w-5 h-5" />
        </div>
        <div className="space-y-1">
          <h3 className="font-bold text-blue-900">How Broadcaster Works</h3>
          <p className="text-sm text-blue-700/80 leading-relaxed">
            When you send a broadcast, it's queued in the database. 
            A cloud trigger monitors this collection and transmits the payload 
            to your users' devices via <strong>Firebase Cloud Messaging (FCM)</strong>.
          </p>
        </div>
      </div>
    </div>
  );
};

export default NotificationCenter;
