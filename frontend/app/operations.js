import * as api from "./api";
import * as act from "./actions";

export function configureWebSocket() {
  const ws = api.getWebSocket();

  ws.onmessage = (event) => {
    const { type, data } = JSON.parse(event.data);
    if (type === "comment") {
      act.addComment(data);
    } else {
      console.warn("Unknown message type:", type);
    }
  };

  ws.onopen = () => {
    console.log("web socket opened");
  };

  ws.onclose = () => {
    console.log("web socket closed");
  };

  ws.onerror = (error) => {
    console.error("web socket error:", error);
  };

  return () => {
    ws.close();
  };
}

export async function checkApiStatus() {
  const result = await api.getHealthCheck();
  act.setApiStatus(result.message);
}

export async function submitComment(comment) {
  api.postComment(comment);
}
