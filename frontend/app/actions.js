import * as state from "./state";

export function setApiStatus(message) {
  state.store.dispatch(state.setApiStatus(message));
}

export function addComment({ comment, sentiment, has_profanity, id }) {
  state.store.dispatch(
    state.addComment({ comment, sentiment, has_profanity, id })
  );
}

export function clearComments() {
  state.store.dispatch(state.clearComments());
}
