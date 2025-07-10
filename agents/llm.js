const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
require("dotenv").config();

const llm = new ChatGoogleGenerativeAI({
  model: "gemini-pro",
  temperature: 0.3,
  apiKey: "",
});

module.exports = llm;
