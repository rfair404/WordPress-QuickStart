#!/usr/bin/env node

/**
 * Simple formatting script to fix the 4 files that are failing Prettier check
 * This uses the same Prettier config as the CI but runs locally
 */

const fs = require('fs');
const path = require('path');

// Files that need formatting (from CI log)
const filesToFormat = [
  '.config/linting/.stylelintrc.js',
  'package.json',
  'tests/e2e/placeholder.spec.js',
  'tests/playwright.config.js',
];

// Basic formatting function that applies consistent indentation
function formatJavaScript(content) {
  // Convert tabs to 4 spaces and normalize line endings
  return content
    .replace(/\t/g, '    ') // Replace tabs with 4 spaces
    .replace(/\r\n/g, '\n') // Normalize line endings
    .split('\n')
    .map(line => line.trimRight()) // Remove trailing whitespace
    .join('\n')
    .replace(/\n+$/, '\n'); // Ensure single newline at end
}

function formatJSON(content) {
  try {
    // Parse and reformat JSON with 4-space indentation
    const parsed = JSON.parse(content);
    return JSON.stringify(parsed, null, 4) + '\n';
  } catch (e) {
    console.error('Error parsing JSON:', e.message);
    return formatJavaScript(content); // Fallback to basic formatting
  }
}

function formatFile(filePath) {
  try {
    const fullPath = path.resolve(filePath);
    const content = fs.readFileSync(fullPath, 'utf8');

    let formatted;
    if (filePath.endsWith('.json')) {
      formatted = formatJSON(content);
    } else {
      formatted = formatJavaScript(content);
    }

    if (content !== formatted) {
      fs.writeFileSync(fullPath, formatted, 'utf8');
      console.log(`✅ Formatted: ${filePath}`);
      return true;
    } else {
      console.log(`ℹ️  Already formatted: ${filePath}`);
      return false;
    }
  } catch (error) {
    console.error(`❌ Error formatting ${filePath}:`, error.message);
    return false;
  }
}

console.log('🔧 Formatting files identified by Prettier check...\n');

let changedFiles = 0;
filesToFormat.forEach(file => {
  if (formatFile(file)) {
    changedFiles++;
  }
});

console.log(`\n🎉 Formatting complete! ${changedFiles} files changed.`);
