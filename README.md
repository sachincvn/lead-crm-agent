# 🏠 Lead CRM Agent

An AI-powered Lead CRM system with LangChain, LangGraph, and Gemini AI integration for intelligent real estate lead management through natural language conversations.

## ✨ Features

- 🤖 **AI Agent**: Natural language interface for lead management
- 🔍 **Smart Search**: Find leads with complex filters and natural language queries
- ➕ **Lead Creation**: Add new leads with complete property requirements
- ✏️ **Lead Updates**: Modify lead information, status, and follow-ups
- 📊 **Analytics**: Intelligent lead scoring, conversion analysis, and insights
- 💬 **Chat Interface**: Interactive conversation with memory
- 🌐 **REST API**: HTTP endpoints for integration
- 📱 **Real-time**: Live lead management with instant updates

## 🚀 Quick Start

### 1. Setup Environment

```bash
# Clone the repository
git clone <your-repo-url>
cd lead-crm-agent

# Install dependencies
npm install

# Setup environment
npm run setup
```

### 2. Configure API Key

Update `.env` file with your Gemini API key:

```env
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

Get your API key from: https://makersuite.google.com/app/apikey

### 3. Start the Server

```bash
npm start
# Server runs on http://localhost:5000
```

### 4. Test the Agent

```bash
# Run comprehensive tests
npm test

# Quick test
npm run test-quick
```

### 5. Start Chat Interface

```bash
npm run chat
# Interactive chat interface
```

## 💬 Using the Agent

### Chat Interface Commands

```bash
# Basic queries
"Show all leads"
"Find leads from Facebook"
"Show New status leads"

# Create leads
"Create a lead for John Doe, phone 9876543210"
"Add new lead from Website for apartment in Mumbai"

# Update leads
"Update lead status to Contacted"
"Assign lead to John Agent"
"Schedule site visit for lead"

# Analytics
"Show lead analytics"
"Find hot leads"
"Show follow-up reminders"
"Analyze conversion rates"
```

### API Endpoints

#### Agent Endpoints

```bash
# Chat with agent
POST /api/agent/chat
{
  "message": "Show all leads from Facebook",
  "sessionId": "optional-session-id"
}

# Get agent status
GET /api/agent/status

# Clear conversation memory
POST /api/agent/clear-memory

# Get conversation history
GET /api/agent/history
```

#### Lead Management

```bash
# Get all leads
GET /api/leads

# Create new lead
POST /api/leads
{
  "name": "John Doe",
  "phone": "9876543210",
  "email": "john@example.com",
  "source": "Facebook",
  "enquiredFor": {
    "propertyType": "Apartment",
    "location": "Mumbai"
  },
  "budget": {
    "min": 5000000,
    "max": 8000000
  }
}

# Update lead
PUT /api/leads/:id

# Delete lead
DELETE /api/leads/:id
```

## 🧠 Agent Capabilities

### 1. Lead Search & Filtering

- Search by name, phone, email
- Filter by status, source, location
- Budget range filtering
- Date range queries
- Complex multi-criteria searches

### 2. Lead Creation

- Natural language lead creation
- Automatic data validation
- Property requirement capture
- Budget and timeline tracking

### 3. Lead Updates

- Status management
- Assignment to agents
- Follow-up scheduling
- Notes and comments
- Site visit coordination

### 4. Smart Analytics

- **Lead Scoring**: Automatic scoring based on engagement
- **Hot Leads**: Identify high-potential prospects
- **Follow-up Reminders**: Track overdue follow-ups
- **Conversion Analysis**: Success rate tracking
- **Source Performance**: ROI by lead source
- **Budget Analysis**: Budget distribution insights

### 5. Conversation Memory

- Multi-turn conversations
- Context awareness
- Reference to previous interactions
- Session management

## 📊 Lead Data Model

```javascript
{
  name: String,           // Required
  phone: String,          // Required
  email: String,
  source: String,         // Required (Facebook, Google, Website, etc.)

  enquiredFor: {
    propertyType: String, // Apartment, Villa, Plot, etc.
    location: String,
    project: String,
    possession: String,
    furnishing: String
  },

  budget: {
    min: Number,
    max: Number
  },

  siteVisit: {
    isScheduled: Boolean,
    date: Date,
    location: String
  },

  meeting: {
    isScheduled: Boolean,
    date: Date,
    mode: String
  },

  status: String,         // New, Contacted, Qualified, Proposal, Won, Lost
  notes: String,
  assignedTo: String,
  leadRating: String,     // Hot, Warm, Cold
  nextFollowUpDate: Date,
  lastFollowUpDate: Date,
  createdAt: Date
}
```

## 🛠 Development

### Project Structure

```
lead-crm-agent/
├── agents/
│   ├── llm.js              # LLM configuration
│   ├── runAgent.js         # Main agent logic
│   ├── chatInterface.js    # Interactive chat
│   └── tools/              # Agent tools
│       ├── getLeads.js
│       ├── createLead.js
│       ├── updateLead.js
│       ├── deleteLead.js
│       └── smartLeadAnalytics.js
├── controllers/            # API controllers
├── models/                 # Database models
├── routes/                 # API routes
├── config/                 # Configuration
└── tests/                  # Test files
```

### Available Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm test           # Run comprehensive tests
npm run test-quick # Quick agent test
npm run chat       # Start chat interface
npm run setup      # Setup wizard
npm run agent      # Alias for chat
```

### Environment Variables

```env
PORT=5000
MONGODB_URI=your_mongodb_connection_string
GEMINI_API_KEY=your_gemini_api_key
```

## 🧪 Testing

The project includes comprehensive testing:

```bash
# Run all tests
npm test

# Tests include:
- Basic agent response
- Lead CRUD operations
- Filtering and search
- Analytics and insights
- Conversation memory
- Error handling
- Complex queries
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details

## 🆘 Support

For issues and questions:

1. Check the troubleshooting section
2. Run the comprehensive tests
3. Review the agent logs
4. Create an issue with detailed information

## 🔧 Troubleshooting

### Common Issues

1. **API Key Error**

   - Ensure GEMINI_API_KEY is set in .env
   - Verify the API key is valid

2. **Server Connection Error**

   - Check if server is running on port 5000
   - Verify MongoDB connection

3. **Agent Not Responding**

   - Check server logs for errors
   - Verify all dependencies are installed
   - Run the test suite

4. **Memory Issues**
   - Clear conversation memory: `POST /api/agent/clear-memory`
   - Restart the server

---

🏠 **Happy Lead Management!** 🤖
