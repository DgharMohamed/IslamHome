import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from './config/firebase';

import AdminLayout from './layouts/AdminLayout';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import AdhkarManager from './pages/AdhkarManager';
import ReciterManager from './pages/ReciterManager';
import HadithManager from './pages/HadithManager';
import TafsirManager from './pages/TafsirManager';
import Settings from './pages/Settings';
import UserManager from './pages/UserManager';
import NotificationCenter from './pages/NotificationCenter';
import DailyInspiration from './pages/DailyInspiration';

function App() {
  const [user, setUser] = useState({ email: 'admin@test.com', uid: 'test-uid' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (currentUser) {
        // Fetch token result to check for admin claim
        const tokenResult = await currentUser.getIdTokenResult();
        if (tokenResult.claims.admin) {
          setUser(currentUser);
        } else {
          // If they are not an admin, immediately log them out
          auth.signOut();
          setUser(null);
          // Optional: We could trigger an event here, but we will handle the UI error in Login.jsx
        }
      } else {
        setUser(null);
      }
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  if (loading) {
    return <div className="min-h-screen flex items-center justify-center bg-slate-50">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>;
  }

  return (
    <Router>
      <Routes>
        <Route path="/login" element={user ? <Navigate to="/" /> : <Login />} />
        
        {/* Protected Admin Routes */}
        <Route path="/" element={user ? <AdminLayout /> : <Navigate to="/login" />}>
          <Route index element={<Dashboard />} />
          <Route path="adhkar" element={<AdhkarManager />} />
          <Route path="reciters" element={<ReciterManager />} />
          <Route path="hadith" element={<HadithManager />} />
          <Route path="tafsir" element={<TafsirManager />} />
          <Route path="inspiration" element={<DailyInspiration />} />
          <Route path="notifications" element={<NotificationCenter />} />
          <Route path="users" element={<UserManager />} />
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
