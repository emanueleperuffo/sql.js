'use strict';

module.exports = {
  env: {
    browser: true,
    es6: true,
    node: true,
  },
  extends: ['airbnb-base'],
  globals: {
    Atomics: 'readonly',
    SharedArrayBuffer: 'readonly',
  },
  ignorePatterns: [
    '/dist/',
    '/examples/',
    '/documentation/',
    '/node_modules/',
    '/out/',
    '/test/',
    '!/.eslintrc.js',
  ],
  parserOptions: {
    ecmaVersion: 6,
    sourceType: 'script',
  },
  rules: {
    // reason - sqlite exposes functions with underscore-naming-convention
    camelcase: 'off',
    // reason - string-notation needed to prevent closure-minifier
    // from mangling property-name
    'dot-notation': 'off',
    // reason - src/api.js uses bitwise-operators
    'no-bitwise': 'off',
    'no-cond-assign': ['error', 'except-parens'],
    'no-param-reassign': 'off',
    'no-throw-literal': 'off',
    // reason - allow top-level "use-strict" in commonjs-modules
    strict: ['error', 'safe'],
    'vars-on-top': 'off',
  },
};
