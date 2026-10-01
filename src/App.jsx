import React, { useState } from 'react';
import { MessageCircle, Calendar, Heart, Sparkles, Wind } from 'lucide-react';
import ChatLily from './components/ChatLily';
import TimeOrganizer from './components/TimeOrganizer';
import CycleTracker from './components/CycleTracker';
import PainRelief from './components/PainRelief';

export default function App() {
  const [activeTab, setActiveTab] = useState('chat');

  return (
    <div className="mobile-container">
      {/* Header */}
      <header className="app-header">
        <div className="header-title">
          <div className="logo-badge">🌸</div>
          <div className="header-text">
            <h1>Bloom Rose</h1>
            <p>Ton espace bien-être & organisation</p>
          </div>
        </div>
        <div style={{
          background: '#FFE5EC',
          color: '#FF85A1',
          padding: '6px 12px',
          borderRadius: '16px',
          fontSize: '11px',
          fontWeight: 'bold',
          display: 'flex',
          alignItems: 'center',
          gap: '4px'
        }}>
          <Sparkles size={12} />
          <span>Mode Rose</span>
        </div>
      </header>

      {/* Main Content Area */}
      <main style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
        {activeTab === 'chat' && <ChatLily />}
        {activeTab === 'organizer' && <TimeOrganizer />}
        {activeTab === 'cycle' && <CycleTracker />}
        {activeTab === 'pain' && <PainRelief />}
      </main>

      {/* Bottom Navigation Bar */}
      <nav className="bottom-nav">
        <button
          className={`nav-item ${activeTab === 'chat' ? 'active' : ''}`}
          onClick={() => setActiveTab('chat')}
        >
          <MessageCircle size={20} />
          <span>Lily Chat</span>
        </button>

        <button
          className={`nav-item ${activeTab === 'organizer' ? 'active' : ''}`}
          onClick={() => setActiveTab('organizer')}
        >
          <Calendar size={20} />
          <span>Mon Temps</span>
        </button>

        <button
          className={`nav-item ${activeTab === 'cycle' ? 'active' : ''}`}
          onClick={() => setActiveTab('cycle')}
        >
          <Heart size={20} />
          <span>Mon Cycle</span>
        </button>

        <button
          className={`nav-item ${activeTab === 'pain' ? 'active' : ''}`}
          onClick={() => setActiveTab('pain')}
        >
          <Wind size={20} />
          <span>SOS Douleur</span>
        </button>
      </nav>
    </div>
  );
}
