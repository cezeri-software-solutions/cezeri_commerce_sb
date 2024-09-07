export class OrderShopifyTaxLine {
    channelLiable: boolean;
    price: string;
    priceSet: OrderShopifyPriceSet;
    rate: number;
    title: string;

    constructor(
        channelLiable: boolean,
        price: string,
        priceSet: OrderShopifyPriceSet,
        rate: number,
        title: string,
    ) {
        this.channelLiable = channelLiable;
        this.price = price;
        this.priceSet = priceSet;
        this.rate = rate;
        this.title = title;
    }

    static fromJson(json: OrderShopifyTaxLineJSON): OrderShopifyTaxLine {
        return new OrderShopifyTaxLine(
            json.channel_liable,
            json.price,
            OrderShopifyPriceSet.fromJson(json.price_set),
            json.rate,
            json.title,
        );
    }

    toJson(): OrderShopifyTaxLineJSON {
        return {
            channel_liable: this.channelLiable,
            price: this.price,
            price_set: this.priceSet.toJson(),
            rate: this.rate,
            title: this.title,
        };
    }
}

export interface OrderShopifyTaxLineJSON {
    channel_liable: boolean;
    price: string;
    price_set: OrderShopifyPriceSetJSON;
    rate: number;
    title: string;
}

export class OrderShopifyPriceSet {
    shopMoney: OrderShopifyAmountWithCurrencyCode;
    presentmentMoney: OrderShopifyAmountWithCurrencyCode;

    constructor(
        shopMoney: OrderShopifyAmountWithCurrencyCode,
        presentmentMoney: OrderShopifyAmountWithCurrencyCode,
    ) {
        this.shopMoney = shopMoney;
        this.presentmentMoney = presentmentMoney;
    }

    static fromJson(json: OrderShopifyPriceSetJSON): OrderShopifyPriceSet {
        return new OrderShopifyPriceSet(
            OrderShopifyAmountWithCurrencyCode.fromJson(json.shop_money),
            OrderShopifyAmountWithCurrencyCode.fromJson(json.presentment_money),
        );
    }

    toJson(): OrderShopifyPriceSetJSON {
        return {
            shop_money: this.shopMoney.toJson(),
            presentment_money: this.presentmentMoney.toJson(),
        };
    }
}

export interface OrderShopifyPriceSetJSON {
    shop_money: OrderShopifyAmountWithCurrencyCodeJSON;
    presentment_money: OrderShopifyAmountWithCurrencyCodeJSON;
}

export class OrderShopifyAmountWithCurrencyCode {
    amount: string;
    currencyCode: string;

    constructor(amount: string, currencyCode: string) {
        this.amount = amount;
        this.currencyCode = currencyCode;
    }

    static fromJson(
        json: OrderShopifyAmountWithCurrencyCodeJSON,
    ): OrderShopifyAmountWithCurrencyCode {
        return new OrderShopifyAmountWithCurrencyCode(
            json.amount,
            json.currency_code,
        );
    }

    toJson(): OrderShopifyAmountWithCurrencyCodeJSON {
        return {
            amount: this.amount,
            currency_code: this.currencyCode,
        };
    }
}

export interface OrderShopifyAmountWithCurrencyCodeJSON {
    amount: string;
    currency_code: string;
}
