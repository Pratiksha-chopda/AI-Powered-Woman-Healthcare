const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();
const db = admin.firestore();

exports.chatWithAI = functions.https.onRequest(async (req, res) => {
  try {
    const { userId, message } = req.body;

    if (!userId || !message) {
      return res.status(400).send({ error: "Missing parameters" });
    }

    const HF_TOKEN = process.env.HF_TOKEN || "YOUR_HUGGINGFACE_TOKEN_HERE";
    const HF_MODEL = "microsoft/Phi-2";

    const prompt = `
      You are a women's health and PCOS support assistant.
      Provide safe, empathetic information.
      Do NOT diagnose diseases or give medical prescriptions.
      Only give general lifestyle, diet, emotional support.
      User question: ${message}
    `;

    const response = await fetch(
      `https://api-inference.huggingface.co/models/${HF_MODEL}`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${HF_TOKEN}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ inputs: prompt }),
      }
    );

    const result = await response.json();
    const botReply =
      result[0]?.generated_text ||
      "I'm here to support you ❤️ How can I help?";

    await db.collection("chats").add({
      user_id: userId,
      message,
      response: botReply,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).send({ reply: botReply });

  } catch (error) {
    console.error(error);
    res.status(500).send({ error: error.toString() });
  }
});
