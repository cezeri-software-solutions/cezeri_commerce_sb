// deno-lint-ignore-file
import { corsHeaders } from "../../_shared/cors.ts";
import { ShopifyCredentials } from "./types.ts";

const apiVersion = "2024-01";

async function doGet(
    { credentials, endpoint }: {
        credentials: ShopifyCredentials;
        endpoint: string;
    },
) {
    const headers = new Headers({
        Authorization: `Basic ${
            btoa(`${credentials.storefrontToken}:${credentials.adminToken}`)
        }`,
        "Content-Type": "application/json",
    });

    const response = await fetch(
        `${credentials.url}/api/${apiVersion}/${endpoint}`,
        {
            method: "GET",
            headers: headers,
        },
    );

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors ?? "Unknown error");
    }

    return response.json();
}

async function doGetAll({
    credentials,
    endpoint,
    key,
}: {
    credentials: ShopifyCredentials;
    endpoint: string;
    key: string;
}) {
    const headers = new Headers({
        Authorization: `Basic ${
            btoa(`${credentials.storefrontToken}:${credentials.adminToken}`)
        }`,
        "Content-Type": "application/json",
    });

    let allItems: any[] = [];
    let nextUri: string | null =
        `${credentials.url}/api/${apiVersion}/${endpoint}?limit=250`;

    try {
        while (nextUri) {
            const response: Response = await fetch(nextUri, {
                method: "GET",
                headers: headers,
            });

            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.errors ?? "Unknown error");
            }

            const data = await response.json();
            allItems = [...allItems, ...data[key]];

            const linkHeader: string | null = response.headers.get("link");
            nextUri = linkHeader ? extractNextPageUrl(linkHeader) : null;
        }

        return allItems;
    } catch (error) {
        throw new Error(error.message || "Failed to fetch data.");
    }
}

export async function getProductsAllRaw(credentials: ShopifyCredentials) {
    try {
        const data = await doGet({ credentials, endpoint: "products.json" });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error fetching products: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function getProductRawById(
    credentials: ShopifyCredentials,
    productId: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint: `products/${productId}.json`,
        });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response("Error fetching product: " + error.message, {
            status: 500,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    }
}

export async function getCustomCollectionsAll(credentials: ShopifyCredentials) {
    try {
        const data = await doGetAll({
            credentials,
            endpoint: "custom_collections.json",
            key: "custom_collections",
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error fetching custom collections: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

function extractNextPageUrl(linkHeader: string): string | null {
    const regex = /<([^>]+)>;\s*rel="next"/;
    const match = linkHeader.match(regex);
    return match ? match[1] : null;
}
