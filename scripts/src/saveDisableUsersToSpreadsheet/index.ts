import {
  AUTH,
  CREDENTIALS_PATH,
  SHEET_NAME,
  SPREADSHEET_ID,
} from "../../config";
import { google } from "googleapis";
import * as fs from "fs";
import * as path from "path";

async function authorizeGoogleSheets() {
  const credentials = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, "utf8"));
  const scopes = ["https://www.googleapis.com/auth/spreadsheets"];
  return new google.auth.GoogleAuth({
    credentials,
    scopes,
  });
}

const saveDisableUsersToSpreadsheet = async () => {
  const users = await AUTH.listUsers();
  const disabledUsers = users.users.filter((user) => user.disabled);
  const rows = [
    ["participant_id", "email_address"],
    ...disabledUsers.map((user) => [user.uid, user.email || ""]),
  ];

  const auth = await authorizeGoogleSheets();
  const sheets = google.sheets({ version: "v4", auth });

  let spreadsheetId = SPREADSHEET_ID;
  if (!spreadsheetId) {
    // Create a new spreadsheet
    const createRes = await sheets.spreadsheets.create({
      requestBody: {
        properties: { title: "Disabled Participants" },
        sheets: [{ properties: { title: SHEET_NAME } }],
      },
    });
    spreadsheetId = createRes.data.spreadsheetId!;
    console.log(
      `Created new spreadsheet: https://docs.google.com/spreadsheets/d/${spreadsheetId}`
    );
  }

  // Write data to the sheet (replace all contents)
  await sheets.spreadsheets.values.update({
    spreadsheetId,
    range: `${SHEET_NAME}!A1`,
    valueInputOption: "RAW",
    requestBody: { values: rows },
  });
  console.log(
    `Wrote data to spreadsheet: https://docs.google.com/spreadsheets/d/${spreadsheetId}`
  );

  return {
    uids: disabledUsers.map((user) => user.uid),
    total: disabledUsers.length,
    spreadsheetId,
  };
};

saveDisableUsersToSpreadsheet();
