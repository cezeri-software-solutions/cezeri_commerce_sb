// deno-lint-ignore-file
export class InventoryItemShopify {
    cost?: number;
    countryCodeOfOrigin?: string;
    countryHarmonizedSystemCodes?: string[];
    createdAt: Date;
    harmonizedSystemCode?: string;
    id: number;
    provinceCodeOfOrigin?: string;
    sku: string;
    tracked: boolean;
    updatedAt: Date;
    requiresShipping: boolean;

    constructor(
        cost: number | undefined,
        countryCodeOfOrigin: string | undefined,
        countryHarmonizedSystemCodes: string[] | undefined,
        createdAt: Date,
        harmonizedSystemCode: string | undefined,
        id: number,
        provinceCodeOfOrigin: string | undefined,
        sku: string,
        tracked: boolean,
        updatedAt: Date,
        requiresShipping: boolean,
    ) {
        this.cost = cost;
        this.countryCodeOfOrigin = countryCodeOfOrigin;
        this.countryHarmonizedSystemCodes = countryHarmonizedSystemCodes;
        this.createdAt = createdAt;
        this.harmonizedSystemCode = harmonizedSystemCode;
        this.id = id;
        this.provinceCodeOfOrigin = provinceCodeOfOrigin;
        this.sku = sku;
        this.tracked = tracked;
        this.updatedAt = updatedAt;
        this.requiresShipping = requiresShipping;
    }

    static fromJson(json: { [key: string]: any }): InventoryItemShopify {
        return new InventoryItemShopify(
            json["cost"],
            json["country_code_of_origin"],
            json["country_harmonized_system_codes"],
            new Date(json["created_at"]),
            json["harmonized_system_code"],
            json["id"],
            json["province_code_of_origin"],
            json["sku"],
            json["tracked"],
            new Date(json["updated_at"]),
            json["requires_shipping"],
        );
    }

    toJson(): { [key: string]: any } {
        return {
            cost: this.cost,
            country_code_of_origin: this.countryCodeOfOrigin,
            country_harmonized_system_codes: this.countryHarmonizedSystemCodes,
            created_at: this.createdAt.toISOString(),
            harmonized_system_code: this.harmonizedSystemCode,
            id: this.id,
            province_code_of_origin: this.provinceCodeOfOrigin,
            sku: this.sku,
            tracked: this.tracked,
            updated_at: this.updatedAt.toISOString(),
            requires_shipping: this.requiresShipping,
        };
    }
}
