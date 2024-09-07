// deno-lint-ignore-file
export class InventoryLevelShopify {
    available?: number;
    inventoryItemId: number;
    locationId: number;
    updatedAt: Date;

    constructor(
        available: number | undefined,
        inventoryItemId: number,
        locationId: number,
        updatedAt: Date,
    ) {
        this.available = available;
        this.inventoryItemId = inventoryItemId;
        this.locationId = locationId;
        this.updatedAt = updatedAt;
    }

    static fromJson(json: { [key: string]: any }): InventoryLevelShopify {
        return new InventoryLevelShopify(
            json["available"],
            json["inventory_item_id"],
            json["location_id"],
            new Date(json["updated_at"]),
        );
    }

    toJson(): { [key: string]: any } {
        return {
            available: this.available,
            inventory_item_id: this.inventoryItemId,
            location_id: this.locationId,
            updated_at: this.updatedAt.toISOString(),
        };
    }
}
