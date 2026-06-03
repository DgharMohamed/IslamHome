import { Outlet, Link, useNavigate, useLocation } from 'react-router-dom';
import { signOut } from 'firebase/auth';
import { auth } from '../config/firebase';
import { LayoutDashboard, BookOpen, Settings, LogOut, Menu, Mic, Book, Languages, Users, Bell, Sparkles } from 'lucide-react';
import { useState } from 'react';

const AdminLayout = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const handleLogout = async () => {
    try {
      await signOut(auth);
      navigate('/login');
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  const navItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Adhkar Content', path: '/adhkar', icon: BookOpen },
    { name: 'Reciters', path: '/reciters', icon: Mic },
    { name: 'Hadith', path: '/hadith', icon: Book },
    { name: 'Tafsir', path: '/tafsir', icon: Languages },
    { name: 'Inspiration Pool', path: '/inspiration', icon: Sparkles },
    { name: 'Push Notifications', path: '/notifications', icon: Bell },
    { name: 'Users', path: '/users', icon: Users },
    { name: 'Settings', path: '/settings', icon: Settings },
  ];

  return (
    <div className="flex h-screen bg-slate-50 overflow-hidden">
      {/* Mobile Sidebar Overlay */}
      {sidebarOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/50 z-20 md:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`fixed inset-y-0 left-0 z-30 w-64 bg-white border-r border-slate-200 transform transition-transform duration-300 ease-in-out md:static md:translate-x-0 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="flex items-center justify-center h-16 border-b border-slate-200 px-6">
          <h1 className="text-xl font-bold bg-gradient-to-r from-primary-600 to-islamic-gold bg-clip-text text-transparent">
            IslamHome Admin
          </h1>
        </div>
        
        <div className="p-4 overflow-y-auto h-[calc(100vh-4rem)]">
          <ul className="space-y-2">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.path;
              return (
                <li key={item.path}>
                  <Link
                    to={item.path}
                    className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                      isActive 
                        ? 'bg-primary-50 text-primary-600 font-medium' 
                        : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                    }`}
                  >
                    <Icon className="w-5 h-5" />
                    {item.name}
                  </Link>
                </li>
              );
            })}
          </ul>

          <div className="mt-8 pt-8 border-t border-slate-200">
            <button
              onClick={handleLogout}
              className="flex items-center gap-3 w-full px-4 py-3 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            >
              <LogOut className="w-5 h-5" />
              Logout
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden w-full relative">
        <header className="h-16 bg-white border-b border-slate-200 flex items-center px-4 md:px-8 justify-between z-10 relative">
          <button 
            className="md:hidden p-2 text-slate-600 hover:bg-slate-50 rounded-lg"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="w-6 h-6" />
          </button>
          
          <div className="flex-1"></div>
          
          <div className="flex items-center gap-4">
            <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-primary-700 font-bold">
              A
            </div>
            <span className="hidden sm:block text-sm font-medium text-slate-700">Admin User</span>
          </div>
        </header>

        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-slate-50 p-4 md:p-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
};

export default AdminLayout;
