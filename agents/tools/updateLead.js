const { Tool } = require("langchain/tools");
const axios = require("axios");

const updateLeadTool = new Tool({
  name: "updateLead",
  description: "Update a lead by ID. Provide the leadId and fields to update.",
  func: async (input) => {
    try {
      const { leadId, ...updates } = JSON.parse(input);
      const response = await axios.put(
        `http://localhost:5000/api/leads/${leadId}`,
        updates
      );
      return JSON.stringify(response.data);
    } catch (err) {
      return `Error updating lead: ${err.message}`;
    }
  },
});

module.exports = updateLeadTool;
