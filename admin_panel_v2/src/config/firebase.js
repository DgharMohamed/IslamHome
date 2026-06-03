import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDSI07_KHizsXPBh7YZ2bLq7py_4GaIyfg",
  appId: "1:925917165008:web:007dfbcc4dbfd9238335d5",
  messagingSenderId: "925917165008",
  projectId: "islam-home-official",
  authDomain: "islam-home-official.firebaseapp.com",
  storageBucket: "islam-home-official.firebasestorage.app",
  measurementId: "G-3JLNXTT3XQ"
};

const app = initializeApp(firebaseConfig);

export const auth = getAuth(app);
export const db = getFirestore(app);
