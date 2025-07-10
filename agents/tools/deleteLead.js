const { Tool } = require("langchain/tools");
const axios = require("axios");

const deleteLeadTool = new Tool({
  name: "deleteLead",
  description: "Delete a lead by its ID.",
  func: async (input) => {
    try {
      const { leadId } = JSON.parse(input);
      const response = await axios.delete(
        `http://localhost:5000/api/leads/${leadId}`
      );
      return JSON.stringify(response.data);
    } catch (err) {
      return `Error deleting lead: ${err.message}`;
    }
  },
});

module.exports = deleteLeadTool;
