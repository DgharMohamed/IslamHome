import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, deleteDoc, doc, updateDoc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Plus, Trash2, Edit2, Search, Loader2 } from 'lucide-react';

const ReciterManager = () => {
  const [reciters, setReciters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  // Form State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    name: '',
    letter: '',
    photo: '',
    moshaf: [{
      name: 'حفص عن عاصم',
      server: '',
      surah_total: 114
    }]
  });
  const [saving, setSaving] = useState(false);

  const rewayat = [
    'حفص عن عاصم',
    'ورش عن نافع',
    'قالون عن نافع',
    'الدوري عن أبي عمرو',
    'السوسي عن أبي عمرو',
    'شعبة عن عاصم',
    'خلف عن حمزة',
    'المصحف المرتل'
  ];

  useEffect(() => {
    fetchReciters();
  }, []);

  const fetchReciters = async () => {
    try {
      setLoading(true);
      const querySnapshot = await getDocs(collection(db, 'reciters'));
      const data = [];
      querySnapshot.forEach((doc) => {
        data.push({ id: doc.id, ...doc.data() });
      });
      setReciters(data);
    } catch (error) {
      console.error('Error fetching reciters:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleOpenModal = (item = null) => {
    if (item) {
      setEditingId(item.id);
      setFormData({
        name: item.name || '',
        letter: item.letter || '',
        photo: item.photo || '',
        moshaf: item.moshaf && item.moshaf.length > 0 ? item.moshaf : [{
          name: 'حفص عن عاصم',
          server: '',
          surah_total: 114
        }]
      });
    } else {
      setEditingId(null);
      setFormData({ 
        name: '', 
        letter: '', 
        photo: '', 
        moshaf: [{ name: 'حفص عن عاصم', server: '', surah_total: 114 }] 
      });
    }
    setIsModalOpen(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this Reciter?')) {
      try {
        await deleteDoc(doc(db, 'reciters', id));
        fetchReciters();
      } catch (error) {
        console.error('Error deleting document:', error);
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    
    // Auto generate letter if not set
    const letterToSave = formData.letter || (formData.name ? formData.name.charAt(0) : '');

    try {
      if (editingId) {
        await updateDoc(doc(db, 'reciters', editingId), {
          ...formData,
          letter: letterToSave,
          updatedAt: serverTimestamp()
        });
      } else {
        await addDoc(collection(db, 'reciters'), {
          ...formData,
          letter: letterToSave,
          createdAt: serverTimestamp()
        });
      }
      setIsModalOpen(false);
      fetchReciters();
    } catch (error) {
      console.error('Error saving document:', error);
    } finally {
      setSaving(false);
    }
  };

  const addMoshaf = () => {
    setFormData({
      ...formData,
      moshaf: [
        ...formData.moshaf,
        { name: 'حفص عن عاصم', server: '', surah_total: 114 }
      ]
    });
  };

  const updateMoshafField = (index, field, value) => {
    const newMoshaf = [...formData.moshaf];
    newMoshaf[index] = { ...newMoshaf[index], [field]: value };
    setFormData({ ...formData, moshaf: newMoshaf });
  };

  const removeMoshaf = (index) => {
    const newMoshaf = formData.moshaf.filter((_, i) => i !== index);
    setFormData({ ...formData, moshaf: newMoshaf });
  };

  const filteredReciters = reciters.filter(item => 
    item.name?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Reciters Management</h1>
          <p className="text-slate-500 text-sm mt-1">Manage Quran reciters, their audio servers, and riwayat.</p>
        </div>
        <button 
          onClick={() => handleOpenModal()}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors shadow-sm"
        >
          <Plus className="w-5 h-5" />
          Add New Reciter
        </button>
      </div>

      <div className="bg-white rounded-xl border border-slate-200 overflow-hidden shadow-sm">
        <div className="p-4 border-b border-slate-200 flex items-center gap-4 bg-slate-50/50">
          <div className="relative flex-1 max-w-md">
            <Search className="w-5 h-5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search reciters..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-slate-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 outline-none transition-all"
            />
          </div>
          <div className="flex items-center gap-2 text-sm text-slate-500 font-medium">
            <span>{filteredReciters.length} Reciters</span>
          </div>
        </div>

        {loading ? (
          <div className="p-12 flex flex-col items-center justify-center text-slate-500">
            <Loader2 className="w-8 h-8 animate-spin text-primary-500 mb-4" />
            <p>Loading reciters...</p>
          </div>
        ) : filteredReciters.length === 0 ? (
          <div className="p-12 text-center text-slate-500">
            <p>No reciters found. Click "Add New Reciter" to create one.</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200 text-xs uppercase tracking-wider text-slate-500 font-semibold" dir="ltr">
                  <th className="p-4">Name</th>
                  <th className="p-4">Riwayat (Moshaf count)</th>
                  <th className="p-4">Server Preview</th>
                  <th className="p-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-200">
                {filteredReciters.map((item) => (
                  <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                    <td className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center overflow-hidden flex-shrink-0">
                          {item.photo ? (
                            <img src={item.photo} alt={item.name} className="w-full h-full object-cover" />
                          ) : (
                            <span className="text-xl">🎙️</span>
                          )}
                        </div>
                        <p className="font-medium text-slate-900" dir="rtl">{item.name}</p>
                      </div>
                    </td>
                    <td className="p-4">
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                        {item.moshaf?.length || 0} Moshaf(s)
                      </span>
                    </td>
                    <td className="p-4">
                      <p className="text-xs text-slate-500 truncate max-w-[200px]" dir="ltr">
                        {item.moshaf?.[0]?.server || 'No server'}
                      </p>
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
          <div className="bg-white rounded-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto shadow-2xl border border-slate-200">
            <div className="p-6 border-b border-slate-200 flex justify-between items-center bg-slate-50 sticky top-0 z-10">
              <h2 className="text-xl font-bold text-slate-900">
                {editingId ? 'Edit Reciter' : 'Add New Reciter'}
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
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Reciter Name (Arabic) *</label>
                  <input 
                    type="text" 
                    required
                    dir="rtl"
                    value={formData.name}
                    onChange={(e) => setFormData({...formData, name: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none font-arabic text-right"
                    placeholder="e.g. عبدالباسط عبدالصمد"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 mb-1.5">Photo URL</label>
                  <input 
                    type="url" 
                    value={formData.photo}
                    onChange={(e) => setFormData({...formData, photo: e.target.value})}
                    className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                    placeholder="https://example.com/photo.jpg"
                  />
                </div>
              </div>

              <div>
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-lg font-semibold text-slate-900">Moshafs / Riwayat</h3>
                  <button 
                    type="button"
                    onClick={addMoshaf}
                    className="text-primary-600 hover:bg-primary-50 px-3 py-1.5 rounded-lg font-medium text-sm transition-colors border border-primary-200"
                  >
                    + Add Moshaf
                  </button>
                </div>

                <div className="space-y-4">
                  {formData.moshaf.map((moshaf, index) => (
                    <div key={index} className="p-4 bg-slate-50 border border-slate-200 rounded-xl relative">
                      {formData.moshaf.length > 1 && (
                        <button
                          type="button"
                          onClick={() => removeMoshaf(index)}
                          className="absolute top-4 right-4 text-red-500 hover:bg-red-50 p-1.5 rounded-lg transition-colors"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                      
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pr-10">
                        <div>
                          <label className="block text-sm font-medium text-slate-700 mb-1.5">Riwayah (Narration) *</label>
                          <select 
                            value={moshaf.name}
                            onChange={(e) => updateMoshafField(index, 'name', e.target.value)}
                            className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none dir-rtl font-arabic text-right"
                            required
                          >
                            {rewayat.map(r => (
                              <option key={r} value={r}>{r}</option>
                            ))}
                          </select>
                        </div>
                        <div>
                          <label className="block text-sm font-medium text-slate-700 mb-1.5">Surah Total</label>
                          <input 
                            type="number" 
                            min="1" max="114"
                            value={moshaf.surah_total}
                            onChange={(e) => updateMoshafField(index, 'surah_total', Number(e.target.value))}
                            className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                            required
                          />
                        </div>
                        <div className="md:col-span-2">
                          <label className="block text-sm font-medium text-slate-700 mb-1.5">Audio Server URL *</label>
                          <input 
                            type="url" 
                            value={moshaf.server}
                            onChange={(e) => updateMoshafField(index, 'server', e.target.value)}
                            className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                            placeholder="https://server.mp3quran.net/basit/Rewayat-Hafs-A-n-Assem/"
                            required
                          />
                          <p className="text-xs text-slate-500 mt-1">Base URL for audio files without the 001.mp3 at the end.</p>
                        </div>
                      </div>
                    </div>
                  ))}
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
                  {saving ? 'Saving...' : 'Save Reciter'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

export default ReciterManager;
