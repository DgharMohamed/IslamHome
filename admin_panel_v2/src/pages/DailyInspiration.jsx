import { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp } from 'firebase/firestore';
import { db } from '../config/firebase';
import { Sparkles, Plus, Trash2, Edit2, Loader2, BookOpen, Save, X } from 'lucide-react';

const DailyInspiration = () => {
  const [verses, setVerses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isEditing, setIsEditing] = useState(false);
  const [currentVerse, setCurrentVerse] = useState({ text: '', surah: '', translation: '' });
  const [editId, setEditId] = useState(null);

  useEffect(() => {
    fetchVerses();
  }, []);

  const fetchVerses = async () => {
    try {
      setLoading(true);
      const snapshot = await getDocs(collection(db, 'daily_verses'));
      const items = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setVerses(items);
    } catch (error) {
      console.error('Error fetching verses:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!currentVerse.text || !currentVerse.surah) return;

    try {
      if (editId) {
        await updateDoc(doc(db, 'daily_verses', editId), {
          ...currentVerse,
          updatedAt: serverTimestamp()
        });
      } else {
        await addDoc(collection(db, 'daily_verses'), {
          ...currentVerse,
          createdAt: serverTimestamp()
        });
      }
      
      setIsEditing(false);
      setEditId(null);
      setCurrentVerse({ text: '', surah: '', translation: '' });
      fetchVerses();
    } catch (error) {
      console.error('Error saving verse:', error);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Delete this verse from the rotation pool?')) {
      try {
        await deleteDoc(doc(db, 'daily_verses', id));
        fetchVerses();
      } catch (error) {
        console.error('Error deleting verse:', error);
      }
    }
  };

  const startEdit = (verse) => {
    setCurrentVerse({ text: verse.text, surah: verse.surah, translation: verse.translation });
    setEditId(verse.id);
    setIsEditing(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Daily Inspiration Pool</h1>
          <p className="text-slate-500 text-sm mt-1">Manage verses that appear on the app's home screen carousel.</p>
        </div>
        <button 
          onClick={() => {
            setIsEditing(true);
            setEditId(null);
            setCurrentVerse({ text: '', surah: '', translation: '' });
          }}
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-all shadow-md shadow-primary-200"
        >
          <Plus className="w-5 h-5" />
          Add New Verse
        </button>
      </div>

      {isEditing && (
        <div className="bg-white rounded-2xl border border-primary-100 shadow-xl p-6 relative overflow-hidden ring-1 ring-primary-50">
          <div className="absolute top-0 right-0 p-4">
            <button onClick={() => setIsEditing(false)} className="text-slate-400 hover:text-slate-600 p-1">
              <X className="w-5 h-5" />
            </button>
          </div>
          <h2 className="text-lg font-bold text-slate-900 mb-6 flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-islamic-gold" />
            {editId ? 'Edit Verse' : 'New Inspiration Verse'}
          </h2>
          
          <form onSubmit={handleSave} className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Verse (Arabic)</label>
                <textarea 
                  dir="rtl"
                  rows={3}
                  required
                  placeholder="أدخل الآية الكريمة..."
                  value={currentVerse.text}
                  onChange={(e) => setCurrentVerse({...currentVerse, text: e.target.value})}
                  className="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none text-xl font-amiri leading-relaxed"
                />
              </div>
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Reference (Surah & Ayah)</label>
                <input 
                  type="text" 
                  required
                  placeholder="e.g., سورة البقرة - ٣٢"
                  value={currentVerse.surah}
                  onChange={(e) => setCurrentVerse({...currentVerse, surah: e.target.value})}
                  className="w-full p-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none"
                />
              </div>
            </div>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-semibold text-slate-700 mb-1.5">Translation (English)</label>
                <textarea 
                  rows={6}
                  placeholder="English translation..."
                  value={currentVerse.translation}
                  onChange={(e) => setCurrentVerse({...currentVerse, translation: e.target.value})}
                  className="w-full p-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none"
                />
              </div>
              <div className="flex justify-end gap-3 pt-2">
                <button 
                  type="button"
                  onClick={() => setIsEditing(false)}
                  className="px-6 py-2.5 text-slate-600 font-medium hover:bg-slate-100 rounded-xl transition-all"
                >
                  Cancel
                </button>
                <button 
                  type="submit"
                  className="px-8 py-2.5 bg-primary-600 text-white font-bold rounded-xl hover:bg-primary-700 transition-all shadow-lg shadow-primary-100 flex items-center gap-2"
                >
                  <Save className="w-5 h-5" />
                  Save to Pool
                </button>
              </div>
            </div>
          </form>
        </div>
      )}

      {loading ? (
        <div className="p-20 flex flex-col items-center justify-center text-slate-400">
          <Loader2 className="w-8 h-8 animate-spin mb-4 text-primary-500" />
          <p>Loading inspiration pool...</p>
        </div>
      ) : verses.length === 0 ? (
        <div className="p-20 bg-white rounded-2xl border-2 border-dashed border-slate-200 text-center text-slate-400">
          <BookOpen className="w-12 h-12 mx-auto mb-4 opacity-20" />
          <p className="text-lg font-medium">No verses in the inspiration pool</p>
          <p>Add verses to make the app's home screen dynamic.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {verses.map((verse) => (
            <div key={verse.id} className="bg-white rounded-2xl border border-slate-200 shadow-sm hover:shadow-md transition-all group overflow-hidden">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div className="w-8 h-8 rounded-lg bg-islamic-gold/10 flex items-center justify-center text-islamic-gold">
                    <Sparkles className="w-4 h-4" />
                  </div>
                  <div className="flex gap-1">
                    <button 
                      onClick={() => startEdit(verse)}
                      className="p-2 text-slate-400 hover:text-primary-600 hover:bg-primary-50 rounded-lg transition-all"
                    >
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button 
                      onClick={() => handleDelete(verse.id)}
                      className="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
                <blockquote className="space-y-4">
                  <p className="text-xl font-amiri text-slate-900 leading-relaxed text-right line-clamp-3">
                    {verse.text}
                  </p>
                  <footer className="text-xs font-bold text-slate-400 flex items-center gap-2">
                    <span className="w-8 h-px bg-slate-100"></span>
                    {verse.surah}
                  </footer>
                  <p className="text-sm text-slate-500 italic line-clamp-2">
                    "{verse.translation}"
                  </p>
                </blockquote>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default DailyInspiration;
