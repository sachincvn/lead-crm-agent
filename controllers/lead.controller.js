import Lead from "../models/lead.model.js";

export const createLead = async (req, res) => {
  try {
    const lead = new Lead(req.body);
    await lead.save();
    res.status(201).json({ message: "Lead created", lead });
  } catch (error) {
    console.error("Create Lead Error:", error.message);
    res.status(400).json({ error: error.message });
  }
};

export const getLeads = async (req, res) => {
  try {
    const filter = {};

    if (req.query.status) filter.status = req.query.status;
    if (req.query.source) filter.source = req.query.source;
    if (req.query.assignedTo) filter.assignedTo = req.query.assignedTo;
    if (req.query.location) filter["enquiredFor.location"] = req.query.location;
    if (req.query.project) filter["enquiredFor.project"] = req.query.project;
    if (req.query.rating) filter.leadRating = req.query.rating;

    if (req.query.name) filter.name = new RegExp(req.query.name, "i");
    if (req.query.phone) filter.phone = req.query.phone;
    if (req.query.email) filter.email = new RegExp(req.query.email, "i");

    if (req.query.from || req.query.to) {
      filter.createdAt = {};
      if (req.query.from) filter.createdAt.$gte = new Date(req.query.from);
      if (req.query.to) filter.createdAt.$lte = new Date(req.query.to);
    }

    if (req.query.meetingScheduled !== undefined) {
      filter["meeting.isScheduled"] = req.query.meetingScheduled === "true";
    }
    if (req.query.siteVisitScheduled !== undefined) {
      filter["siteVisit.isScheduled"] = req.query.siteVisitScheduled === "true";
    }

    if (req.query.meetingDate) {
      const meetingDate = new Date(req.query.meetingDate);
      const startOfDay = new Date(meetingDate.setHours(0, 0, 0, 0));
      const endOfDay = new Date(meetingDate.setHours(23, 59, 59, 999));
      filter["meeting.date"] = {
        $gte: startOfDay,
        $lte: endOfDay,
      };
    }

    if (req.query.siteVisitDate) {
      const siteVisitDate = new Date(req.query.siteVisitDate);
      const startOfDay = new Date(siteVisitDate.setHours(0, 0, 0, 0));
      const endOfDay = new Date(siteVisitDate.setHours(23, 59, 59, 999));
      filter["siteVisit.date"] = {
        $gte: startOfDay,
        $lte: endOfDay,
      };
    }

    const leads = await Lead.find(filter).sort({ createdAt: -1 });
    res.json(leads);
  } catch (error) {
    console.error("Get Leads Error:", error.message);
    res.status(500).json({ error: error.message });
  }
};

export const updateLead = async (req, res) => {
  try {
    delete req.body._id;

    const updatedLead = await Lead.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
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

export const deleteLead = async (req, res) => {
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
