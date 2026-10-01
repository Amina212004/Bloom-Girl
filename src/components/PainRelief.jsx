import React, { useState, useEffect } from 'react';
import { Heart, ShieldAlert, Thermometer, Wind, Sparkles, Coffee } from 'lucide-react';

export default function PainRelief() {
  const [breathingState, setBreathingState] = useState('Inspire...');
  const [isBreathingActive, setIsBreathingActive] = useState(false);
  const [circleScale, setCircleScale] = useState(1);

  useEffect(() => {
    let interval;
    if (isBreathingActive) {
      let step = 0;
      interval = setInterval(() => {
        step = (step + 1) % 3;
        if (step === 0) {
          setBreathingState('Inspire doucement... 🌸');
          setCircleScale(1.35);
        } else if (step === 1) {
          setBreathingState('Maintiens la respiration... 💖');
          setCircleScale(1.35);
        } else {
          setBreathingState('Expire lentement... 🌬️');
          setCircleScale(1);
        }
      }, 4000);
    } else {
      setBreathingState('Touche pour démarrer 🌸');
      setCircleScale(1);
    }
    return () => clearInterval(interval);
  }, [isBreathingActive]);

  const reliefTips = [
    {
      icon: <Thermometer size={22} color="#FF85A1" />,
      title: "La Bouillotte Chaude 🧺",
      text: "Applique une bouillotte tiède sur le bas du ventre ou le bas du dos pendant 15-20 minutes. La chaleur détend immédiatement les muscles de l'utérus."
    },
    {
      icon: <Coffee size={22} color="#FF85A1" />,
      title: "Tisane Apaisante 🫖",
      text: "Prépare une infusion à la camomille, à la menthe poivrée ou au gingembre chaud. Évite les boissons gazeuses et trop glacées."
    },
    {
      icon: <Heart size={22} color="#FF85A1" />,
      title: "Position Fœtale Réconfortante 🧘‍♀️",
      text: "Allonge-toi sur le côté, ramène tes genoux vers ta poitrine et glisse un coussin moelleux entre tes jambes."
    }
  ];

  return (
    <div className="tab-content">
      {/* Banner */}
      <div className="card-rose" style={{ background: 'linear-gradient(135deg, #FFF0F5, #FFE5EC)', borderLeft: '4px solid #FF85A1' }}>
        <h3 style={{ fontSize: '16px', color: '#702632', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Heart size={20} color="#FF85A1" />
          <span>Espace SOS Douleurs & Bien-être</span>
        </h3>
        <p style={{ fontSize: '13px', color: '#995566', marginTop: '4px' }}>
          Ne reste pas seule avec tes douleurs. Voici des exercices simples et naturels pour te soulager rapidement. 💕
        </p>
      </div>

      {/* Breathing Exercise Card */}
      <div className="card-rose" style={{ textAlign: 'center', padding: '24px 16px' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px', color: '#D47A8A', fontWeight: 'bold', fontSize: '13px', marginBottom: '14px' }}>
          <Wind size={18} />
          <span>EXERCICE DE RESPIRATION APAISANTE (4-4-4)</span>
        </div>

        {/* Animated Circle */}
        <div
          onClick={() => setIsBreathingActive(!isBreathingActive)}
          style={{
            width: '140px',
            height: '140px',
            margin: '0 auto 16px auto',
            borderRadius: '50%',
            background: 'linear-gradient(135deg, #FF85A1, #FFB3C6)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: 'white',
            fontWeight: 'bold',
            fontSize: '13px',
            cursor: 'pointer',
            boxShadow: '0 10px 30px rgba(255, 133, 161, 0.4)',
            transform: `scale(${circleScale})`,
            transition: 'transform 3.8s ease-in-out',
            padding: '12px'
          }}
        >
          {breathingState}
        </div>

        <button
          onClick={() => setIsBreathingActive(!isBreathingActive)}
          style={{
            background: isBreathingActive ? '#702632' : '#FF85A1',
            color: 'white',
            border: 'none',
            borderRadius: '20px',
            padding: '8px 20px',
            fontSize: '13px',
            fontWeight: 'bold',
            cursor: 'pointer'
          }}
        >
          {isBreathingActive ? 'Arrêter la respiration' : 'Démarrer l\'exercice 🌸'}
        </button>
      </div>

      {/* Natural Tips */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
        <h3 style={{ fontSize: '15px', color: '#702632', paddingLeft: '4px' }}>
          Astuces naturelles anti-crampes
        </h3>
        {reliefTips.map((tip, index) => (
          <div key={index} className="card-rose" style={{ display: 'flex', gap: '14px', alignItems: 'flex-start' }}>
            <div style={{ background: '#FFE5EC', padding: '10px', borderRadius: '16px' }}>
              {tip.icon}
            </div>
            <div>
              <h4 style={{ fontSize: '14.5px', color: '#702632' }}>{tip.title}</h4>
              <p style={{ fontSize: '13px', color: '#995566', marginTop: '4px', lineHeight: '1.4' }}>
                {tip.text}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
