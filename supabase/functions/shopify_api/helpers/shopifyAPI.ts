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

async function doPost(
    { credentials, endpoint, body }: {
        credentials: ShopifyCredentials;
        endpoint: string;
        body: string;
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
            method: "POST",
            headers: headers,
            body: body,
        },
    );

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors ?? "Unknown error");
    }

    return response.json();
}

async function doPut(
    { credentials, endpoint, body }: {
        credentials: ShopifyCredentials;
        endpoint: string;
        body: string;
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
            method: "PUT",
            headers: headers,
            body: body,
        },
    );

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors ?? "Unknown error");
    }

    return; // Equivalent to returning `const Right(unit)` in Dart
}

async function doDelete(
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
            method: "DELETE",
            headers: headers,
        },
    );

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.errors ?? "Unknown error");
    }

    return; // Equivalent to returning `const Right(unit)` in Dart
}

//* #############################################################################################################################
//* #############################################################################################################################
//* #############################################################################################################################

export async function getProductsAllRaw(credentials: ShopifyCredentials) {
    try {
        const data = await doGet({ credentials, endpoint: "products.json" });
        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getProductsAllRaw: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
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
        return new Response(
            "Error on GET getProductRawById: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getInventoryLevelByInventoryItemId(
    credentials: ShopifyCredentials,
    inventoryItemId: string,
) {
    try {
        // Wir holen die Daten mit dem entsprechenden Endpoint
        const data = await doGet({
            credentials,
            endpoint:
                `inventory_levels.json?inventory_item_ids=${inventoryItemId}`,
        });

        // Wenn wir mehrere Lagerbestände zurückbekommen, geben wir das erste Element zurück
        const inventoryLevels = data.inventory_levels;

        if (inventoryLevels.length === 0) {
            throw new Error(
                "No inventory levels found for this inventory item.",
            );
        }

        return new Response(JSON.stringify(inventoryLevels[0]), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error:
                    `Error on GET getInventoryLevelByInventoryItemId: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getCustomCollectionsAll(credentials: ShopifyCredentials) {
    const key = "custom_collections";

    try {
        const data = await doGetAll({
            credentials,
            endpoint: `${key}.json`,
            key: `${key}`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET ALL getCustomCollectionsAll: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getCollectsOfProduct(
    credentials: ShopifyCredentials,
    productId: string,
) {
    const key = "collects";

    try {
        const data = await doGet({
            credentials,
            endpoint: `${key}.json?product_id=${productId}`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getCollectsOfProduct: " + error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getCustomCollectionsByProductId(
    credentials: ShopifyCredentials,
    productId: string,
) {
    const key = "custom_collections";

    try {
        const data = await doGet({
            credentials,
            endpoint: `${key}.json?product_id=${productId}`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getCustomCollectionsByProductId: " +
                error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function getOrderFulfillmentsOfFulfillmentOrder(
    credentials: ShopifyCredentials,
    orderId: string,
) {
    try {
        const data = await doGet({
            credentials,
            endpoint: `orders/${orderId}/fulfillment_orders.json`,
        });

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            "Error on GET getOrderFulfillmentsOfFulfillmentOrder: " +
                error.message,
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function postInventoryItemAvailability(
    credentials: ShopifyCredentials,
    postBody: string,
) {
    try {
        const body = JSON.stringify(postBody);

        // POST-Anfrage zum Aktualisieren des Lagerbestands
        const inventoryResult = await doPost({
            credentials,
            endpoint: `inventory_levels/set.json`,
            body,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error:
                    `Error on POST postInventoryItemAvailability: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function postCollect(
    credentials: ShopifyCredentials,
    postBody: string,
) {
    try {
        const body = JSON.stringify(postBody);

        // POST-Anfrage zum Aktualisieren des Lagerbestands
        const inventoryResult = await doPost({
            credentials,
            endpoint: `collects.json`,
            body,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on POST postCollect: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function postFulfillment(
    credentials: ShopifyCredentials,
    postBody: string,
) {
    try {
        const body = JSON.stringify(postBody);

        // POST-Anfrage zum Aktualisieren des Bestellstatus
        const inventoryResult = await doPost({
            credentials,
            endpoint: `fulfillments.json`,
            body,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on POST postFulfillment: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function postProductImage(
    credentials: ShopifyCredentials,
    productId: string,
    postBody: string,
) {
    try {
        const body = JSON.stringify(postBody);

        // POST-Anfrage zum Hochladen von Bildern
        const inventoryResult = await doPost({
            credentials,
            endpoint: `products/${productId}/images.json`,
            body,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on POST postProductImage: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function putProduct(
    credentials: ShopifyCredentials,
    productId: string,
    postBody: string,
) {
    try {
        const body = JSON.stringify(postBody);

        // PUT-Anfrage zum Aktualisieren des Lagerbestands
        const inventoryResult = await doPut({
            credentials,
            endpoint: `products/${productId}.json`,
            body,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on PUT putProduct: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function deleteCollect(
    credentials: ShopifyCredentials,
    collectId: string,
) {
    try {
        // DELETE-Anfrage zum Aktualisieren des Lagerbestands
        const inventoryResult = await doDelete({
            credentials,
            endpoint: `collects/${collectId}.json`,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on DELETE deleteCollect: ${error.message}`,
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            },
        );
    }
}

export async function deleteProductImage(
    credentials: ShopifyCredentials,
    productId: string,
    imageId: string,
) {
    try {
        // DELETE-Anfrage zum Löschen von einem Artikelbild
        const inventoryResult = await doDelete({
            credentials,
            endpoint: `products/${productId}/images/${imageId}.json`,
        });

        return new Response(JSON.stringify(inventoryResult), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        return new Response(
            JSON.stringify({
                error: `Error on DELETE deleteProductImage: ${error.message}`,
            }),
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
