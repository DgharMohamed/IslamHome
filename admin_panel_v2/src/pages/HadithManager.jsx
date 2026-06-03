import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, deleteDoc, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Plus, Trash2, Edit2, Search, Loader2 } from 'lucide-react';

const HadithManager = () => {
  const [hadithList, setHadithList] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    hadithText: '',
    narrator: '',
    book: '',
    bookNumber: '',
    chapter: '',
    grade: '',
    category: '',
    language: 'ar'
  });
  const [saving, setSaving] = useState(false);

  const books = [
    'صحيح البخاري',
    'صحيح مسلم',
    'سنن أبي داود',
    'سنن الترمذي',
    'سنن النسائي',
    'سنن ابن ماجه',
    'مسند أحمد',
    'موطأ مالك'
  ];

  const grades = ['صحيح', 'حسن', 'ضعيف', 'موضوع'];

  const categories = [
    'العقيدة',
    'العبادات',
    'المعاملات',
    'الأخلاق والآداب',
    'السيرة النبوية',
    'الرقائق',
    'الجهاد',
    'الطلاق',
    'الزكاة'
  ];

  useEffect(() => {
    fetchHadith();
  }, []);

  const fetchHadith = async () => {
    try {
      setLoading(true);
      const querySnapshot = await getDocs(collection(db, 'hadith'));
      const data = [];
      querySnapshot.forEach((doc) => {
        data.push({ id: doc.id, ...doc.data() });
      });
      setHadithList(data);
    } catch (error) {
      console.error('Error fetching hadith:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (item = null) => {
    if (item) {
      setEditingId(item.id);
      setFormData({
        hadithText: item.hadithText || '',
        narrator: item.narrator || '',
        book: item.book || '',
        bookNumber: item.bookNumber || '',
        chapter: item.chapter || '',
        grade: item.grade || '',
        category: item.category || '',
        language: item.language || 'ar'
      });
    } else {
      setEditingId(null);
      setFormData({ 
        hadithText: '', narrator: '', book: '', bookNumber: '', 
        chapter: '', grade: '', category: '', language: 'ar'
      });
    }
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this Hadith?')) {
      try {
        await deleteDoc(doc(db, 'hadith', id));
        fetchHadith();
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
        await updateDoc(doc(db, 'hadith', editingId), {
          ...formData,
          updatedAt: serverTimestamp()
        });
      } else {
        await addDoc(collection(db, 'hadith'), {
          ...formData,
          createdAt: serverTimestamp()
        });
      }
      setIsModalOpen(false);
      fetchHadith();
    } catch (error) {
      console.error('Error saving document:', error);
    } finally {
      setSaving(false);
    }
  };

  const filteredHadith = hadithList.filter(item => 
    item.hadithText?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    item.narrator?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Hadith Management</h1>
          <p className="text-slate-500 text-sm mt-1">Manage Prophetic traditions, sources, and classifications.</p>
        </div>
        <button 
          onClick={() => handleOpenModal()}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors shadow-sm"
        >
          <Plus className="w-5 h-5" />
          Add Hadith
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-200 flex items-center gap-4 bg-slate-50/50">
          <div className="relative flex-1 max-w-md">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search hadith..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 outline-none transition-all"
            />
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-500 font-medium">
            <span>{filteredHadith.length} Hadiths</span>
          </div>
        </div>

        {loading ? (
          <div className="p-12 flex flex-col items-center justify-center text-slate-500">
            <Loader2 className="w-8 h-8 animate-spin text-primary-500 mb-4" />
            <p>Loading hadith library...</p>
          </div>
        ) : filteredHadith.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p>No hadiths found. Click "Add Hadith" to create one.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-semibold">
                  <th className="p-4">Content</th>
                  <th className="p-4">Book</th>
                  <th className="p-4">Grade</th>
                  <th className="p-4">Category</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {filteredHadith.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4 w-1/3">
                      <div className="line-clamp-2 text-sm text-slate-800" dir="rtl">
                        {item.hadithText}
                      </div>
                      <p className="text-xs text-slate-500 mt-1" dir="rtl">
                        {item.narrator}
                      </p>
                    </td>
                    <td className="p-4">
                      <p className="text-sm font-medium text-slate-700" dir="rtl">{item.book}</p>
                      {item.bookNumber && <p className="text-xs text-slate-500">No. {item.bookNumber}</p>}
                    </td>
                    <td className="p-4">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        item.grade === 'صحيح' ? 'bg-green-100 text-green-800' :
                        item.grade === 'حسن' ? 'bg-amber-100 text-amber-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {item.grade}
                      </span>
                    </td>
                    <td className="p-4">
                      <span className="text-sm text-slate-600" dir="rtl">{item.category}</span>
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
                {editingId ? 'Edit Hadith' : 'Add New Hadith'}
              </h2>
              <button 
                onClick={() => setIsModalOpen(false)}
                className="text-slate-400 hover:text-slate-600 hover:bg-slate-200 p-2 rounded-full transition-colors"
              >
                ✕
              </button>
            </div>
            
            <form onSubmit={handleSubmit} className="p-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div className="md:col-span-2">
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Hadith Text (Arabic) *</label>
                  <textarea 
                    required
                    dir="rtl"
                    rows={5}
                    value={formData.hadithText}
                    onChange={(e) => setFormData({...formData, hadithText: e.target.value})}
                    className="w-full p-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none font-arabic text-right text-lg leading-relaxed"
                    placeholder="نص الحديث..."
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Narrator *</label>
                  <input 
                    type="text" 
                    required
                    dir="rtl"
                    value={formData.narrator}
                    onChange={(e) => setFormData({...formData, narrator: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none font-arabic text-right"
                    placeholder="الراوي..."
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Chapter / Section</label>
                  <input 
                    type="text" 
                    dir="rtl"
                    value={formData.chapter}
                    onChange={(e) => setFormData({...formData, chapter: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none font-arabic text-right"
                    placeholder="الباب..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Book / Source *</label>
                  <select 
                    value={formData.book}
                    onChange={(e) => setFormData({...formData, book: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none dir-rtl font-arabic text-right"
                    required
                  >
                    <option value="" disabled>اختر الكتاب</option>
                    {books.map(b => <option key={b} value={b}>{b}</option>)}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Hadith Number</label>
                  <input 
                    type="text" 
                    value={formData.bookNumber}
                    onChange={(e) => setFormData({...formData, bookNumber: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                    placeholder="e.g. 153"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Grade (Authenticity) *</label>
                  <select 
                    value={formData.grade}
                    onChange={(e) => setFormData({...formData, grade: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none dir-rtl font-arabic text-right"
                    required
                  >
                    <option value="" disabled>اختر الدرجة</option>
                    {grades.map(g => <option key={g} value={g}>{g}</option>)}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Category (Topic) *</label>
                  <select 
                    value={formData.category}
                    onChange={(e) => setFormData({...formData, category: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none dir-rtl font-arabic text-right"
                    required
                  >
                    <option value="" disabled>اختر التصنيف</option>
                    {categories.map(c => <option key={c} value={c}>{c}</option>)}
                  </select>
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
                  {saving ? 'Saving...' : 'Save Hadith'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default HadithManager;
