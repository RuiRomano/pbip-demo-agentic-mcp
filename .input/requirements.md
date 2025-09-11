
 # Business Requirements 💼

| Requirement ID | Description | User Story | Expected Behavior |
|---------------|-------------|------------|-------------------|
| **SALES-001** | Total Sales Performance Overview | As a **Sales Manager**, I want to see the total sales amount across all channels (Internet + Reseller) so that I can understand our overall revenue performance. | Create a combined [Total Sales Amount] measure that sums the sales from Internet and Reseller with proper relationship handling through shared dimensions. |
| **SALES-002** | Sales Growth Analysis | As a **Executive Leadership**, I want to see year-over-year and month-over-month sales growth percentages so that I can track business progress against targets. | Create time intelligence measures using SAMEPERIODLASTYEAR and PREVIOUSMONTH functions: [Sales YoY Growth %] and [Sales MoM Growth %] with proper Calendar table relationships. |
| **SALES-003** | Top Performing Products | As a **Product Manager**, I want to identify the top 10 products by sales amount and category so that I can focus marketing efforts on high-performing items. | Create [Product Sales Rank] measure using RANKX function and establish proper relationships between fact tables and DimProduct for accurate product-level aggregations. |

# Data source information 🛢️

- **Server**: `dummyserver.database.windows.net`
- **Database**: `AdventureWorksDW`

If you cannot connect to the SQL Server above to get the schema, all  information of the Datawarehouse can be found in the file `AzureSQLSchema.csv`. 



