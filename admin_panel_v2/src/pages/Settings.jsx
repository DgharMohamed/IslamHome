import { Save, Shield, Bell, Globe, LogOut, ChevronRight, Settings as SettingsIcon } from 'lucide-react';
import { collection, doc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '../config/firebase';
import { useEffect } from 'react';
import { auth } from '../config/firebase';
import { signOut } from 'firebase/auth';

const Settings = () => {
  const [activeTab, setActiveTab] = useState('general');
  const [saving, setSaving] = useState(false);
  
  const handleLogout = async () => {
    if (window.confirm('Are you sure you want to log out?')) {
      await signOut(auth);
    }
  };

  const tabs = [
    { id: 'general', name: 'General Settings', icon: Globe },
    { id: 'security', name: 'Security & Access', icon: Shield },
    { id: 'notifications', name: 'Notifications', icon: Bell },
    { id: 'system', name: 'System Management', icon: SettingsIcon },
  ];

  const [systemConfig, setSystemConfig] = useState({
    maintenanceMode: false,
    minAppVersion: '1.0.0',
    featuredVerseId: ''
  });

  useEffect(() => {
    const fetchConfig = async () => {
      const docRef = doc(db, 'system', 'config');
      const docSnap = await getDoc(docRef);
      if (docSnap.exists()) {
        setSystemConfig(docSnap.data());
      }
    };
    fetchConfig();
  }, []);

  const handleSaveSystem = async () => {
    setSaving(true);
    try {
      await setDoc(doc(db, 'system', 'config'), systemConfig);
      alert('System configuration updated successfully!');
    } catch (error) {
      console.error('Error updating system config:', error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Admin Settings</h1>
          <p className="text-slate-500 text-sm mt-1">Configure system preferences and administrative controls.</p>
        </div>
        <button 
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors shadow-sm disabled:opacity-50"
          onClick={() => {
            setSaving(true);
            setTimeout(() => setSaving(false), 1000);
          }}
          disabled={saving}
        >
          <Save className="w-5 h-5" />
          {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>

      <div className="flex flex-col lg:flex-row gap-8">
        {/* Sidebar Tabs */}
        <div className="w-full lg:w-64 space-y-1">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium transition-all ${
                  activeTab === tab.id 
                    ? 'bg-white text-primary-600 shadow-sm border border-slate-200' 
                    : 'text-slate-600 hover:bg-slate-100'
                }`}
              >
                <Icon className={`w-5 h-5 ${activeTab === tab.id ? 'text-primary-600' : 'text-slate-400'}`} />
                {tab.name}
              </button>
            );
          })}
          <div className="pt-4 mt-4 border-t border-slate-200">
            <button
              onClick={handleLogout}
              className="w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-medium text-red-600 hover:bg-red-50 transition-all"
            >
              <LogOut className="w-5 h-5" />
              Logout from Admin
            </button>
          </div>
        </div>

        {/* Content Area */}
        <div className="flex-1 space-y-6">
          <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
            <div className="p-6 border-b border-slate-200">
              <h2 className="text-lg font-bold text-slate-900 capitalize">
                {activeTab.replace('_', ' ')}
              </h2>
            </div>
            
            <div className="p-6 space-y-6">
              {activeTab === 'general' && (
                <div className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1.5">App Name</label>
                      <input 
                        type="text" 
                        defaultValue="IslamHome"
                        className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-slate-700 mb-1.5">Support Email</label>
                      <input 
                        type="email" 
                        defaultValue="support@islamhome.com"
                        className="w-full p-2.5 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                      />
                    </div>
                  </div>
                  
                  <div>
                    <label className="block text-sm font-medium text-slate-700 mb-1.5">App Description</label>
                    <textarea 
                      rows={4}
                      defaultValue="Mobile application for daily Islamic content, Quran, and Adhkar."
                      className="w-full p-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-primary-500 outline-none"
                    />
                  </div>
                </div>
              )}

              {activeTab === 'security' && (
                <div className="space-y-6">
                  <div className="flex items-center justify-between p-4 bg-slate-50 rounded-xl border border-slate-200">
                    <div>
                      <h3 className="font-medium text-slate-900">Two-Factor Authentication</h3>
                      <p className="text-xs text-slate-500">Security layer for admin access.</p>
                    </div>
                    <div className="relative inline-block w-12 h-6 rounded-full bg-slate-200">
                      <div className="absolute left-1 top-1 w-4 h-4 rounded-full bg-white transition-all transform translate-x-0"></div>
                    </div>
                  </div>

                  <div className="p-4 bg-blue-50 text-blue-800 rounded-xl text-sm italic">
                    Administrative security policies are managed directly via Firebase Console for this environment.
                  </div>
                </div>
              )}

              {activeTab === 'notifications' && (
                <div className="space-y-6">
                  <div className="p-6 bg-indigo-50 rounded-2xl border border-indigo-100">
                    <h3 className="font-bold text-indigo-900 mb-2">Notification Center</h3>
                    <p className="text-sm text-indigo-700 leading-relaxed mb-4">
                      Global push notifications are managed via the dedicated Notification Center page.
                    </p>
                    <button 
                      onClick={() => navigate('/notifications')}
                      className="px-4 py-2 bg-indigo-600 text-white rounded-xl text-sm font-medium hover:bg-indigo-700 transition-colors"
                    >
                      Go to Notification Center
                    </button>
                  </div>
                </div>
              )}

              {activeTab === 'system' && (
                <div className="space-y-8">
                  <div className="flex items-center justify-between p-5 bg-amber-50 rounded-2xl border border-amber-100">
                    <div className="space-y-1">
                      <h3 className="font-bold text-amber-900">Maintenance Mode</h3>
                      <p className="text-sm text-amber-700/70 leading-relaxed">
                        Enabling this will prevent users from accessing the app. 
                        They will see a "Service Temporarily Unavailable" screen.
                      </p>
                    </div>
                    <button 
                      onClick={() => setSystemConfig({...systemConfig, maintenanceMode: !systemConfig.maintenanceMode})}
                      className={`relative inline-flex h-7 w-14 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                        systemConfig.maintenanceMode ? 'bg-amber-600' : 'bg-slate-200'
                      }`}
                    >
                      <span className={`pointer-events-none inline-block h-6 w-6 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                        systemConfig.maintenanceMode ? 'translate-x-7' : 'translate-x-0'
                      }`} />
                    </button>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="space-y-1.5">
                      <label className="text-sm font-semibold text-slate-700">Minimum Supported Version</label>
                      <input 
                        type="text" 
                        value={systemConfig.minAppVersion}
                        onChange={(e) => setSystemConfig({...systemConfig, minAppVersion: e.target.value})}
                        className="w-full p-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none"
                      />
                    </div>
                    <div className="space-y-1.5">
                      <label className="text-sm font-semibold text-slate-700">Featured Verse Collection</label>
                      <select 
                        value={systemConfig.featuredVerseId}
                        onChange={(e) => setSystemConfig({...systemConfig, featuredVerseId: e.target.value})}
                        className="w-full p-2.5 border border-slate-200 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none"
                      >
                        <option value="pool_1"> Ramadan Special Pool </option>
                        <option value="pool_2"> Daily Essentials </option>
                      </select>
                    </div>
                  </div>

                  <div className="pt-2">
                    <button 
                      onClick={handleSaveSystem}
                      disabled={saving}
                      className="bg-slate-900 text-white font-bold px-6 py-3 rounded-xl hover:bg-slate-800 transition-all flex items-center gap-2"
                    >
                      <Save className="w-5 h-5" />
                      Apply System Config
                    </button>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
