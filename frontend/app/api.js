const API_URL = "http://localhost:3001";
const clientId = crypto.randomUUID();

export function getWebSocket() {
  return new WebSocket(API_URL + "/events?clientId=" + clientId);
}

export async function getHealthCheck() {
  const res = await fetch(API_URL + "/health-check");
  if (!res.ok) {
    throw new Error("[getHealthCheck] " + res.status + ": " + res.statusText);
  }
  return await res.json();
}

export async function postComment(comment) {
  const res = await fetch(API_URL + "/comment", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ comment, clientId }),
  });

  if (!res.ok) {
    throw new Error("[postComment] " + res.status + ": " + res.statusText);
  }
}
