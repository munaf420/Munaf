Select * from dbo.Brands
Select * from dbo.Finance
Select * from dbo.Info
Select * from dbo.Reviews
Select * from dbo.Traffic

--- Count the total number of products along with the number of non-missing values in description, listing_price, and last_visited

SELECT COUNT(Info.product_name) as total_rows,
COUNT(info.description) as count_description, COUNT(finance.listing_price) as count_listing_price,
COUNT(traffic.last_visited) as count_last_visited
FROM info
INNER JOIN traffic
ON traffic.product_id = info.product_id
INNEr JOIN finance
ON finance.product_id = info.product_id

---> total_rows`: The total number of rows or entries in the analyzed dataset is 3,120 rows.
---> count_description`: The total number of entries in the “description” column that have non-empty values is 3,117 entries.
---> count_listing_price`: The total number of entries in the “listing_price” column that have non-empty values is 3,120 entries.
---> count_last_visited`: The total number of entries in the “last_visited” column that have non-empty values is 2,928 entries.

/*
We can see the database contains 3,120 products in total. Of the columns we previewed, only one — last_visited — is missing more than five percent of its values. Now let's turn our attention to pricing.
How do the price points of Nike and Adidas products differ? Answering this question can help us build a picture of the company’s stock range and customer market. We will run a query to produce a 
distribution of the listing_price and the count for each price, grouped by brand
*/

--- Nike vs Adidas Pricing
SELECT b.brand, CAST(f.listing_price AS INTEGER) as listing_price, COUNT (f.product_id) as Total_Count
FROM brands b
INNER JOIN finance f
ON f.product_id = b.product_id
WHERE f.listing_price > 0
GROUP BY b.brand, f.listing_price
ORDER BY f.listing_price DESC


---Labeling price ranges

/*
It turns out there are 77 unique prices for the products in our database, which makes the output of our last query quite difficult to analyze.
Let’s build on our previous query by assigning labels to different price ranges, grouping by brand and label. We will also include the total revenue for each price range and brand.
*/

SELECT
  b.brand,
  COUNT(*) AS num_products,
  SUM(f.revenue) AS total_revenue,
  CASE
    WHEN f.listing_price < 42 THEN 'Budget'
    WHEN f.listing_price >= 42 AND f.listing_price < 74 THEN 'Average'
    WHEN f.listing_price >= 74 AND f.listing_price < 129 THEN 'Expensive'
    ELSE 'Elite'
  END AS price_category
FROM
  finance AS f
  INNER JOIN brands AS b ON f.product_id = b.product_id
WHERE
  b.brand IS NOT NULL
GROUP BY
  b.brand, 
  CASE
    WHEN f.listing_price < 42 THEN 'Budget'
    WHEN f.listing_price >= 42 AND f.listing_price < 74 THEN 'Average'
    WHEN f.listing_price >= 74 AND f.listing_price < 129 THEN 'Expensive'
    ELSE 'Elite'
  END
ORDER BY
  total_revenue DESC;

/*
The brand “Adidas” offers a variety of products with different price ranges. The majority of Adidas products fall into the “Average” category, totaling 1060 products. However, the brand also excels in the
“Expensive” category, generating a total revenue of $4,626,980.07. Additionally, Adidas presents luxury products in the “Elite” category, although the quantity is lower (307 products), they contribute 
significantly to a total revenue of $3,014,316.83. Affordable products are not neglected, as the brand offers 359 products in the “Budget” category, even though the total revenue from this category is lower.

On the other hand, the brand “Nike” also exhibits price variation in its products. Products in the “Budget” category are the primary choice for customers, amounting to 357 products, representing the 
majority of sales. Despite their large quantity, the total revenue from this category is lower compared to the “Adidas” brand, totaling $595,341.02. On the flip side, Nike also presents luxury products in
the “Elite” category, with a smaller quantity (82 products), yet generating a total revenue of $128,475.59. Notably, Nike’s products in the “Expensive” and “Average” categories also contribute significantly
to the total revenue.
*/
--- Correlation between revenue and reviews
/*
To improve revenue further, the company could try to reduce the amount of discount offered on Adidas products, and monitor sales volume to see if it remains stable. Alternatively, it could try offering a
small discount on Nike products. This would reduce average revenue for these products, but may increase revenue overall if there is an increase in the volume of Nike products sold.
*/

SELECT
    SUM(reviews.reviews * finance.revenue) / NULLIF(SQRT(SUM(reviews.reviews * reviews.reviews) * SUM(finance.revenue * finance.revenue)), 0) AS review_revenue_corr
FROM
    reviews
INNER JOIN finance ON finance.product_id = reviews.product_id

/*
The correlation result between revenue and reviews is approximately 0.824. This indicates a moderate positive relationship between the two variables. With a correlation value exceeding 0.5, it can be 
concluded that the higher the number of reviews for a product, the tendency is for an increase in the product’s revenue as well. However, it’s important to note that correlation does not imply causation,
meaning it cannot be determined whether more reviews directly cause an increase in revenue or vice versa.
*/

--- Average discount offered by brand
Select b.brand, (AVG(f.discount))*100 as Average_Discount
from Finance f
Right Join brands b On f.product_id = b.product_id
Where f.discount IS Not NULL
Group by b.brand

--- We can see that Nike does not offer any discount to it's customers. On the other hand Adidas offfers a significant discount of 33.45% to it's customers.

