import React, { useState } from 'react'; // Importing React and the useState hook for managing component state
import logo from './awsaipro logo.png'; // Importing the logo image
import './App.css'; // Importing the CSS file for styling

function App() {
  // useState hook to manage the list of messages in the chat
  // 'messages' is the state variable, and 'setMessages' is the function to update it
  // Initial state is an empty array
  const [messages, setMessages] = useState([]);

  // useState hook to manage the text in the input field
  // 'inputText' is the state variable, and 'setInputText' is the function to update it
  // Initial state is an empty string
  const [inputText, setInputText] = useState('');

  // Function to handle changes in the input field
  const handleInputChange = (event) => {
    setInputText(event.target.value); // Update the 'inputText' state with the current value of the input field
  };

  // Mock API function to simulate a backend API call
  const mockAPI = async (message) => {
    // Simulate a delay to mimic a real API call
    await new Promise(resolve => setTimeout(resolve, 500));

    // Simple logic to generate a response based on the message content
    if (message.toLowerCase().includes('hello')) {
      return "Hello there! How can I help you today?";
    } else if (message.toLowerCase().includes('help')) {
      return "I can answer questions about your S3 data.";
    } else {
      return "I'm sorry, I don't understand. Can you please rephrase your question?";
    }
  };

  // Async function to handle sending a message
  const sendMessage = async () => {
    if (inputText.trim() !== '') { // Check if the input text is not empty after trimming whitespace
      const userMessage = { text: inputText, sender: 'user' }; // Create a message object for the user's message
      setMessages([...messages, userMessage]); // Add the user's message to the 'messages' state
      setInputText(''); // Clear the input field

      try {
        const botResponse = await mockAPI(inputText); // Call the mock API to get a response from the chatbot
        const botMessage = { text: botResponse, sender: 'bot' }; // Create a message object for the bot's response
        setMessages((prevMessages) => [...prevMessages, botMessage]); // Add the bot's message to the 'messages' state
      } catch (error) {
        console.error('Error sending message:', error); // Log any errors to the console
        // Handle error (e.g., display an error message to the user)
        const errorMessage = { text: 'Error: Could not connect to the chatbot.', sender: 'bot' }; // Create an error message object
        setMessages((prevMessages) => [...prevMessages, errorMessage]); // Add the error message to the 'messages' state
      }
    }
  };

  // JSX to render the component
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" /> {/* Display the logo */}
        <h2>My S3 Chatbot</h2> {/* Display the title */}
        <div className="chat-container"> {/* Container for the chat interface */}
          <div className="message-list"> {/* Container for the list of messages */}
            {messages.map((message, index) => ( // Map over the 'messages' array to display each message
              <div key={index} className={`message ${message.sender}`}> {/* Display each message with a unique key and a class based on the sender */}
                {message.text} {/* Display the message text */}
              </div>
            ))}
          </div>
          <div className="input-area"> {/* Container for the input area */}
            <input
              type="text"
              placeholder="Ask any question"
              value={inputText}
              onChange={handleInputChange}
            />
            <button onClick={sendMessage}>Ask ChatBot</button>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App; // Export the App component