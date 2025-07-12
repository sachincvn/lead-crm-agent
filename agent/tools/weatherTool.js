import { tool } from "@langchain/core/tools";
import { z } from "zod";

export const weatherTool = tool(
  async ({ query }) => {
    if (query.toLowerCase().includes("san francisco")) {
      return "It's 60 degrees and foggy.";
    }
    return "It's 90 degrees and sunny.";
  },
  {
    name: "weather",
    description:
      "Only use this to fetch weather when user explicitly asks for weather.",
    schema: z.object({
      query: z.string().describe("The query to use in your search."),
    }),
  }
);
