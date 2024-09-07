export interface CollectShopifyJSON {
    collection_id: number;
    created_at: string;
    id: number;
    position: number;
    product_id: number;
    sort_value: string;
    updated_at: string;
}

export class CollectShopify {
    collectionId: number;
    createdAt: Date;
    id: number;
    position: number;
    productId: number;
    sortValue: string;
    updatedAt: Date;

    constructor(
        collectionId: number,
        createdAt: Date,
        id: number,
        position: number,
        productId: number,
        sortValue: string,
        updatedAt: Date,
    ) {
        this.collectionId = collectionId;
        this.createdAt = createdAt;
        this.id = id;
        this.position = position;
        this.productId = productId;
        this.sortValue = sortValue;
        this.updatedAt = updatedAt;
    }

    // Methode zum Erstellen einer Instanz aus einem JSON-Objekt mit bekanntem Typ
    static fromJson(json: CollectShopifyJSON): CollectShopify {
        return new CollectShopify(
            json.collection_id,
            new Date(json.created_at),
            json.id,
            json.position,
            json.product_id,
            json.sort_value,
            new Date(json.updated_at),
        );
    }

    // Methode zum Konvertieren einer Instanz in ein JSON-Objekt mit spezifischen Typen
    toJson(): CollectShopifyJSON {
        return {
            collection_id: this.collectionId,
            created_at: this.createdAt.toISOString(),
            id: this.id,
            position: this.position,
            product_id: this.productId,
            sort_value: this.sortValue,
            updated_at: this.updatedAt.toISOString(),
        };
    }

    // Methode zum Kopieren mit möglichen Änderungen (copyWith in Dart)
    copyWith(
        collectionId?: number,
        createdAt?: Date,
        id?: number,
        position?: number,
        productId?: number,
        sortValue?: string,
        updatedAt?: Date,
    ): CollectShopify {
        return new CollectShopify(
            collectionId ?? this.collectionId,
            createdAt ?? this.createdAt,
            id ?? this.id,
            position ?? this.position,
            productId ?? this.productId,
            sortValue ?? this.sortValue,
            updatedAt ?? this.updatedAt,
        );
    }
}
