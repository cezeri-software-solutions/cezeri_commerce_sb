import { MetafieldShopify, MetafieldShopifyJSON } from "../metafieldShopify.ts";
import { CollectShopify, CollectShopifyJSON } from "./collectShopify.ts";
import {
  CustomCollectionShopify,
  CustomCollectionShopifyJSON,
} from "./customCollectionShopify.ts";
import {
  ProductImageShopify,
  ProductImageShopifyJSON,
} from "./productImageShopify.ts";
import {
  ProductOptionShopify,
  ProductOptionShopifyJSON,
} from "./productRawShopify.ts";
import {
  ProductVariantShopify,
  ProductVariantShopifyJSON,
} from "./productVariantShopify.ts";

export enum ProductShopifyStatus {
  Active = "active",
  Archived = "archived",
  Draft = "draft",
}

export class ProductShopify {
  id: number;
  title: string;
  bodyHtml: string;
  handle: string;
  images: ProductImageShopify[];
  options: ProductOptionShopify[];
  variants: ProductVariantShopify[];
  metafields: MetafieldShopify[];
  collects: CollectShopify[];
  customCollections: CustomCollectionShopify[];
  vendor: string;
  productType: string;
  publishedAt?: Date;
  publishedScope: string;
  status: ProductShopifyStatus;
  tags: string;
  templateSuffix?: string;
  updatedAt?: Date;
  createdAt?: Date;

  constructor(
    id: number,
    title: string,
    bodyHtml: string,
    handle: string,
    images: ProductImageShopify[],
    options: ProductOptionShopify[],
    variants: ProductVariantShopify[],
    metafields: MetafieldShopify[],
    collects: CollectShopify[],
    customCollections: CustomCollectionShopify[],
    vendor: string,
    productType: string,
    publishedScope: string,
    status: ProductShopifyStatus,
    tags: string,
    updatedAt?: Date,
    createdAt?: Date,
    publishedAt?: Date,
    templateSuffix?: string,
  ) {
    this.id = id;
    this.title = title;
    this.bodyHtml = bodyHtml;
    this.handle = handle;
    this.images = images;
    this.options = options;
    this.variants = variants;
    this.metafields = metafields;
    this.collects = collects;
    this.customCollections = customCollections;
    this.vendor = vendor;
    this.productType = productType;
    this.publishedAt = publishedAt;
    this.publishedScope = publishedScope;
    this.status = status;
    this.tags = tags;
    this.templateSuffix = templateSuffix;
    this.updatedAt = updatedAt;
    this.createdAt = createdAt;
  }

  static fromJson(json: ProductShopifyJSON): ProductShopify {
    return new ProductShopify(
      json.id,
      json.title,
      json.body_html,
      json.handle,
      json.images.map(ProductImageShopify.fromJson),
      json.options.map(ProductOptionShopify.fromJson),
      json.variants.map(ProductVariantShopify.fromJson),
      json.metafields.map(MetafieldShopify.fromJson),
      json.collects.map(CollectShopify.fromJson),
      json.custom_collections.map(CustomCollectionShopify.fromJson),
      json.vendor,
      json.product_type,
      json.published_scope,
      ProductShopify._statusFromJson(json.status),
      json.tags,
      json.updated_at ? new Date(json.updated_at) : undefined,
      json.created_at ? new Date(json.created_at) : undefined,
      json.published_at ? new Date(json.published_at) : undefined,
      json.template_suffix,
    );
  }

  toJson(): ProductShopifyJSON {
    return {
      id: this.id,
      title: this.title,
      body_html: this.bodyHtml,
      handle: this.handle,
      images: this.images.map((image) => image.toJson()),
      options: this.options.map((option) => option.toJson()),
      variants: this.variants.map((variant) => variant.toJson()),
      metafields: this.metafields.map((metafield) => metafield.toJson()),
      collects: this.collects.map((collect) => collect.toJson()),
      custom_collections: this.customCollections.map((collection) =>
        collection.toJson()
      ),
      vendor: this.vendor,
      product_type: this.productType,
      published_scope: this.publishedScope,
      status: ProductShopify._statusToJson(this.status),
      tags: this.tags,
      updated_at: this.updatedAt?.toISOString(),
      created_at: this.createdAt?.toISOString(),
      published_at: this.publishedAt?.toISOString(),
      template_suffix: this.templateSuffix,
    };
  }

  static _statusFromJson(value: string): ProductShopifyStatus {
    switch (value) {
      case "active":
        return ProductShopifyStatus.Active;
      case "archived":
        return ProductShopifyStatus.Archived;
      case "draft":
        return ProductShopifyStatus.Draft;
      default:
        throw new Error(`Unknown product status: ${value}`);
    }
  }

  static _statusToJson(status: ProductShopifyStatus): string {
    return status.toString().split(".").pop()!;
  }

  copyWith({
    id,
    title,
    bodyHtml,
    handle,
    images,
    options,
    variants,
    metafields,
    collects,
    customCollections,
    vendor,
    productType,
    publishedAt,
    publishedScope,
    status,
    tags,
    templateSuffix,
    updatedAt,
    createdAt,
  }: Partial<ProductShopify>): ProductShopify {
    return new ProductShopify(
      id ?? this.id,
      title ?? this.title,
      bodyHtml ?? this.bodyHtml,
      handle ?? this.handle,
      images ?? this.images,
      options ?? this.options,
      variants ?? this.variants,
      metafields ?? this.metafields,
      collects ?? this.collects,
      customCollections ?? this.customCollections,
      vendor ?? this.vendor,
      productType ?? this.productType,
      publishedScope ?? this.publishedScope,
      status ?? this.status,
      tags ?? this.tags,
      updatedAt ?? this.updatedAt,
      createdAt ?? this.createdAt,
      publishedAt ?? this.publishedAt,
      templateSuffix ?? this.templateSuffix,
    );
  }
}

export interface ProductShopifyJSON {
  id: number;
  title: string;
  body_html: string;
  handle: string;
  images: ProductImageShopifyJSON[];
  options: ProductOptionShopifyJSON[];
  variants: ProductVariantShopifyJSON[];
  metafields: MetafieldShopifyJSON[];
  collects: CollectShopifyJSON[];
  custom_collections: CustomCollectionShopifyJSON[];
  vendor: string;
  product_type: string;
  published_scope: string;
  status: string;
  tags: string;
  template_suffix?: string;
  updated_at?: string;
  created_at?: string;
  published_at?: string;
}
