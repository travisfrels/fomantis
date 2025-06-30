const { CloudEvent } = require("cloudevents");

const handle = (context, event) =>
  new CloudEvent({
    source: "analyze-profanity",
    type: "comment-analysis",
    version: "1.0.0",
    data: { ...event.data, ...{ has_profanity: false } },
  });

module.exports = { handle };
