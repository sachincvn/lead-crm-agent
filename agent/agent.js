import dotenv from "dotenv";
dotenv.config({ debug: false });

import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { createReactAgent } from "@langchain/langgraph/prebuilt";
import { MemorySaver } from "@langchain/langgraph";
import { weatherTool } from "./tools/weatherTool.js";
import { getLeadsTool } from "./tools/getLeadsTool.js";
import { createLeadTool } from "./tools/createLeadTool.js";
import { updateLeadTool } from "./tools/updateLeadTool.js";

const model = new ChatGoogleGenerativeAI({
  apiKey: process.env.GOOGLE_API_KEY,
  model: "gemini-2.5-flash",
});

const checkpointSaver = new MemorySaver();

export const agent = createReactAgent({
  llm: model,
  tools: [weatherTool, getLeadsTool, createLeadTool, updateLeadTool],
  checkpointSaver,
});
