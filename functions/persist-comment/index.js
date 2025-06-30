const { CloudEvent } = require("cloudevents");

const handle = (context, event) =>
  new CloudEvent({
    source: "persist-comment",
    type: "comment-persisted",
    version: "1.0.0",
    data: { ...event.data, ...{ id: crypto.randomUUID() } },
  });

module.exports = { handle };
