"use client";
import { Provider } from "react-redux";
import * as state from "./state";

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <title>fomantis</title>
      </head>
      <body>
        <Provider store={state.store}>{children}</Provider>
      </body>
    </html>
  );
}
