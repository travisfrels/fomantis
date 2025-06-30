import { configureStore, createSlice } from "@reduxjs/toolkit";

const slice = createSlice({
  name: "fomantis",
  initialState: { apiStatus: "pending", comments: [] },
  reducers: {
    setApiStatus: (state, action) => {
      state.apiStatus = action.payload;
    },
    addComment: (state, action) => {
      const { comment, sentiment, has_profanity, id } = action.payload;
      state.comments.push({ comment, sentiment, has_profanity, id });
    },
    clearComments: (state) => {
      state.comments = [];
    },
  },
});

export const store = configureStore({
  reducer: {
    app: slice.reducer,
  },
});

export const { setApiStatus, addComment, clearComments } = slice.actions;
