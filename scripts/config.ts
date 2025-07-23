import { config } from "dotenv";
import * as admin from "firebase-admin";
import path from "path";

config();

var serviceAccount = require("./env/thepaxapp-firebase-adminsdk-fbsvc-d9e8b1fdff.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export const AUTH = admin.auth();

export const CREDENTIALS_PATH = path.resolve(
  __dirname,
  "./env/thepaxapp-71fbcf5792b2.json"
);

export const SPREADSHEET_ID = process.env.GSHEET_ID || null;

export const SHEET_NAME = "Disabled Participants";
