const express = require("express");
const router = express.Router();
const leadController = require("../controllers/lead.controller");

// CRUD endpoints
router.post("/", leadController.createLead);
router.get("/", leadController.getLeads);
router.put("/:id", leadController.updateLead);
router.delete("/:id", leadController.deleteLead);

module.exports = router;
