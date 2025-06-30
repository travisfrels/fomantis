"use client";
import * as ops from "../operations";
import { useState } from "react";

export default function CommentForm() {
  const [comment, setComment] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    ops.submitComment(comment);
  };

  return (
    <div>
      <h2>Submit Comment</h2>
      <form onSubmit={handleSubmit}>
        <textarea value={comment} onChange={(event) => setComment(event.target.value)}></textarea>
        <br />
        <button type="submit">submit</button>
      </form>
    </div>
  );
}
