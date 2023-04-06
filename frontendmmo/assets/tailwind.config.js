// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      colors: {
        primary: "#e779c1",
        secondary: "#58c7f3",
        accent: "#f3cc30",
        neutral: "#20134e",
        "neutral-content": "#f9f7fd",
        "base-100": "#2d1b69",
        "base-content": "#f9f7fd",
        info: "#53c0f3",
        "info-content": "#201047",
        success: "#71ead2",
        "success-content": "#201047",
        warning: "#f3cc30",
        "warning-content": "#201047",
        error: "#e24056",
        "error-content": "#f9f7fd",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    plugin(({addVariant}) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({addVariant}) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({addVariant}) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({addVariant}) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ]
}
