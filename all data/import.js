const admin = require('firebase-admin');
const serviceAccount = require("./serviceAccountKey.json");
const data = require("./data.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadData() {
  for (const item of data.medicines) {
    await db.collection('medicines_list').add(item);
    console.log(`✅ Uploaded: ${item.name}`);
  }
  console.log("🚀 Mission Successful: Saara data Firestore mein hai!");
}

uploadData();