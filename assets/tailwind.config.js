const colors = require("tailwindcss/colors");

module.exports = {
  darkMode: false, // or 'media' or 'class'
  purge: [
    "../lib/**/*.ex",
    "../lib/**/*.leex",
    "../lib/**/*.eex",
    "./js/**/*.js",
  ],
  theme: {
    colors: {
      sandy: "rgb(249, 245, 241)",
      owhite: "rgb(255, 254, 252)",
      oblack: "rgb(55, 53, 47)",
      bblack: "#040404",
      lblack: "rgba(0, 0, 0, 0.6)",
      tomato: "rgb(225, 98, 89)",
      black: colors.black,
      white: colors.white,
      gray: colors.coolGray,
      blue: colors.lightBlue,
      red: colors.rose,
      green: colors.green,
      pink: colors.fuchsia,
    },
    fontFamily: {
      sans: ["Graphik", "sans-serif"],
      serif: ["Merriweather", "serif"],
    },
    extend: {
      spacing: {
        128: "32rem",
        144: "36rem",
      },
      borderRadius: {
        "4xl": "2rem",
      },
    },
  },
  variants: {
    extend: {
      borderColor: ["focus-visible"],
      opacity: ["disabled"],
    },
  },
};
