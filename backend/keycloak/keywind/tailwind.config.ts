import type { Config } from 'tailwindcss';
import colors from 'tailwindcss/colors';

export default {
  content: ['./theme/**/*.ftl'],
  experimental: {
    optimizeUniversalDefaults: true,
  },
  plugins: [require('@tailwindcss/forms')],
  theme: {
    extend: {
      colors: {
        primary: {
          ...colors.emerald,
          50: '#f7f9f8',
          100: '#eaf2ed',
          500: '#6b9888',
          600: '#285e4f',
          700: '#1c483c',
          800: '#163c32',
          900: '#202b2b',
        },
        secondary: {
          ...colors.gray,
          50: '#ffffff',
          100: '#f7f9f8',
          200: '#dfe5e2',
          500: '#677171',
          600: '#677171',
          700: '#202b2b',
          800: '#202b2b',
          900: '#202b2b',
        },
        provider: {
          apple: '#000000',
          bitbucket: '#0052CC',
          discord: '#5865F2',
          facebook: '#1877F2',
          github: '#181717',
          gitlab: '#FC6D26',
          google: '#4285F4',
          instagram: '#E4405F',
          linkedin: '#0A66C2',
          microsoft: '#5E5E5E',
          oidc: '#F78C40',
          openshift: '#EE0000',
          paypal: '#00457C',
          slack: '#4A154B',
          stackoverflow: '#F58025',
          twitter: '#1DA1F2',
        },
      },
    },
  },
} satisfies Config;
