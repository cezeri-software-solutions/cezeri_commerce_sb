import { createClient } from "https://esm.sh/@supabase/supabase-js";

const supabaseUrl = Deno.env.get("SB_URL")!;
const supabaseKey = Deno.env.get("SB_KEY")!;
const supabase = createClient(supabaseUrl, supabaseKey);

export async function getShopifyCredentials(
    marketplaceId: string,
    ownerId: string,
) {
    const { data, error } = await supabase
        .from("d_marketplaces")
        .select(
            "storefrontAccessToken, adminAccessToken, endpointUrl, storeName, shopSuffix",
        )
        .eq("id", marketplaceId)
        .eq("ownerId", ownerId)
        .single();

    if (error) {
        console.error("Error fetching Shopify credentials:", error);
        return null;
    }

    return {
        storefrontToken: data.storefrontAccessToken,
        adminToken: data.adminAccessToken,
        url: `${data.endpointUrl}${data.storeName}.myshopify.com/${data.shopSuffix}`,
    };
}
