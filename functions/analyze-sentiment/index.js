const { CloudEvent } = require("cloudevents");

const handle = (context, event) =>
  new CloudEvent({
    source: "analyze-sentiment",
    type: "comment-analysis",
    version: "1.0.0",
    data: { ...event.data, ...{ sentiment: "positive" } },
  });

module.exports = { handle };
