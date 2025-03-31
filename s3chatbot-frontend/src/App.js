import React, { useState } from 'react';
import logo from './awsaipro logo.png';
import './App.css';

function App() {
  const [messages, setMessages] = useState([]);
  const [inputText, setInputText] = useState('');

  const handleInputChange = (event) => {
    setInputText(event.target.value);
  };

  // Remove mockAPI function
  // const mockAPI = async (message) => { ... }

  const sendMessage = async () => {
    if (inputText.trim() !== '') {
      const userMessage = { text: inputText, sender: 'user', isUser: true }; // Added isUser:true
      setMessages([...messages, userMessage]);
      setInputText('');

      try {
        // Make sure to replace 'YOUR_API_GATEWAY_ENDPOINT/bedrock' with your actual API Gateway URL
        const response = await fetch('YOUR_API_GATEWAY_ENDPOINT/bedrock', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ message: inputText }), // Send inputText as the message
        });

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        const botMessage = { text: data.response, sender: 'bot', isUser: false }; // Added isUser:false
        setMessages((prevMessages) => [...prevMessages, botMessage]);
      } catch (error) {
        console.error('Error sending message:', error);
        const errorMessage = { text: 'Error: Could not connect to the chatbot.', sender: 'bot', isUser: false }; // Added isUser:false
        setMessages((prevMessages) => [...prevMessages, errorMessage]);
      }
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <h2>My S3 Chatbot Serverless</h2>
        <div className="chat-container">
          <div className="message-list">
            {messages.map((message, index) => (
              <div key={index} className={`message ${message.sender} ${message.isUser ? 'user-message' : 'bot-message'}`}>
                {message.text}
              </div>
            ))}
          </div>
          <div className="input-area">
            <input
              type="text"
              placeholder="Ask any question to your own chatgpt"
              value={inputText}
              onChange={handleInputChange}
            />
            <button onClick={sendMessage}>Ask ChatBot anything</button>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App;