"use client";
import { useSelector } from "react-redux";
import CommentComponent from "./CommentComponent";

export default function CommentListComponent() {
  const comments = useSelector((state) => state.app.comments);

  return (
    <div>
      <h2>Comments</h2>
      <div>
        {comments.length > 0 ? (
          comments.map((comment) => (
            <CommentComponent
              key={comment.id}
              comment={comment.comment}
              sentiment={comment.sentiment}
              has_profanity={comment.has_profanity}
              id={comment.id}
            />
          ))
        ) : (
          <p>No comments yet.</p>
        )}
      </div>
    </div>
  );
}