---  Ratings and reviews by product description length
/*
interestingly, there is a strong positive correlation between revenue and reviews. This means, potentially, if we can get more reviews on the company's website, it may increase sales of those items with a
larger number of reviews.
Perhaps the length of a product’s description might influence a product's rating and reviews — if so, the company can produce content guidelines for listing products on their website and test if this 
influences revenue.
*/

SELECT
    ROUND(LEN(i.description) / 100.0, 0) * 100 AS description_length,
    Round(Avg(CAST(r.rating AS numeric)), 2) AS average_rating
FROM
    info AS i
INNER JOIN
    reviews AS r ON i.product_id = r.product_id
WHERE
    i.description IS NOT NULL
GROUP BY
    ROUND(LEN(i.description) / 100.0, 0) * 100
ORDER BY
    description_length

/*
The results indicate a relationship between the length of product descriptions (description_length) and the average product rating (average_rating). It is evident that as the length of product descriptions
increases, the average rating tends to rise. For instance, products with a description length of 600 characters have a higher average rating (3.47) compared to products with shorter descriptions.
*/

--- Reviews by month and brand

/*
As we know a correlation exists between reviews and revenue, one approach the company could take is to run experiments with different sales processes encouraging more reviews from customers about their
purchases, such as by offering a small discount on future purchases.
*/

SELECT b.brand, DATEPART(MONTH, t.last_visited) AS month_number, COUNT(r.reviews) AS num_reviews
FROM brands AS b
INNER JOIN traffic AS t 
    ON b.product_id = t.product_id
INNER JOIN reviews AS r 
    ON t.product_id = r.product_id
GROUP BY b.brand, DATEPART(MONTH, t.last_visited)
HAVING b.brand IS NOT NULL
    AND DATEPART(MONTH, t.last_visited) IS NOT NULL
ORDER BY b.brand, month_number;

/*
On the Adidas side, there’s an interesting variation in their review counts from month to month:
- Starting from January, Adidas received 253 reviews.
- The review count increased to 272 in February.
- March and April also showed high review counts with 269 and 180 reviews, respectively.
- May and June followed with 172 and 159 review counts.
- Then, July, August, and September recorded 170, 189, and 181 reviews.
- October exhibited a significant increase with 192 reviews, followed by November with 150 reviews.
- The year ended with December having 190 reviews.

On the Nike side, the review trend also captures attention:
- In January and February, Nike received an equal number of reviews, 52 each.
- March showed an increase to 55 reviews.
- Subsequent months like April and May recorded 42 and 41 reviews.
- June displayed a slight increase with 43 reviews.
- July had 37 reviews, while August and September had 29 and 28 reviews, respectively.
- October showed a drastic increase with 47 reviews.
- November and December then decreased again with 38 and 35 reviews each.
*/


/*
Looks like product reviews are highest in the first quarter of the calendar year, so there is scope to run experiments aiming to increase the volume of reviews in the other nine months!
So far, we have been primarily analyzing Adidas vs Nike products. Now, let’s switch our attention to the type of products being sold. As there are no labels for product type, we will create a Common Table
Expression (CTE) that filters description for keywords, then use the results to find out how much of the company's stock consists of footwear products and the median revenue generated by these items.
*/

WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f 
        ON i.product_id = f.product_id
    WHERE (LOWER(i.description) LIKE '%shoe%'
        OR LOWER(i.description) LIKE '%trainer%'
        OR LOWER(i.description) LIKE '%foot%')
        AND i.description IS NOT NULL
)
SELECT
    COUNT(*) AS num_footwear_products, 
    avg(revenue) AS mean_footwear_revenue
FROM
    footwear;

/*
The results indicate that there are 2,700 footwear products in the analyzed dataset. The mean revenue for these footwear products is $4235.46. This suggests that on average footwear products generate an
average revenue of $4235.46
*/


/*
We found there are 3,117 products without missing values for description. Of those, 2,700 are footwear products, which accounts for around 85% of the company's stock. They also generate an average
revenue of over $4200 dollars!
This is interesting, but we have no point of reference for whether footwear’s median_revenue is good or bad compared to other products. So, for our final task, let's examine how this differs to 
clothing products. We will re-use footwear, adding a filter afterward to count the number of products and median_revenue of products that are not in footwear.
*/

WITH footwear AS
(
    SELECT i.description, f.revenue
    FROM info AS i
    INNER JOIN finance AS f 
        ON i.product_id = f.product_id
    WHERE i.description LIKE '%shoe%'
        OR i.description LIKE '%trainer%'
        OR i.description LIKE '%foot%'
        AND i.description IS NOT NULL
)

SELECT COUNT(*) AS num_clothing_products, 
    Avg(revenue) AS mean_clothing_revenue
FROM info AS i
INNER JOIN finance AS f on i.product_id = f.product_id
WHERE i.description NOT IN (SELECT description FROM footwear);

/*
The results indicate the presence of 417 clothing products in the analyzed dataset. The median revenue of these clothing products is $2080.24.  This suggests that on average clothing products generate an
average revenue of $2080.24
*/

/*
CONCLUSION :
1) The brand needs to explore opportunities to develop products in the “Expensive” and “Elite” categories that have higher revenue potential.

2) Focusing on product quality, customer service, and holistic marketing strategies can help improve reviews and revenue.

3) Analyzing factors that influence monthly review fluctuations and planning appropriate marketing strategies.

4) Continuously monitoring product categories like footwear and clothing and making relevant price adjustments or marketing strategies.

5) Using this data as a foundation to design more effective and customer-oriented business strategies.

6) sAll of these recommendations can assist the brand in enhancing product performance, increasing revenue, and providing a better experience to customers.

*/