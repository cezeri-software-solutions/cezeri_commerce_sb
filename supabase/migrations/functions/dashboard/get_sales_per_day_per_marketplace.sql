CREATE OR REPLACE FUNCTION "public"."get_sales_per_day_per_marketplace"("owner_id" "text", "start_date" "date", "end_date" "date") RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(
            jsonb_build_object(
                'date', date,
                'list_of_stat_sales_per_day_per_marketplace', list_of_stat_sales_per_day_per_marketplace
            )
        )
        FROM (
            SELECT
                date,
                jsonb_agg(
                    jsonb_build_object(
                        'marketplace_id', marketplace_id,
                        'marketplace_name', marketplace_name,
                        'total_net_sum', total_net_sum,
                        'count', count,
                        'date', date
                    )
                ) AS list_of_stat_sales_per_day_per_marketplace
            FROM (
                SELECT
                    DATE(di."creationDate") AS date,
                    di."marketplaceId" AS marketplace_id,
                    mkt."name" AS marketplace_name,
                    COUNT(*) AS count,
                    SUM(CASE WHEN di."receiptTyp" = 'credit' THEN di."totalNet" * -1 ELSE di."totalNet" END) AS total_net_sum
                FROM d_invoices di
                JOIN d_marketplaces mkt ON di."marketplaceId" = mkt."id"
                WHERE di."ownerId" = owner_id
                  AND di."creationDate" >= start_date
                  AND di."creationDate" < end_date
                GROUP BY DATE(di."creationDate"), di."marketplaceId", mkt."name"
            ) daily_sales
            GROUP BY date
        ) final_agg
    );
END;
$$;


