import React, { useState } from 'react';
import { HeartHandshake, Sparkles, Calendar, Activity, Check } from 'lucide-react';

export default function CycleTracker() {
  const [symptoms, setSymptoms] = useState([
    { id: 'cramps', name: 'Crampes légères 🩹', active: true },
    { id: 'fatigue', name: 'Fatigue / Envie de dodo 😴', active: true },
    { id: 'headache', name: 'Maux de tête 💆‍♀️', active: false },
    { id: 'bloating', name: 'Ventre gonflé ☁️', active: false },
    { id: 'cravings', name: 'Envie de chocolat 🍫', active: true },
    { id: 'acne', name: 'Petits boutons 🌸', active: false }
  ]);

  const toggleSymptom = (id) => {
    setSymptoms(symptoms.map(s => s.id === id ? { ...s, active: !s.active } : s));
  };

  return (
    <div className="tab-content">
      {/* Dynamic Status Card */}
      <div className="card-rose" style={{
        background: 'linear-gradient(135deg, #FF85A1, #FFB3C6)',
        color: 'white',
        textAlign: 'center',
        padding: '24px 18px',
        boxShadow: '0 10px 25px rgba(255, 133, 161, 0.4)'
      }}>
        <span style={{ fontSize: '12px', textTransform: 'uppercase', letterSpacing: '1px', opacity: 0.9, fontWeight: 'bold' }}>
          PROCHAINES RÈGLES ESTIMÉES
        </span>
        <h2 style={{ fontSize: '32px', fontWeight: '800', margin: '8px 0 4px 0' }}>
          Dans 6 jours 🌸
        </h2>
        <p style={{ fontSize: '13px', opacity: 0.95 }}>
          Date prévue : <strong>12 Septembre</strong> (Phase Lutéale)
        </p>

        <div style={{
          display: 'inline-flex',
          gap: '12px',
          background: 'rgba(255, 255, 255, 0.25)',
          backdropFilter: 'blur(8px)',
          padding: '8px 16px',
          borderRadius: '20px',
          marginTop: '14px',
          fontSize: '12.5px'
        }}>
          <span>Cycle moyen : <strong>28 jours</strong></span>
          <span>•</span>
          <span>Règles : <strong>5 jours</strong></span>
        </div>
      </div>

      {/* Mini Calendar View */}
      <div className="card-rose">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
          <h3 style={{ fontSize: '15px', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Calendar size={18} color="#FF85A1" />
            <span>Calendrier Mensuel (Septembre)</span>
          </h3>
        </div>

        {/* Days Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: '6px', textAlign: 'center', fontSize: '12px' }}>
          {['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day, i) => (
            <span key={i} style={{ color: '#B07080', fontWeight: 'bold', paddingBottom: '4px' }}>{day}</span>
          ))}
          {Array.from({ length: 30 }).map((_, index) => {
            const dayNum = index + 1;
            const isPeriod = dayNum >= 12 && dayNum <= 16;
            const isToday = dayNum === 6;

            return (
              <div
                key={dayNum}
                style={{
                  padding: '8px 0',
                  borderRadius: '12px',
                  fontSize: '13px',
                  fontWeight: isToday || isPeriod ? 'bold' : 'normal',
                  background: isToday
                    ? '#702632'
                    : isPeriod
                    ? '#FFE5EC'
                    : 'transparent',
                  color: isToday
                    ? 'white'
                    : isPeriod
                    ? '#FF85A1'
                    : '#702632',
                  border: isToday ? 'none' : isPeriod ? '1px solid #FFB3C6' : 'none'
                }}
              >
                {dayNum}
                {isPeriod && <div style={{ fontSize: '8px', lineHeight: 1 }}>🌸</div>}
              </div>
            );
          })}
        </div>
      </div>

      {/* Symptoms Checklist */}
      <div className="card-rose">
        <h3 style={{ fontSize: '15px', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Activity size={18} color="#FF85A1" />
          <span>Symptômes & Ressentis du jour</span>
        </h3>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
          {symptoms.map((symp) => (
            <button
              key={symp.id}
              onClick={() => toggleSymptom(symp.id)}
              className={`mood-chip ${symp.active ? 'selected' : ''}`}
            >
              {symp.active && <Check size={14} style={{ marginRight: '2px' }} />}
              {symp.name}
            </button>
          ))}
        </div>
      </div>

      {/* Gentle Care Advice */}
      <div className="card-rose" style={{ background: '#FFF9FA', borderLeft: '4px solid #FF85A1' }}>
        <h4 style={{ fontSize: '14px', color: '#702632', display: 'flex', alignItems: 'center', gap: '6px' }}>
          <Sparkles size={16} color="#FF85A1" />
          <span>Conseil Santé de Lily</span>
        </h4>
        <p style={{ fontSize: '13px', color: '#995566', marginTop: '4px', lineHeight: '1.4' }}>
          Pendant les quelques jours avant tes règles, ton corps a besoin de plus de magnésium et d'eau. N'hésite pas à manger une banane ou un carré de chocolat noir ! 🍫🌸
        </p>
      </div>
    </div>
  );
}
