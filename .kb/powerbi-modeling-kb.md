# powerbi-modeling-kb

This file defines the **core rules** and **implementation guidelines** an agent must follow to create and optimize Power BI semantic models.

---

## Model Structure

- Use a **Star Schema**: fact tables (numbers, transactions) + dimension tables (descriptive attributes). 
- Avoid **Snowflake dimensions**, for example if you find tables like Product, ProductSubCategory and ProductCategory. Prefer to create a single Product table that joins these tables.
- Relationships: default to **single-directional** with `CrossFilteringBehavior = "OneDirection"`
- When available in the data source, choose **integer keys** for relationships (better performance than strings)
- **Ensure each dimension has a unique key** - Semantic model tables cannot have composite keys and only dimensions have a key column configured with `isKey`. Don't set more than one `isKey` column per table.
- Fact tables should not have surrogate keys, its a massive waste of memory.
- Create all relationships before creating measures (measures may reference relationships)
- **Always refresh model after creating relationships** to ensure they are calculated
- **Always create semantic model parameters for Data Source location**. And use them in the table Power Query expressions. For example, `ServerName`, `DatabaseName`. Notice that semantic model parameters are a special expression.
- Make sure there is a Calendar/Date table for time-intelligence (see [Date/Calendar Table](#2-datecalendar-table))
- **CRITICAL:** Create tables with Power Query expressions, do not create named expressions for the table query.
- For each table, manually create all required columns with proper data types. The `sourceColumn` column property must map to the column name from the Power Query expression.

## Naming Conventions
- Tables: business-friendly names, don't use terms as 'Fact' or 'Dim', use plural names for fact tables and singular names for dimension tables (e.g. `Sales`, `Product`, `Customer`). 
- Columns: Readable names with spaces (e.g. `Order Date`, `Product`, `Unit Price`)
- Columns: For dimension name prefer a column with the same name of the dimension. `Product` instead of `Product Name`
- Measures: clear naming patterns (`Total Sales`, `Total Quantity`, `# Customers`, `# Products`)
- Measures variations (e.g. time intelligence) should follow a consistent naming convention:
  - [measure name] for base measure
  - [measure name (ly)] for last year value of the base measure
  - [measure name (ytd)] for ytd value for the base measure
- **Critical**: Always use exact case-sensitive names when referencing objects
- **Verify names with List operations** before any update/rename operations
  
## Data Types & Formatting
- All column must have a data type (Int64 for keys, Decimal for currency)
- Measures dont require a data type, its inferred from the DAX expression at run-time.
- Choose efficient data types (Int64 for keys, Decimal for currency)
- Always apply an appropriate format string for measures. See [Format String Reference](#format-string-reference)

## Table columns
- Columns are NOT automatically inferred from Power Query expressions
- The column `dataType` if available can be inferred from source column data type from the data source.
- Hide all technical ID/foreign key columns (set `IsHidden = true`)
- Don't summarize numeric columns, set `SummarizeBy = None`
  
## Date/Calendar Table
- Only create a DAX calculated Date table if not available in the Data Source.
- Mark date dimension with `DataCategory = "Time"`
- Ensure contiguous date range (no gaps)
- Include standard date attributes (Year, Month, Quarter, Week)
- Create time intelligence measures (YTD, MTD, QTD)
- **Verify date table relationships** before creating time intelligence measures
   
## Measures & DAX
- Create **explicit measures only**, never rely on implicit aggregations from the numeric aggregatable columns.
- Don't store all measures in a dedicated Measures table.
- **Validate every measure immediately after creation** - check State property for errors
- **Create measures in batches of 5-10** to reduce risk and aid debugging
- Use `DIVIDE()` function instead of `/` operator for safe division
- Use `SUMMARIZECOLUMNS` instead of `SUMMARIZE`
- DAX syntax: Use single quotes for table references: `'tablename'[column]`
- Use `VAR` statements in complex DAX to improve performance and readability
- **Test each measure with a simple query** after creation
- Group related measures in display folders (`DisplayFolder` property)
- Avoid nesting CALCULATE excessively
- Avoid conflicts with builtin functions and table names, when necessary prefix the variable name with __
- When referencing measures do not include the table name (e.g. [Measure])

## Documentation Requirements
- **Every table** must have a description
- **Every measure** must have a description
- Use display folders to organize measures logically
- Document the purpose of complex DAX calculations
- Include example values or expected outputs in descriptions
- Incorporate business verbiage of the COMPANY in the descriptions. (See [COMPANY verbiage](#company-verbiage))

## High-Impact Best Practice Rules (BPA) Checklist

### Critical (Must Fix)
- [ ] No implicit measures - all aggregations are explicit
- [ ] No calculated columns on large fact tables
- [ ] Star schema with proper relationships

### High Priority

- [ ] All relationships are single-directional
- [ ] Relationship keys are integers
- [ ] Foreign keys are hidden
- [ ] Date table marked as Time dimension

### Medium Priority
- [ ] DIVIDE() function used for division
- [ ] All tables have descriptions
- [ ] All measures have descriptions
- [ ] Currency formatting applied correctly
- [ ] Percentage formatting applied correctly
- [ ] Measures organized in display folders
  
## Common Pitfalls to Avoid

- **Don't reference columns before verifying they exist** - use List operations first
- **Always escape special characters in format strings** - use double backslash
- **Use single quotes in DAX table references** - `'table'[column]` not "table"[column]
- **Check case sensitivity of all object names** - Power BI is case-sensitive
- **Create relationships before dependent measures** - measures may reference relationships
- **Document while you build** - easier than adding documentation later.

## Format String Reference
- Currency: `"\\$#,##0.00"` (note double backslash)
- Percentage: `"0.00%"`
- Integer: `"#,##0"`
- Decimal: `"#,##0.00"`
- Thousands: `"#,##0,K"`
- Millions: `"#,##0,,M"`

## COMPANY verbiage

- sells products from a series of brands across multiple countries.
- operates physical retail stores and an online platform to reach global customers.
- offers a wide range of products including clothing, home goods, and electronics.
- serves millions of customers annually through both digital and in-store experiences.
- uses data and technology to personalize the shopping experience.
- partners with manufacturers and suppliers to ensure product quality and availability.
- invests in sustainable practices across its supply chain and packaging.
- has a global workforce and local teams to support regional markets.
- adapts its product offerings to meet the cultural and seasonal needs of each market.
- runs marketing campaigns tailored to specific audiences across different countries.
- manages a loyalty program to reward repeat customers and drive retention.
- constantly evaluates trends to introduce new brands and product lines.
- integrates inventory and logistics systems for efficient order fulfillment.
- participates in corporate social responsibility initiatives around the world.