import defaultTheme from "tailwindcss/defaultTheme.js";
import typography from "@tailwindcss/typography";

const customization = (theme) => ({
  DEFAULT: {
    css: {
      maxWidth: "100ch",
      lineHeight: false,
      h1: {
        fontWeight: false,
      },
      h2: {
        fontWeight: false,
      },
      table: {
        width: false,
        fontSize: false,
      },
      pre: false,
      "code::before": false,
      "code::after": false,
      code: {
        fontSize: false,
      },
      a: {
        color: theme("colors.rose.700"),
        textDecoration: "none",
        "&:hover": {
          textDecoration: "underline",
        },
      },
    },
  },
});

/** @type {import("tailwindcss").Config} */
export default {
  content: ["_layouts/**/*.html"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Calibri", "Liberation Sans", ...defaultTheme.fontFamily.sans],
      },
      typography: customization,
    },
  },
  plugins: [typography],
};
