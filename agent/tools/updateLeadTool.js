import { tool } from "@langchain/core/tools";
import { z } from "zod";
import axios from "axios";

const LeadStatusEnum = z.enum([
  "New",
  "Follow-Up",
  "Meeting Scheduled",
  "Site Visit Scheduled",
  "Site Visited",
  "Negotiation",
  "Not Interested",
  "Dropped",
  "Closed",
]);

export const updateLeadTool = tool(
  async ({ name, phone, updates }) => {
    try {
      const searchParams = {};
      if (name) searchParams.name = name;
      if (phone) searchParams.phone = phone;

      const searchResp = await axios.get(process.env.GET_LEADS_API, {
        params: searchParams,
      });

      const leads = searchResp.data;

      if (!leads.length) {
        return `❌ No lead found with${name ? ` name "${name}"` : ""}${
          phone ? ` and phone "${phone}"` : ""
        }.`;
      }

      if (leads.length > 1) {
        const preview = leads
          .slice(0, 3)
          .map((l) => `- ${l.name}, ${l.phone}`)
          .join("\n");
        return `⚠️ Multiple leads found for name "${name}". Please specify the phone number.\n\nMatching leads:\n${preview}`;
      }

      const leadId = leads[0]._id;

      const updateResp = await axios.put(
        `${process.env.GET_LEADS_API}/${leadId}`,
        updates
      );

      const updated = updateResp.data.lead;

      return `✅ Lead updated:\n- Name: ${updated.name}\n- Phone: ${
        updated.phone
      }\n- Status: ${updated.status || "N/A"}`;
    } catch (error) {
      console.error("Update Lead Error:", error.message);
      return `❌ Failed to update lead: ${error.message}`;
    }
  },
  {
    name: "update_lead",
    description:
      "Update an existing lead using name or phone to find it. You can update name, status, notes, meeting/site visit info, budget, etc.",
    schema: z.object({
      name: z.string().describe("Name of the lead to find"),
      phone: z
        .string()
        .optional()
        .describe("Phone number of the lead (if available)"),
      updates: z
        .object({
          name: z.string().optional(),
          status: LeadStatusEnum.optional(),
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
        })
        .describe("Fields to update for the lead"),
    }),
  }
);
