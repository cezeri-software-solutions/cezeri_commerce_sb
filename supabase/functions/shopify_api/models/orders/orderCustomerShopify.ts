// deno-lint-ignore-file

import {
    CustomerAddressShopify,
    CustomerAddressShopifyJSON,
} from "./customerAddressShopify.ts";

export class OrderCustomerShopify {
    id: number;
    createdAt: string;
    updatedAt: string;
    state: string;
    note?: string;
    verifiedEmail: boolean;
    multipassIdentifier?: string;
    taxExempt: boolean;
    emailMarketingConsent: any; // Struktur nicht bekannt, daher 'any'
    smsMarketingConsent: any; // Struktur nicht bekannt, daher 'any'
    tags: string;
    currency: string;
    taxExemptions: string[];
    adminGraphqlApiId: string;
    defaultAddress: CustomerAddressShopify;

    constructor(
        id: number,
        createdAt: string,
        updatedAt: string,
        state: string,
        note: string | undefined,
        verifiedEmail: boolean,
        multipassIdentifier: string | undefined,
        taxExempt: boolean,
        emailMarketingConsent: any,
        smsMarketingConsent: any,
        tags: string,
        currency: string,
        taxExemptions: string[],
        adminGraphqlApiId: string,
        defaultAddress: CustomerAddressShopify,
    ) {
        this.id = id;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.state = state;
        this.note = note;
        this.verifiedEmail = verifiedEmail;
        this.multipassIdentifier = multipassIdentifier;
        this.taxExempt = taxExempt;
        this.emailMarketingConsent = emailMarketingConsent;
        this.smsMarketingConsent = smsMarketingConsent;
        this.tags = tags;
        this.currency = currency;
        this.taxExemptions = taxExemptions;
        this.adminGraphqlApiId = adminGraphqlApiId;
        this.defaultAddress = defaultAddress;
    }

    static fromJson(json: OrderCustomerShopifyJSON): OrderCustomerShopify {
        return new OrderCustomerShopify(
            json.id,
            json.created_at,
            json.updated_at,
            json.state,
            json.note,
            json.verified_email,
            json.multipass_identifier,
            json.tax_exempt,
            json.email_marketing_consent,
            json.sms_marketing_consent,
            json.tags,
            json.currency,
            json.tax_exemptions,
            json.admin_graphql_api_id,
            CustomerAddressShopify.fromJson(json.default_address),
        );
    }

    toJson(): OrderCustomerShopifyJSON {
        return {
            id: this.id,
            created_at: this.createdAt,
            updated_at: this.updatedAt,
            state: this.state,
            note: this.note,
            verified_email: this.verifiedEmail,
            multipass_identifier: this.multipassIdentifier,
            tax_exempt: this.taxExempt,
            email_marketing_consent: this.emailMarketingConsent,
            sms_marketing_consent: this.smsMarketingConsent,
            tags: this.tags,
            currency: this.currency,
            tax_exemptions: this.taxExemptions,
            admin_graphql_api_id: this.adminGraphqlApiId,
            default_address: this.defaultAddress.toJson(),
        };
    }

    copyWith({
        id,
        createdAt,
        updatedAt,
        state,
        note,
        verifiedEmail,
        multipassIdentifier,
        taxExempt,
        emailMarketingConsent,
        smsMarketingConsent,
        tags,
        currency,
        taxExemptions,
        adminGraphqlApiId,
        defaultAddress,
    }: Partial<OrderCustomerShopify>): OrderCustomerShopify {
        return new OrderCustomerShopify(
            id ?? this.id,
            createdAt ?? this.createdAt,
            updatedAt ?? this.updatedAt,
            state ?? this.state,
            note ?? this.note,
            verifiedEmail ?? this.verifiedEmail,
            multipassIdentifier ?? this.multipassIdentifier,
            taxExempt ?? this.taxExempt,
            emailMarketingConsent ?? this.emailMarketingConsent,
            smsMarketingConsent ?? this.smsMarketingConsent,
            tags ?? this.tags,
            currency ?? this.currency,
            taxExemptions ?? this.taxExemptions,
            adminGraphqlApiId ?? this.adminGraphqlApiId,
            defaultAddress ?? this.defaultAddress,
        );
    }
}

export interface OrderCustomerShopifyJSON {
    id: number;
    created_at: string;
    updated_at: string;
    state: string;
    note?: string;
    verified_email: boolean;
    multipass_identifier?: string;
    tax_exempt: boolean;
    email_marketing_consent: any;
    sms_marketing_consent: any;
    tags: string;
    currency: string;
    tax_exemptions: string[];
    admin_graphql_api_id: string;
    default_address: CustomerAddressShopifyJSON;
}
