import { agent } from "../agent/agent.js";

export const generateResponse = async (req, res) => {
  try {
    const { prompt, thread_id } = req.body;

    if (!prompt) {
      return res.status(400).json({ error: "Prompt is required" });
    }

    const response = await agent.invoke(
      {
        messages: [
          {
            role: "user",
            content: prompt,
          },
        ],
      },
      {
        configurable: {
          thread_id: thread_id,
        },
      }
    );

    res.json(response.messages.at(-1)?.content);
  } catch (error) {
    console.error("Agent Error:", error.message);
    res.status(500).json({ error: error.message });
  }
};
