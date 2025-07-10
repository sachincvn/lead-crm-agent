const express = require("express");
const app = express();
const leadRoutes = require("./routes/lead.routes");

// Middleware
app.use(express.json());

// Routes
app.use("/api/leads", leadRoutes);

// Health check
app.get("/", (req, res) => {
  res.send("Lead CRM API is running...");
});

module.exports = app;
