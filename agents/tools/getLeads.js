const { Tool } = require("langchain/tools");
const axios = require("axios");

const getLeadsTool = new Tool({
  name: "getLeads",
  description:
    "Fetch leads from the CRM using optional filters like status or source.",
  func: async (input) => {
    try {
      const filters = input ? JSON.parse(input) : {};
      const response = await axios.get("http://localhost:5000/api/leads", {
        params: filters,
      });
      return JSON.stringify(response.data, null, 2);
    } catch (err) {
      return `Error fetching leads: ${err.message}`;
    }
  },
});

module.exports = getLeadsTool;
