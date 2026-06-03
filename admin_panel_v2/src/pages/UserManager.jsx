import { useState, useEffect } from 'react';
import { collection, getDocs, doc, deleteDoc, query, orderBy, limit, startAfter } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Users, Search, Loader2, Trash2, Calendar, Globe, User } from 'lucide-react';

const UserManager = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [lastVisible, setLastVisible] = useState(null);
  const [totalCount, setTotalCount] = useState(0);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const q = query(collection(db, 'users'), orderBy('lastUpdated', 'desc'), limit(20));
      const querySnapshot = await getDocs(q);
      
      const userData = [];
      querySnapshot.forEach((doc) => {
        userData.push({ uid: doc.id, ...doc.data() });
      });
      
      setUsers(userData);
      setLastVisible(querySnapshot.docs[querySnapshot.docs.length - 1]);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async (uid) => {
    if (window.confirm('Are you sure you want to delete this user record from Firestore? This will NOT delete their Auth account.')) {
      try {
        await deleteDoc(doc(db, 'users', uid));
        setUsers(users.filter(u => u.uid !== uid));
      } catch (error) {
        console.error('Error deleting user record:', error);
      }
    }
  };

  const filteredUsers = users.filter(user => 
    user.uid.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatDate = (timestamp) => {
    if (!timestamp) return 'Never';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return date.toLocaleString();
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">User Management</h1>
          <p className="text-slate-500 text-sm mt-1">View and monitor registered app users and their preferences.</p>
        </div>
        <div className="flex bg-blue-50 border border-blue-100 rounded-xl px-4 py-2 items-center gap-3">
          <Users className="w-5 h-5 text-blue-600" />
          <div>
            <p className="text-xs text-blue-600 font-medium uppercase tracking-wider">Total Records</p>
            <p className="text-lg font-bold text-slate-900">{users.length}{lastVisible ? '+' : ''}</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-200 bg-slate-50/50 flex items-center gap-4">
          <div className="relative flex-1 max-w-md">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search by UID..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 outline-none transition-all"
            />
          </div>
        </div>

        {loading ? (
          <div className="p-20 flex flex-col items-center justify-center text-slate-500">
            <Loader2 className="w-10 h-10 animate-spin text-primary-500 mb-4" />
            <p className="font-medium">Fetching users from directory...</p>
          </div>
        ) : filteredUsers.length === 0 ? (
          <div className="p-20 text-center text-slate-500">
            <Users className="w-12 h-12 mx-auto text-slate-200 mb-4" />
            <p className="text-lg font-medium">No users found</p>
            <p className="text-sm">Try adjusting your search or check your connection.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-semibold">
                  <th className="p-4">User Identifier (UID)</th>
                  <th className="p-4">Language</th>
                  <th className="p-4">Last Activity</th>
                  <th className="p-4">Status</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredUsers.map((user) => (
                  <tr key={user.uid} className="hover:bg-slate-50/50 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center">
                          <User className="w-4 h-4 text-slate-500" />
                        </div>
                        <div>
                          <p className="text-sm font-mono text-slate-900 leading-none mb-1">{user.uid}</p>
                          <p className="text-[10px] text-slate-400 font-medium">STORED IN FIRESTORE</p>
                        </div>
                      </div>
                    </td>
                    <td className="p-4 text-sm text-slate-600">
                      <div className="flex items-center gap-2">
                        <Globe className="w-4 h-4 text-slate-400" />
                        <span className="uppercase">{user.settings?.language || 'Unknown'}</span>
                      </div>
                    </td>
                    <td className="p-4 text-sm text-slate-600">
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4 text-slate-400" />
                        {formatDate(user.lastUpdated)}
                      </div>
                    </td>
                    <td className="p-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                        Active
                      </span>
                    </td>
                    <td className="p-4 text-right">
                      <button 
                        onClick={() => handleDeleteUser(user.uid)}
                        className="p-2 text-slate-300 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all"
                        title="Delete record from Firestore"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      
      <div className="p-4 bg-amber-50 border border-amber-100 rounded-xl flex gap-3 text-amber-800 text-sm italic">
        <p><strong>Note:</strong> Display names and emails are managed via Firebase Authentication. This page lists corresponding profile records stored in Firestore.</p>
      </div>
    </div>
  );
};

export default UserManager;
