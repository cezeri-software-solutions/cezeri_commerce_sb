import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.3";

const supabaseUrl = Deno.env.get("SB_URL")!;
const supabaseKey = Deno.env.get("SB_KEY")!;
const supabase = createClient(supabaseUrl, supabaseKey);

export async function getPrestaCredentials(
    marketplaceId: string,
    ownerId: string,
) {
    const { data, error } = await supabase
        .from("d_marketplaces")
        .select(
            "key, endpointUrl, url, shopSuffix",
        )
        .eq("id", marketplaceId)
        .eq("ownerId", ownerId)
        .single();

    if (error) {
        console.error("Error fetching PrestaShop credentials:", error);
        return null;
    }

    return {
        apiKey: data.key,
        url: `${data.endpointUrl}${data.url}${data.shopSuffix}`,
    };
}
