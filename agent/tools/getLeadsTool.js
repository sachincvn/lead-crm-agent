import { tool } from "@langchain/core/tools";
import { z } from "zod";
import axios from "axios";

export const getLeadsTool = tool(
  async ({ filters }) => {
    try {
      const response = await axios.get(
        process.env.GET_LEADS_API || "http://localhost:5000/api/leads",
        {
          params: filters || {},
        }
      );

      const leads = response.data;
      if (!leads.length) return "No leads found.";

      return leads
        .map((lead, index) => {
          return `Lead ${index + 1}:
- Name: ${lead.name}
- Phone: ${lead.phone}
- Email: ${lead.email || "N/A"}
- Status: ${lead.status}
- Source: ${lead.source}
- Rating: ${lead.leadRating || "N/A"}
- Assigned To: ${lead.assignedTo || "N/A"}
- Meeting Scheduled: ${lead.meeting?.isScheduled ? "Yes" : "No"}
- Meeting Date: ${
            lead.meeting?.date
              ? new Date(lead.meeting.date).toLocaleString()
              : "N/A"
          }
- Site Visit Scheduled: ${lead.siteVisit?.isScheduled ? "Yes" : "No"}
- Site Visit Date: ${
            lead.siteVisit?.date
              ? new Date(lead.siteVisit.date).toLocaleString()
              : "N/A"
          }
- Location: ${lead.enquiredFor?.location || "N/A"}
- Project: ${lead.enquiredFor?.project || "N/A"}
- Created At: ${new Date(lead.createdAt).toLocaleString()}`;
        })
        .join("\n\n");
    } catch (error) {
      console.error("Error fetching leads:", error.message);
      return `Failed to fetch leads: ${error.message}`;
    }
  },
  {
    name: "get_leads",
    description:
      "Fetch leads from the CRM API. You can filter by name, phone, email, status, source, assignedTo, location, project, rating, created date range (from, to), meetingScheduled, siteVisitScheduled, meetingDate, or siteVisitDate.",
    schema: z.object({
      filters: z
        .object({
          name: z.string().optional().describe("Partial match on lead name"),
          phone: z.string().optional().describe("Exact phone number"),
          email: z.string().optional().describe("Partial match on email"),
          status: z.string().optional(),
          source: z.string().optional(),
          assignedTo: z.string().optional(),
          location: z.string().optional(),
          project: z.string().optional(),
          rating: z.string().optional(),
          from: z
            .string()
            .optional()
            .describe("Created date from (YYYY-MM-DD)"),
          to: z.string().optional().describe("Created date to (YYYY-MM-DD)"),
          meetingScheduled: z
            .boolean()
            .optional()
            .describe("Whether meeting is scheduled"),
          siteVisitScheduled: z
            .boolean()
            .optional()
            .describe("Whether site visit is scheduled"),
          meetingDate: z
            .string()
            .optional()
            .describe("Specific date for meeting (YYYY-MM-DD)"),
          siteVisitDate: z
            .string()
            .optional()
            .describe("Specific date for site visit (YYYY-MM-DD)"),
        })
        .optional(),
    }),
  }
);
