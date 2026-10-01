import React, { useState, useRef, useEffect } from 'react';
import { Send, Heart, Sparkles, MessageCircle, RefreshCw } from 'lucide-react';

export default function ChatLily() {
  const [messages, setMessages] = useState([
    {
      id: 1,
      sender: 'bot',
      text: "Coucou ! 🌸 Je suis Lily, ta compagne virtuelle bienveillante. Comment te sens-tu aujourd'hui ? Tu peux tout me raconter : ton organisation, tes cours, ou si tu as des douleurs de règles ou de la fatigue. Je suis là pour toi ! 💕",
      time: '10:00'
    }
  ]);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const chatEndRef = useRef(null);

  const quickPrompts = [
    "🩹 J'ai mal au ventre (règles)",
    "🌸 Mes règles approchent",
    "📚 Aide-moi à m'organiser",
    "😴 Je me sens fatiguée",
    "✨ Donne-moi un conseil bien-être"
  ];

  const scrollToBottom = () => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages, isTyping]);

  const handleSend = (textToSend = input) => {
    const text = textToSend.trim();
    if (!text) return;

    const userMsg = {
      id: Date.now(),
      sender: 'user',
      text,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };

    setMessages(prev => [...prev, userMsg]);
    if (textToSend === input) setInput('');
    setIsTyping(true);

    // Simulation de réponse de Lily Rose adaptée aux besoins des jeunes filles
    setTimeout(() => {
      let botReply = getLilyResponse(text);

      const botMsg = {
        id: Date.now() + 1,
        sender: 'bot',
        text: botReply,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
      };

      setMessages(prev => [...prev, botMsg]);
      setIsTyping(false);
    }, 1200);
  };

  const getLilyResponse = (query) => {
    const q = query.toLowerCase();

    if (q.includes('mal au ventre') || q.includes('douleur') || q.includes('crampe') || q.includes('règle')) {
      return "Oh ma chérie, je comprends tellement... 🥺 Les douleurs de règles peuvent être vraiment fatigantes. Voici ce qui va te soulager rapidement :\n\n1. 🫖 Bois une tisane chaude à la camomille ou au gingembre.\n2. 🧺 Pose une bouillotte chaude sur le bas de ton ventre.\n3. 🧘‍♀️ Mets-toi en position fœtale (sur le côté) ou teste l'onglet 'SOS Douleurs' dans l'application !\nPrends du repos, tu es super forte ! 💖";
    }

    if (q.includes('organis') || q.includes('cours') || q.includes('devoir') || q.includes('temps')) {
      return "Pour bien organiser ta journée sans stress 📚✨ :\n- Commence par 1 seule tâche prioritaire (méthode des 25 minutes Pomodoro).\n- N'oublie pas de planifier tes moments de détente et de soin dans l'onglet 'Mon Temps'.\n- Célèbre chaque petite victoire ! Tu vas assurer 💪🌸";
    }

    if (q.includes('fatigué') || q.includes('dort') || q.includes('triste') || q.includes('stress')) {
      return "Repose-toi mon ange ☁️💖. C'est tout à fait normal d'avoir des baisses d'énergie, surtout pendant ton cycle. Bois un grand verre d'eau, écoute ta musique préférée et fais une petite sieste. Tu mérites de prendre soin de toi ! 🌸";
    }

    if (q.includes('conseil') || q.includes('beauté') || q.includes('soin')) {
      return "Mon petit conseil du jour 🌸 :\nFais un soin du visage doux, prends un bain tiède et écris 3 choses positives sur ta journée dans ton journal. Tu es magnifique et unique ! ✨";
    }

    return "Merci de partager ça avec moi 💕. N'oublie pas que je suis toujours là pour t'écouter, t'aider à organiser ta journée ou te donner des astuces pour ton bien-être et ton cycle menstruel. Que souhaites-tu faire maintenant ? 🌸";
  };

  return (
    <div className="chat-container">
      {/* Messages */}
      <div className="messages-list">
        {messages.map((msg) => (
          <div key={msg.id} className={`chat-bubble ${msg.sender}`}>
            <div style={{ whiteSpace: 'pre-line' }}>{msg.text}</div>
            <div style={{ fontSize: '10px', marginTop: '6px', opacity: 0.7, textAlign: 'right' }}>
              {msg.time}
            </div>
          </div>
        ))}

        {isTyping && (
          <div className="chat-bubble bot" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Sparkles className="pulse-rose" size={16} color="#FF85A1" />
            <span>Lily réfléchit avec amour... 🌸</span>
          </div>
        )}
        <div ref={chatEndRef} />
      </div>

      {/* Suggestion Chips */}
      <div className="mood-selector" style={{ padding: '8px 0' }}>
        {quickPrompts.map((prompt, i) => (
          <button
            key={i}
            onClick={() => handleSend(prompt)}
            className="mood-chip"
            style={{ fontSize: '12px', padding: '6px 12px' }}
          >
            {prompt}
          </button>
        ))}
      </div>

      {/* Input Bar */}
      <div className="chat-input-bar">
        <input
          type="text"
          className="chat-input"
          placeholder="Parle avec Lily Rose..."
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
        />
        <button className="btn-send" onClick={() => handleSend()}>
          <Send size={18} />
        </button>
      </div>
    </div>
  );
}
