const Lead = require("../models/lead.model");

// 📥 Create a new lead
exports.createLead = async (req, res) => {
  try {
    const lead = new Lead(req.body);
    await lead.save();
    res.status(201).json({ message: "Lead created", lead });
  } catch (error) {
    console.error("Create Lead Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};

// 📤 Get leads with optional filters
exports.getLeads = async (req, res) => {
  try {
    const filter = {};

    // Existing filters
    if (req.query.status) filter.status = req.query.status;
    if (req.query.source) filter.source = req.query.source;
    if (req.query.assignedTo) filter.assignedTo = req.query.assignedTo;
    if (req.query.location) filter["enquiredFor.location"] = req.query.location;
    if (req.query.project) filter["enquiredFor.project"] = req.query.project;
    if (req.query.rating) filter.leadRating = req.query.rating;

    // ✅ NEW: Search fields
    if (req.query.name) filter.name = new RegExp(req.query.name, "i");
    if (req.query.phone) filter.phone = req.query.phone;
    if (req.query.email) filter.email = new RegExp(req.query.email, "i");

    // ✅ NEW: Date Range
    if (req.query.from || req.query.to) {
      filter.createdAt = {};
      if (req.query.from) filter.createdAt.$gte = new Date(req.query.from);
      if (req.query.to) filter.createdAt.$lte = new Date(req.query.to);
    }

    const leads = await Lead.find(filter).sort({ createdAt: -1 });
    res.json(leads);
  } catch (error) {
    console.error("Get Leads Error:", error.message);
    res.status(500).json({ error: error.message });
  }
};

// ✏️ Update a lead by ID
exports.updateLead = async (req, res) => {
  try {
    const updatedLead = await Lead.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    if (!updatedLead) {
      return res.status(404).json({ error: "Lead not found" });
    }
    res.json({ message: "Lead updated", lead: updatedLead });
  } catch (error) {
    console.error("Update Lead Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};

// 🗑️ Delete a lead by ID
exports.deleteLead = async (req, res) => {
  try {
    const deleted = await Lead.findByIdAndDelete(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: "Lead not found" });
    }
    res.json({ message: "Lead deleted" });
  } catch (error) {
    console.error("Delete Lead Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};
