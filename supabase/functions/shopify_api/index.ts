//! supabase functions new shopify_api
//! supabase functions deploy shopify_api

import { corsHeaders } from "../_shared/cors.ts"; // Importiere die CORS-Header
import {
  deleteCollect,
  deleteProductImage,
  getCollectsOfProduct,
  getCustomCollectionsAll,
  getCustomCollectionsByProductId,
  getInventoryLevelByInventoryItemId,
  getOrderFulfillmentsOfFulfillmentOrder,
  getProductRawById,
  getProductsAllRaw,
  postCollect,
  postFulfillment,
  postInventoryItemAvailability,
  postProductImage,
  putProduct,
} from "./helpers/shopifyAPI.ts";

console.log("Server startet...");

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    // Handle CORS preflight request
    return new Response(null, {
      headers: corsHeaders,
    });
  }

  try {
    const {
      credentials,
      functionName,
      productId,
      inventoryItemId,
      collectId,
      imageId,
      orderId,
      postBody,
    } = await req.json();

    // if (!marketplaceId || !ownerId || !functionName) {
    //   return new Response("Missing parameters", {
    //     status: 400,
    //     headers: corsHeaders,
    //   });
    // }

    // const credentials = await getShopifyCredentials(marketplaceId, ownerId);
    // if (!credentials) {
    //   return new Response("Shopify credentials not found.", {
    //     status: 404,
    //     headers: corsHeaders,
    //   });
    // }

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
      case "getInventoryLevelByInventoryItemId":
        if (!inventoryItemId) {
          return new Response("Missing inventoryItemId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getInventoryLevelByInventoryItemId(
          credentials,
          inventoryItemId,
        );
        break;
      case "getOrderFulfillmentsOfFulfillmentOrder":
        if (orderId == null) {
          return new Response("Missing orderId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getOrderFulfillmentsOfFulfillmentOrder(
          credentials,
          orderId,
        );
        break;
      case "getCustomCollectionsAll":
        response = await getCustomCollectionsAll(credentials);
        break;
      case "getCollectsOfProduct":
        if (!productId) {
          return new Response("Missing productId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getCollectsOfProduct(credentials, productId);
        break;
      case "getCustomCollectionsByProductId":
        if (!productId) {
          return new Response("Missing productId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getCustomCollectionsByProductId(
          credentials,
          productId,
        );
        break;

      case "postInventoryItemAvailability":
        if (postBody == null) {
          return new Response(
            "Missing postBody",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await postInventoryItemAvailability(credentials, postBody);
        break;
      case "postProductImage":
        if (productId == null || postBody == null) {
          return new Response(
            "Missing productId or postBody",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await postProductImage(credentials, productId, postBody);
        break;
      case "postCollect":
        if (postBody == null) {
          return new Response(
            "Missing postBody",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await postCollect(credentials, postBody);
        break;
      case "postFulfillment":
        if (postBody == null) {
          return new Response(
            "Missing postBody",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await postFulfillment(credentials, postBody);
        break;
      case "putProduct":
        if (postBody == null || productId == null) {
          return new Response(
            "Missing postBody or productId",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await putProduct(credentials, productId, postBody);
        break;
      case "deleteCollect":
        if (collectId == null) {
          return new Response(
            "Missing collectId",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await deleteCollect(credentials, collectId);
        break;
      case "deleteProductImage":
        if (productId == null || imageId == null) {
          return new Response(
            "Missing productId or imageId",
            {
              status: 400,
              headers: corsHeaders,
            },
          );
        }
        response = await deleteProductImage(credentials, productId, imageId);
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
