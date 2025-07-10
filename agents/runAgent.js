const { initializeAgentExecutorWithOptions } = require("langchain/agents");
const llm = require("./llm");

const getLeadsTool = require("./tools/getLeads");
const createLeadTool = require("./tools/createLead");
const updateLeadTool = require("./tools/updateLead");
const deleteLeadTool = require("./tools/deleteLead");

async function runAgent(input) {
  console.log("🛠 Tool Checks:");
  console.log("getLeadsTool:", typeof getLeadsTool, getLeadsTool?.name);
  console.log("createLeadTool:", typeof createLeadTool, createLeadTool?.name);
  console.log("updateLeadTool:", typeof updateLeadTool, updateLeadTool?.name);
  console.log("deleteLeadTool:", typeof deleteLeadTool, deleteLeadTool?.name);

  const executor = await initializeAgentExecutorWithOptions(
    [getLeadsTool, createLeadTool, updateLeadTool, deleteLeadTool],
    llm,
    {
      agentType: "chat-conversational-react-description",
      verbose: true,
    }
  );

  const result = await executor.invoke({ input });
  console.log("🤖 Agent Response:", result);
}

module.exports = runAgent;
