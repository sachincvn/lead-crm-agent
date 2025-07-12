import mongoose from "mongoose";
import { LEAD_STATUS, LEAD_SOURCE } from "../enums/lead.enums.js";

const LeadSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  email: { type: String },
  source: { type: String, enum: LEAD_SOURCE, required: true },

  enquiredFor: {
    propertyType: { type: String },
    location: { type: String },
    project: { type: String },
    possession: { type: String },
    furnishing: { type: String },
  },

  budget: {
    min: Number,
    max: Number,
  },

  siteVisit: {
    isScheduled: { type: Boolean, default: false },
    date: Date,
    location: String,
  },

  meeting: {
    isScheduled: { type: Boolean, default: false },
    date: Date,
    mode: String,
  },

  status: { type: String, enum: LEAD_STATUS, default: "New" },
  notes: { type: String },

  assignedTo: { type: String },
  leadRating: { type: String },
  nextFollowUpDate: { type: Date },
  lastFollowUpDate: { type: Date },

  createdAt: { type: Date, default: Date.now },
});

export default mongoose.model("Lead", LeadSchema);
