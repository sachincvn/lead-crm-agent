import { tool } from "@langchain/core/tools";
import { z } from "zod";
import axios from "axios";
import { LEAD_SOURCE, LEAD_STATUS } from "../../enums/lead.enums.js";

export const createLeadTool = tool(
  async ({ lead }) => {
    try {
      const response = await axios.post(
        process.env.GET_LEADS_API || "http://localhost:5000/api/leads",
        lead
      );
      const newLead = response.data.lead;
      return `✅ Lead created successfully:\n- Name: ${newLead.name}\n- Phone: ${newLead.phone}\n- Source: ${newLead.source}`;
    } catch (error) {
      console.error("Create Lead Error:", error.message);
      return `❌ Failed to create lead: ${error.message}`;
    }
  },
  {
    name: "create_lead",
    description:
      "Create a new lead. Name, phone, and source are required. You can also provide status, project details, site visit, meeting, budget, etc.",
    schema: z.object({
      lead: z.object({
        name: z.string().describe("Full name of the lead"),
        phone: z.string().describe("Phone number of the lead"),
        source: z
          .enum(LEAD_SOURCE)
          .describe("Source of the lead (e.g., Facebook, JustDial)"),
        email: z.string().optional(),
        status: z.enum(LEAD_STATUS).optional(),
        leadRating: z.string().optional(),
        assignedTo: z.string().optional(),
        notes: z.string().optional(),
        enquiredFor: z
          .object({
            propertyType: z.string().optional(),
            location: z.string().optional(),
            project: z.string().optional(),
            possession: z.string().optional(),
            furnishing: z.string().optional(),
          })
          .optional(),
        budget: z
          .object({
            min: z.number().optional(),
            max: z.number().optional(),
          })
          .optional(),
        meeting: z
          .object({
            isScheduled: z.boolean().optional(),
            date: z.string().optional(),
            mode: z.string().optional(),
          })
          .optional(),
        siteVisit: z
          .object({
            isScheduled: z.boolean().optional(),
            date: z.string().optional(),
            location: z.string().optional(),
          })
          .optional(),
        nextFollowUpDate: z.string().optional(),
        lastFollowUpDate: z.string().optional(),
      }),
    }),
  }
);
