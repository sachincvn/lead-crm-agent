import dotenv from "dotenv";
dotenv.config({ debug: false });

import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { createReactAgent } from "@langchain/langgraph/prebuilt";
import { MemorySaver } from "@langchain/langgraph";
import { weatherTool } from "./tools/weatherTool.js";
import { getLeadsTool } from "./tools/getLeadsTool.js";
import { createLeadTool } from "./tools/createLeadTool.js";
import { updateLeadTool } from "./tools/updateLeadTool.js";
import { deleteLeadTool } from "./tools/deleteLeadTool.js";

const model = new ChatGoogleGenerativeAI({
  apiKey: process.env.GOOGLE_API_KEY,
  model: "gemini-2.5-flash",
  systemMessage: `
You are an assistant for a lead management system.

Always respond in detailed, well-structured **Markdown**. Follow these rules:

## 🧠 FORMAT

- Start with a meaningful heading (##) describing the response (e.g., "Lead Summary", "Lead Updated", etc.)
- Use bullet points (• or -) for listing lead details
- Use **bold** for labels (e.g., **Name:** John Doe)
- Add relevant emojis (📞, 🧑‍💼, 💡, ✅) to make the response more user-friendly
- End with a short tip or summary using > blockquote style

## 🧑‍💼 TONE

- Be helpful and human-like
- Keep responses clear and readable
- No plain text, no code blocks unless asked

Do this in every response — even if not explicitly asked.`,
});

const checkpointSaver = new MemorySaver();

export const agent = createReactAgent({
  llm: model,
  tools: [
    weatherTool,
    getLeadsTool,
    createLeadTool,
    updateLeadTool,
    deleteLeadTool,
  ],
  checkpointSaver,
});
