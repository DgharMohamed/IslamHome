import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, deleteDoc, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Plus, Trash2, Edit2, Search, Loader2 } from 'lucide-react';

const TafsirManager = () => {
  const [tafsirList, setTafsirList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    surahNumber: '',
    surahName: '',
    ayahNumber: '',
    tafsirText: '',
    scholar: '',
    language: 'ar'
  });
  const [saving, setSaving] = useState(false);

  const scholars = [
    'ابن كثير',
    'الطبري',
    'القرطبي',
    'السعدي',
    'الجلالين',
    'ابن عاشور',
    'الشعراوي'
  ];

  useEffect(() => {
    fetchTafsir();
  }, []);

  const fetchTafsir = async () => {
    try {
      setLoading(true);
      const querySnapshot = await getDocs(collection(db, 'tafsir'));
      const data = [];
      querySnapshot.forEach((doc) => {
        data.push({ id: doc.id, ...doc.data() });
      });
      setTafsirList(data);
    } catch (error) {
      console.error('Error fetching tafsir:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (item = null) => {
    if (item) {
      setEditingId(item.id);
      setFormData({
        surahNumber: item.surahNumber || '',
        surahName: item.surahName || '',
        ayahNumber: item.ayahNumber || '',
        tafsirText: item.tafsirText || '',
        scholar: item.scholar || '',
        language: item.language || 'ar'
      });
    } else {
      setEditingId(null);
      setFormData({ 
        surahNumber: '', surahName: '', ayahNumber: '', 
        tafsirText: '', scholar: '', language: 'ar'
      });
    }
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this Tafsir?')) {
      try {
        await deleteDoc(doc(db, 'tafsir', id));
        fetchTafsir();
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
        await updateDoc(doc(db, 'tafsir', editingId), {
          ...formData,
          surahNumber: Number(formData.surahNumber),
          ayahNumber: Number(formData.ayahNumber),
          updatedAt: serverTimestamp()
        });
      } else {
        await addDoc(collection(db, 'tafsir'), {
          ...formData,
          surahNumber: Number(formData.surahNumber),
          ayahNumber: Number(formData.ayahNumber),
          createdAt: serverTimestamp()
        });
      }
      setIsModalOpen(false);
      fetchTafsir();
    } catch (error) {
      console.error('Error saving document:', error);
    } finally {
      setSaving(false);
    }
  };

  const filteredTafsir = tafsirList.filter(item => 
    item.surahName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.scholar?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.tafsirText?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Tafsir Management</h1>
          <p className="text-slate-500 text-sm mt-1">Manage Quran exegesis, interpretations, and scholars.</p>
        </div>
        <button 
          onClick={() => handleOpenModal()}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors shadow-sm"
        >
          <Plus className="w-5 h-5" />
          Add Tafsir
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-200 flex items-center gap-4 bg-slate-50/50">
          <div className="relative flex-1 max-w-md">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search by surah or scholar..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 outline-none transition-all"
            />
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-500 font-medium">
            <span>{filteredTafsir.length} Records</span>
          </div>
        </div>

        {loading ? (
          <div className="p-12 flex flex-col items-center justify-center text-slate-500">
            <Loader2 className="w-8 h-8 animate-spin text-primary-500 mb-4" />
            <p>Loading tafsir library...</p>
          </div>
        ) : filteredTafsir.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p>No tafsir records found. Click "Add Tafsir" to create one.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-semibold">
                  <th className="p-4">Surah</th>
                  <th className="p-4">Ayah</th>
                  <th className="p-4">Scholar</th>
                  <th className="p-4 w-1/3">Tafsir Excerpt</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {filteredTafsir.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4">
                      <p className="font-medium text-slate-900" dir="rtl">{item.surahName}</p>
                      <p className="text-xs text-slate-500">No. {item.surahNumber}</p>
                    </td>
                    <td className="p-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-800">
                        {item.ayahNumber}
                      </span>
                    </td>
                    <td className="p-4">
                      <span className="text-sm font-medium text-primary-700" dir="rtl">{item.scholar}</span>
                    </td>
                    <td className="p-4">
                      <div className="line-clamp-2 text-sm text-slate-600" dir="rtl">
                        {item.tafsirText}
                      </div>
                    </td>
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
          <div className="bg-white rounded-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="p-6 border-b border-slate-200 flex justify-between items-center bg-slate-50 sticky top-0 z-10">
              <h2 className="text-xl font-bold text-slate-900">
                {editingId ? 'Edit Tafsir' : 'Add New Tafsir'}
              </h2>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 hover:bg-slate-200 p-2 rounded-full transition-colors"
              >
                ✕
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Surah Number *</label>
                  <input 
                    type="number" 
                    min="1" max="114"
                    required
                    value={formData.surahNumber}
                    onChange={(e) => setFormData({...formData, surahNumber: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Surah Name (Arabic) *</label>
                  <input 
                    type="text" 
                    required
                    dir="rtl"
                    value={formData.surahName}
                    onChange={(e) => setFormData({...formData, surahName: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none font-arabic text-right"
                    placeholder="الفاتحة..."
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Ayah Number *</label>
                  <input 
                    type="number" 
                    min="1"
                    required
                    value={formData.ayahNumber}
                    onChange={(e) => setFormData({...formData, ayahNumber: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Scholar / Source *</label>
                  <select 
                    value={formData.scholar}
                    onChange={(e) => setFormData({...formData, scholar: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none dir-rtl font-arabic text-right"
                    required
                  >
                    <option value="" disabled>اختر المفسر</option>
                    {scholars.map(s => <option key={s} value={s}>{s}</option>)}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Language *</label>
                  <select 
                    value={formData.language}
                    onChange={(e) => setFormData({...formData, language: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                    required
                  >
                    <option value="ar">العربية (Arabic)</option>
                    <option value="en">English</option>
                    <option value="ur">اردو (Urdu)</option>
                    <option value="fr">Français (French)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 mb-1.5">Tafsir Text *</label>
                <textarea 
                  required
                  dir={formData.language === 'ar' ? "rtl" : "ltr"}
                  rows={8}
                  value={formData.tafsirText}
                  onChange={(e) => setFormData({...formData, tafsirText: e.target.value})}
                  className={`w-full p-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none text-lg leading-relaxed ${
                    formData.language === 'ar' ? 'font-arabic text-right' : 'text-left'
                  }`}
                  placeholder="اكتب التفسير هنا..."
                />
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
                  {saving ? 'Saving...' : 'Save Tafsir'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default TafsirManager;
