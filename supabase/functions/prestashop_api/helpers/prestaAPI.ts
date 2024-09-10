import { corsHeaders } from "../../_shared/cors.ts";
import { PrestaCredentials } from "./types.ts";

async function doGet(
    { credentials, endpoint }: {
        credentials: PrestaCredentials;
        endpoint: string;
    },
) {
    const headers = new Headers({
        "Authorization": `Basic ${btoa(`${credentials.apiKey}:`)}`,
        "Content-Type": "application/json",
    });

    const response = await fetch(`${credentials.url}/${endpoint}`, {
        method: "GET",
        headers: headers,
    });

    // if (!response.ok) {
    //     const error = await response.json();
    //     throw new Error(error.errors ?? "Unknown error");
    // }

    const text = await response.text();
    if (!text) {
        throw new Error("Empty response from server");
    }

    // Versuche, die Antwort als JSON zu parsen
    try {
        return JSON.parse(text);
    } catch (e) {
        throw new Error("Invalid JSON response: " + e.message);
    }
}

async function doPatch(
    { credentials, endpoint, xmlPayload }: {
        credentials: PrestaCredentials;
        endpoint: string;
        xmlPayload: string;
    },
) {
    const headers = new Headers({
        "Authorization": `Basic ${btoa(`${credentials.apiKey}:`)}`,
        "Content-Type": "application/xml",
    });

    const response = await fetch(`${credentials.url}/${endpoint}`, {
        method: "PATCH",
        headers: headers,
        body: xmlPayload,
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(error ?? "Unknown error");
    }

    return response;
}

async function doPost(
    { credentials, endpoint, formData }: {
        credentials: PrestaCredentials;
        endpoint: string;
        formData: FormData;
    },
) {
    const headers = new Headers({
        "Authorization": `Basic ${btoa(`${credentials.apiKey}:`)}`,
    });

    const response = await fetch(`${credentials.url}/${endpoint}`, {
        method: "POST",
        headers: headers,
        body: formData,
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(error ?? "Unknown error");
    }

    return response;
}

async function doDelete(
    { credentials, endpoint }: {
        credentials: PrestaCredentials;
        endpoint: string;
    },
) {
    const headers = new Headers({
        "Authorization": `Basic ${btoa(`${credentials.apiKey}:`)}`,
    });

    const response = await fetch(`${credentials.url}/${endpoint}`, {
        method: "DELETE",
        headers: headers,
    });

    if (!response.ok) {
        const error = await response.text();
        throw new Error(error ?? "Unknown error");
    }

    return response;
}

//* #############################################################################################################################
//* #############################################################################################################################
//* #############################################################################################################################

export async function getProduct(
    credentials: PrestaCredentials,
    productId: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint:
                `products?filter[id]=[${productId}]&output_format=JSON&display=full`,
        });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error on GET getProduct: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function getProductByReference(
    credentials: PrestaCredentials,
    reference: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint:
                `products?filter[reference]=[${reference}]&output_format=JSON&display=full`,
        });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getProductByReference: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getCategories(credentials: PrestaCredentials) {
    try {
        const data = await doGet({
            credentials,
            endpoint: `categories?output_format=JSON&display=full`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error on GET getCategories: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function getCategory(
    credentials: PrestaCredentials,
    categoryId: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint:
                `categories/${categoryId}?output_format=JSON&display=full`,
        });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error on GET getCategory: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function getStockAvailable(
    credentials: PrestaCredentials,
    stockAvailableId: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint:
                `stock_availables/${stockAvailableId}?output_format=JSON&display=full`,
        });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getStockAvailable: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getLanguages(credentials: PrestaCredentials) {
    try {
        const data = await doGet({
            credentials,
            endpoint: `languages?output_format=JSON&display=full`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error on GET getLanguages: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function patchProductQuantity(
    credentials: PrestaCredentials,
    stockAvailableId: string,
    xmlPayload: string,
) {
    try {
        const response = await doPatch({
            credentials,
            endpoint: `stock_availables/${stockAvailableId}`,
            xmlPayload,
        });

        return new Response(response.body, {
            status: response.status,
            headers: { ...corsHeaders, "Content-Type": "application/xml" },
        });
    } catch (error) {
        return new Response(
            "Error on PATCH patchProductQuantity: " + error.message,
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/plain",
                },
            },
        );
    }
}

export async function patchOrderStatus(
    credentials: PrestaCredentials,
    orderId: string,
    xmlPayload: string,
) {
    try {
        const response = await doPatch({
            credentials,
            endpoint: `orders/${orderId}`,
            xmlPayload,
        });

        return new Response(response.body, {
            status: response.status,
            headers: { ...corsHeaders, "Content-Type": "application/xml" },
        });
    } catch (error) {
        return new Response(
            "Error on PATCH patchOrderStatus: " + error.message,
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/plain",
                },
            },
        );
    }
}

export async function patchProduct(
    credentials: PrestaCredentials,
    productId: string,
    xmlPayload: string,
) {
    try {
        const response = await doPatch({
            credentials,
            endpoint: `products/${productId}`,
            xmlPayload,
        });

        return new Response(response.body, {
            status: response.status,
            headers: { ...corsHeaders, "Content-Type": "application/xml" },
        });
    } catch (error) {
        return new Response(
            "Error on PATCH patchProductQuantity: " + error.message,
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/plain",
                },
            },
        );
    }
}

export async function deleteProductImage(
    credentials: PrestaCredentials,
    productId: string,
    imageId: string,
) {
    try {
        const response = await doDelete({
            credentials,
            endpoint: `images/products/${productId}/${imageId}`,
        });

        return new Response(response.body, {
            status: response.status,
            headers: { ...corsHeaders, "Content-Type": "application/xml" },
        });
    } catch (error) {
        return new Response(
            "Error on DELETE deleteProductImage: " + error.message,
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/plain",
                },
            },
        );
    }
}

export async function uploadProductImage(
    credentials: PrestaCredentials,
    productId: string,
    productImage: { fileName: string; fileUrl: string },
) {
    const urlEndpoint = `images/products/${productId}/`;

    // Lade das Bild von der URL herunter
    const imageResponse = await fetch(productImage.fileUrl);
    if (!imageResponse.ok) {
        throw new Error(
            `Failed to download image from ${productImage.fileUrl}`,
        );
    }

    const imageData = await imageResponse.arrayBuffer(); // Äquivalent zu imageResponse.bodyBytes in Flutter
    const uint8ImageData = new Uint8Array(imageData); // Erstelle Uint8Array wie in Flutter

    // Hole die Dateierweiterung
    const fileExtension = getFileExtensionFromFilename(productImage.fileName);
    console.log(`File extension: ${fileExtension}`);

    // Erstellen eines FormData-Objekts für den Multipart-Upload
    const formData = new FormData();
    const blob = new Blob([uint8ImageData], { type: `image/${fileExtension}` });
    formData.append("image", blob, productImage.fileName);

    try {
        // Verwende die doPost Funktion
        await doPost({
            credentials,
            endpoint: urlEndpoint,
            formData,
        });

        console.log(`Image (${productImage.fileName}) uploaded successfully`);

        return new Response(
            JSON.stringify({ message: "Image uploaded successfully" }),
            {
                status: 200,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    } catch (error) {
        return new Response(
            "Error on PUT uploadProductImage: " + error.message,
            {
                status: 500,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/plain",
                },
            },
        );
    }
}

function getFileExtensionFromFilename(filename: string): string {
    const lastDot = filename.lastIndexOf(".");
    if (lastDot !== -1 && lastDot !== filename.length - 1) {
        return filename.substring(lastDot + 1);
    }
    return "unknown";
}
