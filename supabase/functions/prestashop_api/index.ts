//! supabase functions new prestashop_api
//! supabase functions deploy prestashop_api

import { corsHeaders } from "../_shared/cors.ts"; // Importiere die CORS-Header
import {
  deleteProductImage,
  getCategories,
  getCategory,
  getLanguages,
  getProduct,
  getProductByReference,
  getStockAvailable,
  patchOrderStatus,
  patchProduct,
  patchProductQuantity,
  uploadProductImage,
} from "./helpers/prestaAPI.ts";

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
      imageId,
      orderId,
      reference,
      categoryId,
      xmlPayload,
      stockAvailableId,
      productImage,
    } = await req.json();

    // if (!marketplaceId || !ownerId || !functionName) {
    //   return new Response("Missing parameters", {
    //     status: 400,
    //     headers: corsHeaders,
    //   });
    // }

    // const credentials = await getPrestaCredentials(marketplaceId, ownerId);
    // if (!credentials) {
    //   return new Response("PrestaShop credentials not found.", {
    //     status: 404,
    //     headers: corsHeaders,
    //   });
    // }

    // Dynamischer Funktionsaufruf
    let response;
    switch (functionName) {
      case "getProduct":
        if (!productId) {
          return new Response("Missing productId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getProduct(credentials, productId);
        break;
      case "getProductByReference":
        if (!reference) {
          return new Response("Missing product reference", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getProductByReference(credentials, reference);
        break;
      case "getCategories":
        response = await getCategories(credentials);
        break;
      case "getCategory":
        if (!categoryId) {
          return new Response("Missing categoryId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getCategory(credentials, categoryId);
        break;
      case "getStockAvailable":
        if (stockAvailableId == null) {
          return new Response("Missing stockAvailableId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await getStockAvailable(credentials, stockAvailableId);
        break;
      case "getLanguages":
        response = await getLanguages(credentials);
        break;
      case "patchProductQuantity":
        if (!stockAvailableId || xmlPayload == null) {
          return new Response("Missing stockAvailableId or xmlPayload", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await patchProductQuantity(
          credentials,
          stockAvailableId,
          xmlPayload,
        );

        return new Response(response.body, {
          status: response.status,
          headers: {
            ...corsHeaders,
            ...response.headers,
            "Content-Type": "application/xml",
          },
        });
      case "patchProduct":
        if (productId == null || xmlPayload == null) {
          return new Response("Missing productId or xmlPayload", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await patchProduct(
          credentials,
          productId,
          xmlPayload,
        );

        return new Response(response.body, {
          status: response.status,
          headers: {
            ...corsHeaders,
            ...response.headers,
            "Content-Type": "application/xml",
          },
        });
      case "patchOrderStatus":
        if (orderId == null || xmlPayload == null) {
          return new Response("Missing orderId or xmlPayload", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await patchOrderStatus(
          credentials,
          orderId,
          xmlPayload,
        );

        return new Response(response.body, {
          status: response.status,
          headers: {
            ...corsHeaders,
            ...response.headers,
            "Content-Type": "application/xml",
          },
        });
      case "deleteProductImage":
        if (productId == null || imageId == null) {
          return new Response("Missing productId or imageId", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await deleteProductImage(credentials, productId, imageId);
        break;
      case "uploadProductImage":
        if (productId == null || productImage == null) {
          return new Response("Missing productId or productImage", {
            status: 400,
            headers: corsHeaders,
          });
        }
        response = await uploadProductImage(
          credentials,
          productId,
          productImage,
        );
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
      headers: corsHeaders,
    });
  }
});
