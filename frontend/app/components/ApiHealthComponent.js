"use client";
import { useSelector } from "react-redux";
import { useEffect } from "react";
import * as ops from "../operations";

export default function ApiHealth() {
  const apiStatus = useSelector((state) => state.app.apiStatus);

  useEffect(() => {
    ops.checkApiStatus();
  }, []);

  return (
    <div>
      <h2>API Health</h2>
      <strong>API Status:</strong> {apiStatus}
      <br />
      <button onClick={ops.checkApiStatus}>health check</button>
    </div>
  );
}
