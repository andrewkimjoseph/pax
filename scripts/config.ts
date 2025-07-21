import * as admin from "firebase-admin";

var serviceAccount = require("./env/thepaxapp-firebase-adminsdk-fbsvc-d9e8b1fdff.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export const AUTH = admin.auth();