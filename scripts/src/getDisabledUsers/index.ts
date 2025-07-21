import { AUTH } from "../../config";
import * as fs from "fs";
import * as path from "path";

const getDisabledUsers = async () => {
  const users = await AUTH.listUsers();
  const disabledUsers = users.users.filter((user) => user.disabled);
  const rows = ["participant_id,email_address"];
  for (const user of disabledUsers) {
    rows.push(`${user.uid},${user.email || ""}`);
  }
  const csvContent = rows.join("\n");
  const outputDir = path.join(__dirname, "../../outputs");
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  const outputPath = path.join(outputDir, "DISABLED_PARTICIPANTS.csv");
  fs.writeFileSync(outputPath, csvContent);
  console.log(`CSV file created at: ${outputPath}`);
  return {
    uids: disabledUsers.map((user) => user.uid),
    total: disabledUsers.length,
  };
};

getDisabledUsers();