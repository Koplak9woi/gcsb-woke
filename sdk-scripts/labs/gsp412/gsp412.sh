
echo "${YELLOW}${BOLD}Starting${RESET}" "${GREEN}${BOLD}Execution${RESET}"

cd ./labs/gsp412

# ============================================== Task 1 ================================================
bq mk ecommerce


# ============================================ TASK 4 =================================================

bq query --use_legacy_sql=false \
"
SELECT
  productSKU,
  COUNT(DISTINCT v2ProductName) AS product_count,
  STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name
FROM \`data-to-insights.ecommerce.all_sessions_raw\`
  WHERE v2ProductName IS NOT NULL
  GROUP BY productSKU
  HAVING product_count > 1
  ORDER BY product_count DESC
" &

bq query --use_legacy_sql=false \
"
WITH inventory_per_sku AS (
  SELECT DISTINCT
    website.v2ProductName,
    website.productSKU,
    inventory.stockLevel
  FROM \`data-to-insights.ecommerce.all_sessions_raw\` AS website
  JOIN \`data-to-insights.ecommerce.products\` AS inventory
    ON website.productSKU = inventory.SKU
    WHERE productSKU = 'GGOEGPJC019099'
)

SELECT
  productSKU,
  SUM(stockLevel) AS total_inventory
FROM inventory_per_sku
GROUP BY productSKU
" &

bq query --use_legacy_sql=false \
"
#standardSQL
CREATE OR REPLACE TABLE ecommerce.site_wide_promotion AS
SELECT .05 AS discount;
" & wait

bq query --use_legacy_sql=false \
"
#standardSQL
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM \`data-to-insights.ecommerce.all_sessions_raw\` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
AND productSKU = 'GGOEGOLC013299'
" 

echo "${RED}${BOLD}Congratulations${RESET}" "${WHITE}${BOLD}for${RESET}" "${GREEN}${BOLD}Completing the Lab !!!${RESET}"