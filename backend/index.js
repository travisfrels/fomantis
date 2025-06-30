const express = require("express");
const cors = require("cors");
const expressWs = require("express-ws");
const { HTTP, CloudEvent } = require("cloudevents");

const app = express();
const port = 3001;

app.use(express.json());
app.use(cors());
expressWs(app);

app.listen(port, () => console.log("listening on port " + port));

app.get("/health-check", (req, res) =>
  res.status(200).json({ message: "healthy", broker: !!process.env.K_SINK })
);

const clientSockets = new Map();

app.ws("/events", (ws, req) => {
  const url = new URL(req.url, "http://" + req.headers.host);
  const clientId = url.searchParams.get("clientId");

  console.log("new client connected", clientId);

  if (clientId) {
    clientSockets.set(clientId, ws);

    ws.on("close", () => clientSockets.delete(clientId));
    ws.on("error", () => clientSockets.delete(clientId));
  } else {
    ws.close(1008, "no clientId");
  }
});

app.post("/comment", async (req, res) => {
  try {
    const ws = clientSockets.get(req.body.clientId);
    if (!ws || ws.readyState !== ws.OPEN) {
      return res.status(400).json({ error: "clientId missing or invalid" });
    }

    const brokerURI = process.env.K_SINK;
    if (!brokerURI) {
      return res.status(500).json({ error: "sinkbinding not configured" });
    }

    const id = crypto.randomUUID();

    const response = await fetch(brokerURI, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "ce-specversion": "1.0",
        "ce-source": "fomantis-api",
        "ce-type": "new-comment",
        "ce-id": id,
      },
      body: JSON.stringify(req.body),
    });

    if (!response.ok) {
      return res.status(response.status).json({
        message: response.statusText,
      });
    }

    return res.status(200).json({ message: "event brokered", id });
  } catch (ex) {
    console.error(ex);
    return res.status(500).json({ error: "internal server error" });
  }
});

app.post("/comment-persisted", (req, res) => {
  const ws = clientSockets.get(req.body.clientId);
  if (ws && ws.readyState === ws.OPEN) {
    ws.send(JSON.stringify({ type: "comment", data: req.body }));
  }

  const receivedEvent = HTTP.toEvent({ headers: req.headers, body: req.body });

  const ack = HTTP.binary(
    new CloudEvent({
      type: receivedEvent.type,
      source: receivedEvent.source,
      data: {
        success: true,
        message: "processed",
      },
    })
  );

  res.writeHead(200, ack.headers);
  res.end(JSON.stringify(ack.body));
});
