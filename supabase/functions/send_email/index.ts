console.log("Server startet send_email...");

import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    // Handling der Preflight-Anfrage
    return new Response(null, {
      headers: corsHeaders,
    });
  }

  try {
    const { to, from, bcc, subject, html, attachment, filename } = await req
      .json();

    const SENDGRID_API_KEY = Deno.env.get("SENDGRID_API_KEY");

    if (!SENDGRID_API_KEY) {
      console.error("SendGrid API key nicht gesetzt");
      return new Response("SendGrid API key not set in environment variables", {
        status: 500,
        headers: corsHeaders, // CORS-Header auch bei Fehler setzen
      });
    }

    const headers = {
      Authorization: `Bearer ${SENDGRID_API_KEY}`,
      "Content-Type": "application/json",
      apikey: SENDGRID_API_KEY, // Falls dieser apikey für die Supabase-Funktion notwendig ist
    };

    const attachments = attachment
      ? [
        {
          content: attachment,
          filename: filename || "attachment.pdf",
          type: "application/pdf",
          disposition: "attachment",
        },
      ]
      : [];

    const bccList = Array.isArray(bcc)
      ? bcc.map((bccEmail: string) => ({ email: bccEmail }))
      : bcc
      ? [{ email: bcc }]
      : undefined;

    const body = JSON.stringify({
      personalizations: [
        {
          to: [{ email: to }],
          subject: subject,
          bcc: bccList,
        },
      ],
      from: { email: from },
      content: [
        {
          type: "text/html",
          value: html,
        },
      ],
      attachments: attachments.length > 0 ? attachments : undefined,
    });

    console.log("Sende Anfrage an SendGrid API...");

    const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
      method: "POST",
      headers,
      body,
    });

    if (response.ok) {
      console.log("E-Mail erfolgreich gesendet");
      return new Response(
        JSON.stringify({ message: "E-Mail erfolgreich gesendet" }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    } else {
      const errorText = await response.text();
      console.error("Fehler beim Senden der E-Mail:", errorText);
      return new Response(
        JSON.stringify({
          success: false,
          message: `Fehler beim Senden der E-Mail: ${errorText}`,
        }),
        {
          status: 500,
          headers: corsHeaders, // CORS-Header auch bei Fehler setzen
        },
      );
    }
  } catch (error) {
    console.error("Fehler beim Verarbeiten der Anfrage:", error);
    return new Response("Interner Serverfehler", {
      status: 500,
      headers: corsHeaders, // CORS-Header auch bei Fehler setzen
    });
  }
});
