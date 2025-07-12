import { tool } from "@langchain/core/tools";
import { z } from "zod";
import axios from "axios";

export const deleteLeadTool = tool(
  async ({ name, phone, confirmed }) => {
    try {
      // Build search parameters
      const searchParams = {};
      if (name) searchParams.name = name;
      if (phone) searchParams.phone = phone;

      // Search for leads
      const searchResp = await axios.get(process.env.GET_LEADS_API, {
        params: searchParams,
      });

      const leads = searchResp.data;

      // Check if any leads found
      if (!leads.length) {
        return `❌ No lead found with${name ? ` name "${name}"` : ""}${
          phone ? ` and phone "${phone}"` : ""
        }.`;
      }

      // Handle multiple leads found
      if (leads.length > 1) {
        const preview = leads
          .slice(0, 5)
          .map((l, index) => `${index + 1}. ${l.name}, ${l.phone}`)
          .join("\n");
        return `⚠️ Multiple leads found for name "${name}". Please specify the phone number to identify the exact lead.\n\n**Matching leads:**\n${preview}\n\n💡 **Tip:** Use both name and phone number for precise identification.`;
      }

      const lead = leads[0];

      // Require confirmation before deletion
      if (!confirmed) {
        return `⚠️ **Confirmation Required**\n\nYou are about to delete the following lead:\n\n**Lead Details:**\n- **Name:** ${lead.name}\n- **Phone:** ${lead.phone}\n- **Status:** ${lead.status || "N/A"}\n- **Source:** ${lead.source || "N/A"}\n\n🚨 **This action cannot be undone!**\n\nTo proceed with deletion, please confirm by saying "Yes, delete this lead" or "Confirm deletion".`;
      }

      // Perform deletion
      const deleteResp = await axios.delete(
        `${process.env.GET_LEADS_API}/${lead._id}`
      );

      return `✅ **Lead Successfully Deleted**\n\n**Deleted Lead:**\n- **Name:** ${lead.name}\n- **Phone:** ${lead.phone}\n- **Status:** ${lead.status || "N/A"}\n\n🗑️ The lead has been permanently removed from the system.`;
    } catch (error) {
      console.error("Delete Lead Error:", error.message);
      
      if (error.response?.status === 404) {
        return `❌ Lead not found. It may have already been deleted.`;
      }
      
      return `❌ Failed to delete lead: ${error.message}`;
    }
  },
  {
    name: "delete_lead",
    description:
      "Delete a lead by name. Requires confirmation before deletion. If multiple leads match the name, user must specify phone number for precise identification.",
    schema: z.object({
      name: z.string().describe("Name of the lead to delete"),
      phone: z
        .string()
        .optional()
        .describe("Phone number of the lead (required if multiple leads have the same name)"),
      confirmed: z
        .boolean()
        .optional()
        .describe("Set to true only after user explicitly confirms the deletion"),
    }),
  }
);
