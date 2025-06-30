"use client";
import { useEffect } from "react";
import * as ops from "./operations";
import ApiHealth from "./components/ApiHealthComponent";
import CommentForm from "./components/CommentFormComponent";
import CommentListComponent from "./components/CommentListComponent";

export default function Page() {
  useEffect(() => ops.configureWebSocket(), []);

  return (
    <div>
      <h1>fomantis</h1>
      <ApiHealth />
      <hr />
      <CommentForm />
      <hr />
      <CommentListComponent />
    </div>
  );
}
