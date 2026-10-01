import React, { useState } from 'react';
import { Calendar, CheckCircle2, Circle, Plus, Droplets, Smile, Sparkles, Heart } from 'lucide-react';

export default function TimeOrganizer() {
  const [selectedMood, setSelectedMood] = useState('🌸 Ravissante');
  const [waterCups, setWaterCups] = useState(4);
  const [newTask, setNewTask] = useState('');
  const [tasks, setTasks] = useState([
    { id: 1, text: '📚 Réviser les cours (30 min)', category: 'Études', completed: true },
    { id: 2, text: '💧 Boire 1.5L d\'eau fraîche', category: 'Santé', completed: false },
    { id: 3, text: '💆‍♀️ Pause Skincare & Hydratation', category: 'Soin', completed: true },
    { id: 4, text: '🧘‍♀️ 10 min de méditation ou étirements', category: 'Détente', completed: false },
    { id: 5, text: '🛌 Se coucher avant 22h30', category: 'Sommeil', completed: false }
  ]);

  const moods = [
    { emoji: '🌸', name: 'Ravissante' },
    { emoji: '💖', name: 'Motivée' },
    { emoji: '😴', name: 'Fatiguée' },
    { emoji: '🩹', name: 'Douleurs' },
    { emoji: '☁️', name: 'Sensible' }
  ];

  const toggleTask = (id) => {
    setTasks(tasks.map(t => t.id === id ? { ...t, completed: !t.completed } : t));
  };

  const handleAddTask = (e) => {
    e.preventDefault();
    if (!newTask.trim()) return;
    setTasks([...tasks, { id: Date.now(), text: `✨ ${newTask}`, category: 'Perso', completed: false }]);
    setNewTask('');
  };

  const completedCount = tasks.filter(t => t.completed).length;
  const progressPercent = Math.round((completedCount / tasks.length) * 100);

  return (
    <div className="tab-content">
      {/* Citation du Jour */}
      <div className="card-rose" style={{ background: 'linear-gradient(135deg, #FFF0F5, #FFE5EC)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: '#D47A8A', fontWeight: 'bold', fontSize: '13px' }}>
          <Sparkles size={16} />
          <span>PENSÉE D'AMOUR DU JOUR</span>
        </div>
        <p style={{ fontSize: '14.5px', marginTop: '6px', fontStyle: 'italic', color: '#702632' }}>
          "Chaque jour est une nouvelle opportunité de fleurir à ton propre rythme. Prends soin de toi ! ✨"
        </p>
      </div>

      {/* Mood Tracker */}
      <div className="card-rose">
        <h3 style={{ fontSize: '15px', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Smile size={18} color="#FF85A1" />
          <span>Ton Humeur du Jour</span>
        </h3>
        <div className="mood-selector">
          {moods.map((m, index) => {
            const label = `${m.emoji} ${m.name}`;
            const isSel = selectedMood === label;
            return (
              <button
                key={index}
                className={`mood-chip ${isSel ? 'selected' : ''}`}
                onClick={() => setSelectedMood(label)}
              >
                {label}
              </button>
            );
          })}
        </div>
      </div>

      {/* Hydratation Tracker */}
      <div className="card-rose" style={{ background: 'linear-gradient(135deg, #EBF8FF, #FFF9FA)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <h3 style={{ fontSize: '15px', color: '#2B6CB0', display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Droplets size={18} color="#3182CE" />
              <span>Objectif Hydratation (1.5L)</span>
            </h3>
            <p style={{ fontSize: '12px', color: '#4A5568', marginTop: '2px' }}>
              {waterCups} / 8 verres d'eau servis
            </p>
          </div>
          <button
            onClick={() => setWaterCups(prev => Math.min(8, prev + 1))}
            style={{
              background: '#3182CE',
              color: 'white',
              border: 'none',
              borderRadius: '16px',
              padding: '8px 14px',
              fontSize: '13px',
              fontWeight: 'bold',
              cursor: 'pointer',
              boxShadow: '0 4px 10px rgba(49, 130, 206, 0.3)'
            }}
          >
            +1 Verre 💧
          </button>
        </div>
      </div>

      {/* Tasks & Routine Organizer */}
      <div className="card-rose">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <h3 style={{ fontSize: '16px', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Calendar size={18} color="#FF85A1" />
            <span>Mon Programme du Jour</span>
          </h3>
          <span style={{ fontSize: '12px', background: '#FFE5EC', color: '#FF85A1', padding: '4px 10px', borderRadius: '12px', fontWeight: 'bold' }}>
            {progressPercent}% Fait
          </span>
        </div>

        {/* Progress Bar */}
        <div style={{ width: '100%', height: '8px', background: '#FFE5EC', borderRadius: '4px', overflow: 'hidden', marginBottom: '14px' }}>
          <div style={{ width: `${progressPercent}%`, height: '100%', background: 'linear-gradient(90deg, #FF85A1, #FFB3C6)', transition: 'width 0.4s ease' }} />
        </div>

        {/* Tasks List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
          {tasks.map(task => (
            <div
              key={task.id}
              onClick={() => toggleTask(task.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '10px',
                padding: '10px 12px',
                borderRadius: '16px',
                background: task.completed ? '#FFF0F5' : 'white',
                border: '1px solid #FFE5EC',
                cursor: 'pointer',
                transition: 'all 0.2s ease'
              }}
            >
              {task.completed ? (
                <CheckCircle2 size={20} color="#FF85A1" />
              ) : (
                <Circle size={20} color="#FFB3C6" />
              )}
              <span style={{
                fontSize: '14px',
                textDecoration: task.completed ? 'line-through' : 'none',
                color: task.completed ? '#B07080' : '#702632',
                flex: 1
              }}>
                {task.text}
              </span>
            </div>
          ))}
        </div>

        {/* Add Task Input */}
        <form onSubmit={handleAddTask} style={{ display: 'flex', gap: '8px', marginTop: '14px' }}>
          <input
            type="text"
            className="chat-input"
            placeholder="Ajouter une activité ou soin..."
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            style={{ fontSize: '13px', padding: '8px 14px' }}
          />
          <button
            type="submit"
            style={{
              background: '#FF85A1',
              color: 'white',
              border: 'none',
              borderRadius: '20px',
              padding: '0 16px',
              cursor: 'pointer'
            }}
          >
            <Plus size={18} />
          </button>
        </form>
      </div>
    </div>
  );
}
