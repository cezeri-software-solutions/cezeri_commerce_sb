// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
//////import "jsr:@supabase/functions-js/edge-runtime.d.ts"
//////
//////console.log("Hello from Functions!")
//////
//////Deno.serve(async (req) => {
//////  const { name } = await req.json()
//////  const data = {
//////    message: `Hello ${name}!`,
//////  }
//////
//////  return new Response(
//////    JSON.stringify(data),
//////    { headers: { "Content-Type": "application/json" } },
//////  )
//////})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/shopify_api' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/

//! supabase functions new shopify_api
//! supabase functions deploy shopify_api

import { corsHeaders } from "../_shared/cors.ts"; // Importiere die CORS-Header
import {
  getCustomCollectionsAll,
  getProductRawById,
  getProductsAllRaw,
} from "./helpers/shopifyAPI.ts";
import { getShopifyCredentials } from "./helpers/shopifyCredentials.ts";

console.log("Server startet...");

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    // Handle CORS preflight request
    return new Response(null, {
      headers: corsHeaders,
    });
  }

  try {
    const { marketplaceId, ownerId, functionName, productId } = await req
      .json();

    if (!marketplaceId || !ownerId || !functionName) {
      return new Response("Missing parameters", {
        status: 400,
        headers: corsHeaders,
      });
    }

    const credentials = await getShopifyCredentials(marketplaceId, ownerId);
    if (!credentials) {
      return new Response("Shopify credentials not found.", {
        status: 404,
        headers: corsHeaders,
      });
    }

    // Dynamischer Funktionsaufruf
    let response;
    switch (functionName) {
      case "getProductsAllRaw":
        response = await getProductsAllRaw(credentials);
        break;
      case "getProductRawById":
        if (!productId) {
          return new Response("Missing productId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getProductRawById(credentials, productId);
        break;
      case "getCustomCollectionsAll":
        response = await getCustomCollectionsAll(credentials);
        break;
      default:
        return new Response("Unknown function", {
          status: 400,
          headers: corsHeaders,
        });
    }

    // Füge CORS-Header in die Antwort ein
    return new Response(response.body, {
      status: response.status,
      headers: {
        ...corsHeaders,
        ...response.headers,
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    return new Response(`Error: ${error.message}`, {
      status: 500,
      headers: corsHeaders, // Setze die CORS-Header hier
    });
  }
});
