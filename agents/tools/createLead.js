const { Tool } = require("langchain/tools");
const axios = require("axios");

const createLeadTool = new Tool({
  name: "createLead",
  description: "Create a new lead with name, phone, email, source, etc.",
  func: async (input) => {
    try {
      const body = JSON.parse(input);
      const response = await axios.post(
        "http://localhost:5000/api/leads",
        body
      );
      return JSON.stringify(response.data);
    } catch (err) {
      return `Error creating lead: ${err.message}`;
    }
  },
});

module.exports = createLeadTool;
