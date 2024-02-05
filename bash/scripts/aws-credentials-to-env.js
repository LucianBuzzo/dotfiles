#!/usr/bin/env node

const fs = require("fs");
const os = require("os");
const path = require("path");

const CREDENTIALS_FILE = path.join(os.homedir(), ".aws", "credentials");
const ENV_FILE = path.join(process.cwd(), ".env");
const PROFILE = "cerebrum-token";

// Read .aws/credentials
const credentials = fs.readFileSync(CREDENTIALS_FILE, "utf8");
const lines = credentials.split("\n");
let profileIndex = lines.findIndex((line) => line === `[${PROFILE}]`);

if (profileIndex === -1) {
  console.error(`Profile ${PROFILE} not found in ${CREDENTIALS_FILE}`);
  process.exit(1);
}

let keys = {};
for (let i = profileIndex + 1; i < lines.length; i++) {
  if (lines[i].startsWith("[")) break;
  if (lines[i].trim().length === 0) continue;

  const [key, value] = lines[i].split("=").map((str) => str.trim());
  keys[key.toUpperCase()] = value;
}

// Read .env
let envContent = "";
if (fs.existsSync(ENV_FILE)) {
  envContent = fs.readFileSync(ENV_FILE, "utf8");
}

// Update .env
Object.keys(keys).forEach((key) => {
  const regex = new RegExp(`^${key}=.*$`, "m");
  if (regex.test(envContent)) {
    envContent = envContent.replace(regex, `${key}=${keys[key]}`);
  } else {
    envContent += `\n${key}=${keys[key]}`;
  }
});

fs.writeFileSync(ENV_FILE, envContent);

console.log(`Done! variables written to ${ENV_FILE}`);
