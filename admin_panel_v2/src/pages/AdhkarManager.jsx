import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, deleteDoc, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Plus, Trash2, Edit2, Search, Loader2 } from 'lucide-react';

const AdhkarManager = () => {
  const [adhkar, setAdhkar] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    title: '',
    category: 'morning',
    content: '',
    count: 1,
    reference: ''
  });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchAdhkar();
  }, []);

  const fetchAdhkar = async () => {
    try {
      setLoading(true);
      const querySnapshot = await getDocs(collection(db, 'adhkar'));
      const adhkarData = [];
      querySnapshot.forEach((doc) => {
        adhkarData.push({ id: doc.id, ...doc.data() });
      });
      setAdhkar(adhkarData);
    } catch (error) {
      console.error('Error fetching adhkar:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (item = null) => {
    if (item) {
      setEditingId(item.id);
      setFormData({
        title: item.title || '',
        category: item.category || 'morning',
        content: item.content || '',
        count: item.count || 1,
        reference: item.reference || ''
      });
    } else {
      setEditingId(null);
      setFormData({ title: '', category: 'morning', content: '', count: 1, reference: '' });
    }
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this Dhikr?')) {
      try {
        await deleteDoc(doc(db, 'adhkar', id));
        fetchAdhkar();
      } catch (error) {
        console.error('Error deleting document:', error);
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      if (editingId) {
        await updateDoc(doc(db, 'adhkar', editingId), {
          ...formData,
          updatedAt: serverTimestamp()
        });
      } else {
        await addDoc(collection(db, 'adhkar'), {
          ...formData,
          createdAt: serverTimestamp()
        });
      }
      setIsModalOpen(false);
      fetchAdhkar();
    } catch (error) {
      console.error('Error saving document:', error);
    } finally {
      setSaving(false);
    }
  };

  const filteredAdhkar = adhkar.filter(item => 
    item.title?.toLowerCase().includes(searchTerm.toLowerCase()) || 
    item.content?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Adhkar Content Manager</h1>
          <p className="text-slate-500 text-sm mt-1">Manage the library of supplications and remembrances.</p>
        </div>
        <button 
          onClick={() => handleOpenModal()}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors shadow-sm"
        >
          <Plus className="w-5 h-5" />
          Add New Dhikr
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-200 flex items-center gap-4 bg-slate-50/50">
          <div className="relative flex-1 max-w-md">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search adhkar..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 outline-none transition-all"
            />
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-500 font-medium">
            <span>{filteredAdhkar.length} Items</span>
          </div>
        </div>

        {loading ? (
          <div className="p-12 flex flex-col items-center justify-center text-slate-500">
            <Loader2 className="w-8 h-8 animate-spin text-primary-500 mb-4" />
            <p>Loading adhkar library...</p>
          </div>
        ) : filteredAdhkar.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p>No adhkar found. Click "Add New Dhikr" to create one.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-semibold">
                  <th className="p-4">Title</th>
                  <th className="p-4">Category</th>
                  <th className="p-4">Count</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {filteredAdhkar.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4">
                      <p className="font-medium text-slate-900">{item.title}</p>
                      <p className="text-xs text-slate-500 truncate max-w-md mt-1" dir="rtl">{item.content}</p>
                    </td>
                    <td className="p-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 capitalize">
                        {item.category}
                      </span>
                    </td>
                    <td className="p-4 text-slate-600 font-medium">{item.count}</td>
                    <td className="p-4">
                      <div className="flex items-center justify-end gap-2">
                        <button 
                          onClick={() => handleOpenModal(item)}
                          className="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-colors"
                          title="Edit"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => handleDelete(item.id)}
                          className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                          title="Delete"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Add/Edit Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-slate-900/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="p-6 border-b border-slate-200 flex justify-between items-center bg-slate-50 sticky top-0 z-10">
              <h2 className="text-xl font-bold text-slate-900">
                {editingId ? 'Edit Dhikr' : 'Add New Dhikr'}
              </h2>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 hover:bg-slate-200 p-2 rounded-full transition-colors"
              >
                ✕
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-5">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Title (Description)</label>
                  <input 
                    type="text" 
                    required
                    value={formData.title}
                    onChange={(e) => setFormData({...formData, title: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                    placeholder="e.g. Morning praise"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Category</label>
                  <select 
                    value={formData.category}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                  >
                    <option value="morning">Morning Adhkar</option>
                    <option value="evening">Evening Adhkar</option>
                    <option value="after_prayer">After Prayer</option>
                    <option value="general">General</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Arabic Content</label>
                <textarea 
                  required
                  dir="rtl"
                  rows={4}
                  value={formData.content}
                  onChange={(e) => setFormData({...formData, content: e.target.value})}
                  className="w-full p-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-lg text-right font-arabic leading-relaxed"
                  placeholder="أدخل النص العربي للذكر..."
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Target Count</label>
                  <input 
                    type="number" 
                    min="1"
                    required
                    value={formData.count}
                    onChange={(e) => setFormData({...formData, count: Number(e.target.value)})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Reference / Fadel (Optional)</label>
                  <input 
                    type="text" 
                    dir="rtl"
                    value={formData.reference}
                    onChange={(e) => setFormData({...formData, reference: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-right"
                    placeholder="مثال: سورة البقرة، الحديث كذا..."
                  />
                </div>
              </div>

              <div className="pt-6 mt-6 border-t border-slate-200 flex justify-end gap-3 sticky bottom-0 bg-white">
                <button 
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-5 py-2.5 text-slate-600 font-medium hover:bg-slate-100 rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button 
                  type="submit"
                  disabled={saving}
                  className="bg-primary-600 hover:bg-primary-700 text-white px-6 py-2.5 rounded-lg font-medium shadow-sm transition-colors flex items-center gap-2"
                >
                  {saving && <Loader2 className="w-4 h-4 animate-spin" />}
                  {saving ? 'Saving...' : 'Save Dhikr'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdhkarManager;
