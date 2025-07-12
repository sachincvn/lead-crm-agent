import express from "express";
import leadRoutes from "./routes/lead.routes.js";
import agentRoutes from "./routes/agent.routes.js";
import cors from "cors";

const app = express();

app.use(express.json());
app.use(cors({ origin: "*" }));

app.use("/api/leads", leadRoutes);
app.use("/api/agent", agentRoutes);

app.get("/", (req, res) => {
  res.send("Server is running");
});

export default app;
