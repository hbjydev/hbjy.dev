import type { Config } from 'tailwindcss';
import defaultTheme from 'tailwindcss/defaultTheme';
import typography from '@tailwindcss/typography';

export default {
	content: ['./src/**/*.{astro,html,md,mdx}'],
	theme: {
		extend: {
      lineHeight: {
        normal: "180%",
      },
      letterSpacing: {
        normal: "-0.32px",
      },
      fontFamily: {
        mono: ["Geist Mono", "Courier New", ...defaultTheme.fontFamily.sans],
      },
      colors: {
        black: "var(--base00)",
        white: "var(--base05)",
        gray: "var(--base02)",
        muted: "var(--base02)",
        pink: "var(--base0A)",
      },

      animation: {
        blink: "blink 1.45s infinite step-start",
      },

      keyframes: {
        blink: {
          "0%, 25%, 100%": { opacity: "1" },
          "50%, 75%": { opacity: "0" },
        },
      },

      typography: (theme: (acc: string) => string) => ({
        DEFAULT: {
          css: {
            color: theme('colors.white'),
            a: {
              color: theme('colors.pink'),
            },
            h1: {
              color: theme('colors.white'),
            },
            blockquote: {
              "border-inline-start-color": 'var(--base03)',
              "font-style": "normal",
              p: {
                color: 'var(--base04)',
              },
            },
            code: {
              color: 'var(--base0E)',
              '&::before': {
                content: '"" !important',
              },
              '&::after': {
                content: '"" !important',
              },
            },
          },
        },
      }),
    },
	},
	plugins: [
    typography,
  ],
} satisfies Config;
