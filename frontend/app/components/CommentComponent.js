"use client";

export default function CommentComponent({
  comment,
  sentiment,
  has_profanity,
  id,
}) {
  return (
    <div>
      <strong>Comment:</strong> {comment}
      <br />
      <strong>Sentiment:</strong> {sentiment}
      <br />
      <strong>Has Profanity:</strong> {has_profanity ? "Yes" : "No"}
      <br />
      <strong>ID:</strong> {id}
    </div>
  );
}
