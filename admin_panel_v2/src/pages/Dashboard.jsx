import { Users, BookOpen, Clock, Activity } from 'lucide-react';
import { useState, useEffect } from 'react';
import { collection, getCountFromServer, getDocs, query, orderBy, limit } from 'firebase/firestore';
import { db } from '../config/firebase';
import { 
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer 
} from 'recharts';

const Dashboard = () => {
  const [userCount, setUserCount] = useState('...');
  const [adhkarCount, setAdhkarCount] = useState('...');
  const [chartData, setChartData] = useState([]);

  useEffect(() => {
    const fetchCounts = async () => {
      try {
        const userSnapshot = await getCountFromServer(collection(db, 'users'));
        setUserCount(userSnapshot.data().count.toLocaleString());

        const adhkarSnapshot = await getCountFromServer(collection(db, 'adhkar'));
        setAdhkarCount(adhkarSnapshot.data().count.toLocaleString());

        // Simulated Chart Data (In a real app, this would query registrations per day)
        setChartData([
          { date: 'Apr 15', users: 120 },
          { date: 'Apr 16', users: 150 },
          { date: 'Apr 17', users: 300 },
          { date: 'Apr 18', users: 200 },
          { date: 'Apr 19', users: 450 },
          { date: 'Apr 20', users: 400 },
          { date: 'Apr 21', users: 600 },
        ]);
      } catch (error) {
        console.error('Error fetching dashboard counts:', error);
      }
    };
    fetchCounts();
  }, []);

  const stats = [
    { name: 'Total Users', value: userCount, change: '+12%', icon: Users, color: 'bg-blue-100 text-blue-600' },
    { name: 'Active Adhkar', value: adhkarCount, change: '+3', icon: BookOpen, color: 'bg-emerald-100 text-emerald-600' },
    { name: 'Sessions Today', value: '8,234', change: '+24%', icon: Activity, color: 'bg-purple-100 text-purple-600' },
    { name: 'Avg. Time', value: '14m', change: '-1m', icon: Clock, color: 'bg-amber-100 text-amber-600' },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Dashboard Overview</h1>
          <p className="text-slate-500 text-sm mt-1">Welcome back, Admin. Here's what's happening today.</p>
        </div>
        <div className="flex bg-white rounded-lg p-1 border border-slate-200">
          <button className="px-4 py-1.5 text-sm font-medium rounded-md bg-slate-100 text-slate-900 shadow-sm">Today</button>
          <button className="px-4 py-1.5 text-sm font-medium rounded-md text-slate-600 hover:text-slate-900">7 Days</button>
          <button className="px-4 py-1.5 text-sm font-medium rounded-md text-slate-600 hover:text-slate-900">30 Days</button>
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div key={stat.name} className="bg-white rounded-xl p-6 border border-slate-200 shadow-sm hover:shadow-md transition-shadow">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-sm font-medium text-slate-500 mb-1">{stat.name}</p>
                  <h3 className="text-3xl font-bold text-slate-900">{stat.value}</h3>
                </div>
                <div className={`p-3 rounded-lg ${stat.color}`}>
                  <Icon className="w-6 h-6" />
                </div>
              </div>
              <div className="mt-4 flex items-center">
                <span className={`text-sm font-medium ${stat.change.startsWith('+') ? 'text-emerald-600' : 'text-red-600'}`}>
                  {stat.change}
                </span>
                <span className="text-sm text-slate-500 ml-2">from last month</span>
              </div>
            </div>
          );
        })}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-lg font-bold text-slate-900">User Registrations</h2>
              <p className="text-sm text-slate-500">New signups over the last 7 days</p>
            </div>
            <div className="flex items-center gap-2 text-emerald-600 font-medium text-sm bg-emerald-50 px-3 py-1 rounded-full">
              <Activity className="w-4 h-4" />
              +24% Increase
            </div>
          </div>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0ea5e9" stopOpacity={0.1}/>
                    <stop offset="95%" stopColor="#0ea5e9" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                <XAxis 
                  dataKey="date" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{fill: '#64748b', fontSize: 12}} 
                  dy={10}
                />
                <YAxis 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{fill: '#64748b', fontSize: 12}} 
                />
                <Tooltip 
                  contentStyle={{borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)'}}
                />
                <Area 
                  type="monotone" 
                  dataKey="users" 
                  stroke="#0ea5e9" 
                  strokeWidth={3}
                  fillOpacity={1} 
                  fill="url(#colorUsers)" 
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
          <h2 className="text-lg font-bold text-slate-900 mb-4">Quick Actions</h2>
          <div className="space-y-3">
            <button className="w-full flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-primary-500 hover:bg-primary-50 transition-all group">
              <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600">
                <Bell className="w-5 h-5" />
              </div>
              <div className="text-left">
                <p className="font-semibold text-slate-900 text-sm">Send Notification</p>
                <p className="text-xs text-slate-500">Alert all users instantly</p>
              </div>
            </button>
            <button className="w-full flex items-center gap-3 p-3 rounded-xl border border-slate-100 hover:border-emerald-100 hover:bg-emerald-50 transition-all group">
              <div className="w-10 h-10 rounded-lg bg-emerald-100 flex items-center justify-center text-emerald-600">
                <Sparkles className="w-5 h-5" />
              </div>
              <div className="text-left">
                <p className="font-semibold text-slate-900 text-sm">New Verse</p>
                <p className="text-xs text-slate-500">Add to inspiration pool</p>
              </div>
            </button>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
          <h2 className="text-lg font-bold text-slate-900 mb-4">Recent Activity</h2>
          <div className="space-y-4">
            <div className="flex items-center gap-4 text-sm">
              <div className="w-2 h-2 rounded-full bg-emerald-500"></div>
              <p className="text-slate-900 flex-1">New user registered <span className="font-medium">Batman</span></p>
              <span className="text-slate-500">2 min ago</span>
            </div>
            <div className="flex items-center gap-4 text-sm">
              <div className="w-2 h-2 rounded-full bg-blue-500"></div>
              <p className="text-slate-900 flex-1">Updated Morning Adhkar content</p>
              <span className="text-slate-500">45 min ago</span>
            </div>
            <div className="flex items-center gap-4 text-sm">
              <div className="w-2 h-2 rounded-full bg-purple-500"></div>
              <p className="text-slate-900 flex-1">System backup completed successfully</p>
              <span className="text-slate-500">3 hours ago</span>
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
          <h2 className="text-lg font-bold text-slate-900 mb-4">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-4">
            <button className="p-4 rounded-xl border border-slate-200 hover:border-primary-500 hover:bg-primary-50 text-left transition-colors group">
              <BookOpen className="w-6 h-6 text-slate-400 group-hover:text-primary-600 mb-2" />
              <h3 className="font-medium text-slate-900">Add New Dhikr</h3>
              <p className="text-xs text-slate-500 mt-1">Create a new entry in the library</p>
            </button>
            <button className="p-4 rounded-xl border border-slate-200 hover:border-primary-500 hover:bg-primary-50 text-left transition-colors group">
              <Users className="w-6 h-6 text-slate-400 group-hover:text-primary-600 mb-2" />
              <h3 className="font-medium text-slate-900">Manage Users</h3>
              <p className="text-xs text-slate-500 mt-1">View and edit user accounts</p>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
