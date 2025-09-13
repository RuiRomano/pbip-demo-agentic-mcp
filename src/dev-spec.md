# Adventure Works Sales Analytics - Technical Development Specification

**Project**: Adventure Works Power BI Project (PBIP)  
**Version**: 1.0  
**Date**: September 13, 2025  
**Author**: GitHub Copilot  

## Executive Summary

This document outlines the technical implementation specification for a Power BI Project (PBIP) that will analyze Adventure Works sales data to meet specific business requirements for Sales Managers, Executive Leadership, and Product Managers. The solution will implement a star schema semantic model with comprehensive sales analytics capabilities across Internet and Reseller channels.

## Business Requirements Analysis

### Core Requirements
The solution must address three primary business requirements:

| Requirement | Business User | Key Deliverable |
|-------------|---------------|-----------------|
| **SALES-001** | Sales Manager | Total Sales Performance Overview - Combined Internet + Reseller sales |
| **SALES-002** | Executive Leadership | Sales Growth Analysis - YoY and MoM growth percentages |
| **SALES-003** | Product Manager | Top Performing Products - Top 10 products by sales with ranking |

### Key Performance Indicators (KPIs)
- **Total Sales Amount**: Combined revenue from Internet and Reseller channels
- **Sales YoY Growth %**: Year-over-year growth percentage using time intelligence
- **Sales MoM Growth %**: Month-over-month growth percentage
- **Product Sales Rank**: RANKX-based product performance ranking

## Data Source Architecture

### Primary Data Source
- **Server**: `dummyserver.database.windows.net` (SQL Server)
- **Database**: `AdventureWorksDW` (Data Warehouse)
- **Fallback**: `AzureSQLSchema.csv` for schema reference

### Key Tables Analysis
Based on the schema analysis, the following tables are critical for implementation:

#### Fact Tables
1. **FactInternetSales** - Internet channel sales transactions
   - Key columns: `SalesAmount`, `OrderQuantity`, `UnitPrice`, `OrderDateKey`, `ProductKey`, `CustomerKey`
   - Relationships: Product, Customer, Date, Territory, Currency, Promotion

2. **FactResellerSales** - Reseller channel sales transactions
   - Key columns: `SalesAmount`, `OrderQuantity`, `UnitPrice`, `OrderDateKey`, `ProductKey`, `ResellerKey`
   - Relationships: Product, Reseller, Date, Territory, Currency, Employee, Promotion

#### Dimension Tables
1. **DimDate** - Calendar dimension for time intelligence
   - Key columns: `DateKey`, `FullDateAlternateKey`, `CalendarYear`, `CalendarQuarter`, `MonthNumberOfYear`
   - **Critical**: Must be marked as Time dimension for DAX time intelligence functions

2. **DimProduct** - Product master data
   - Key columns: `ProductKey`, `ProductAlternateKey`, `EnglishProductName`, `ProductSubcategoryKey`, `ProductCategoryKey`
   - **Note**: Implement denormalized approach (avoid snowflake) by joining subcategory and category

3. **DimCustomer** - Customer dimension for Internet sales
4. **DimReseller** - Reseller dimension for channel sales
5. **DimSalesTerritory** - Geographic sales territories
6. **DimCurrency** - Currency conversion support

## Semantic Model Design

### Star Schema Implementation
The semantic model will follow a star schema design pattern:

```
        DimDate (Calendar)
             |
             | OrderDateKey
             |
    FactInternetSales ←→ DimProduct
             |               ↑
             | CustomerKey     | ProductKey
             ↓               |
        DimCustomer     FactResellerSales
                             |
                             | ResellerKey
                             ↓
                        DimReseller
```

### Table Structure

#### Sales (Fact Table) - Combined Internet and Reseller
- **Purpose**: Unified fact table combining both sales channels
- **Key Columns**:
  - `Sales Amount` (Decimal) - Primary sales measure
  - `Order Quantity` (Int64) - Quantity sold
  - `Unit Price` (Decimal) - Unit pricing
  - `Order Date Key` (Int64) - Date relationship key
  - `Product Key` (Int64) - Product relationship key
  - `Sales Channel` (Text) - "Internet" or "Reseller"
  - `Customer Key` (Int64) - Customer/Reseller identifier

#### Product (Dimension Table) - Denormalized
- **Purpose**: Complete product hierarchy in single table
- **Key Columns**:
  - `Product Key` (Int64, IsKey=true) - Primary key
  - `Product` (Text) - Product name
  - `Product Subcategory` (Text) - Subcategory
  - `Product Category` (Text) - Category
  - `Product Color` (Text) - Color attribute
  - `Product Size` (Text) - Size attribute

#### Date (Dimension Table) - Calendar
- **Purpose**: Time intelligence support
- **Key Columns**:
  - `Date Key` (Int64, IsKey=true) - Primary key
  - `Date` (DateTime, DataCategory="Time") - Full date
  - `Year` (Int64) - Calendar year
  - `Quarter` (Text) - Quarter label
  - `Month` (Text) - Month name
  - `Month Number` (Int64) - Month number

### Measures Implementation

#### Core Sales Measures
1. **Total Sales Amount**
   ```dax
   Total Sales Amount = 
   VAR __InternetSales = CALCULATE(SUM(FactInternetSales[SalesAmount]))
   VAR __ResellerSales = CALCULATE(SUM(FactResellerSales[SalesAmount]))
   RETURN __InternetSales + __ResellerSales
   ```

2. **Sales YoY Growth %**
   ```dax
   Sales YoY Growth % = 
   VAR __CurrentYear = [Total Sales Amount]
   VAR __PreviousYear = CALCULATE([Total Sales Amount], SAMEPERIODLASTYEAR('Date'[Date]))
   RETURN DIVIDE(__CurrentYear - __PreviousYear, __PreviousYear)
   ```

3. **Sales MoM Growth %**
   ```dax
   Sales MoM Growth % = 
   VAR __CurrentMonth = [Total Sales Amount]
   VAR __PreviousMonth = CALCULATE([Total Sales Amount], PREVIOUSMONTH('Date'[Date]))
   RETURN DIVIDE(__CurrentMonth - __PreviousMonth, __PreviousMonth)
   ```

4. **Product Sales Rank**
   ```dax
   Product Sales Rank = 
   RANKX(ALL('Product'[Product]), [Total Sales Amount],, DESC, Dense)
   ```

### Relationships Design
- **Single-directional relationships** (CrossFilteringBehavior = "OneDirection")
- **Integer keys** for optimal performance
- **Hidden foreign key columns** in fact tables
- **Active relationships** on OrderDateKey across all fact tables

### Parameters Configuration
- `ServerName` (Text) - SQL Server connection parameter
- `DatabaseName` (Text) - Database name parameter
- Dynamic Power Query expressions using parameter references

## Implementation Phases

### Phase 1: Environment Preparation
1. **Verify powerbi-modeling-mcp availability** - Critical requirement
2. **Create PBIP folder structure**:
   ```
   AdventureWorksSales.SemanticModel/
   ├── definition/ (empty - for TMDL)
   └── definition.pbism
   
   AdventureWorksSales.Report/
   ├── definition/ (empty - for PBIR)
   └── definition.pbir
   
   AdventureWorksSales.pbip
   ```

### Phase 2: Semantic Model Development
1. **Create semantic model** with proper parameters
2. **Implement star schema tables** using batch operations
3. **Create relationships** between fact and dimension tables
4. **Implement measures** in batches of 5-10
5. **Apply formatting and metadata**

### Phase 3: Best Practices Enforcement
1. **Execute BPA script** `.bpa/bpa.ps1 -src [SemanticModel folder path]`
2. **Resolve critical errors** iteratively
3. **Serialize model** back to TMDL format
4. **Validate all measures** for calculation errors

### Phase 4: Report Implementation
1. **Copy template report** from `.kb/templateReport`
2. **Adapt visual configurations** to semantic model
3. **Configure main KPI cards** with core measures
4. **Implement product ranking visualization**

## Technical Considerations

### Performance Optimizations
- Use **integer keys** for relationships (better than string keys)
- Implement **denormalized dimensions** (avoid snowflake schema)
- Apply **appropriate data types** (Int64 for keys, Decimal for currency)
- Hide **technical ID columns** to reduce model complexity

### Data Quality Assurance
- **Contiguous date range** in Calendar table (no gaps)
- **Unique keys** in all dimension tables
- **Proper format strings** for all measures
- **Comprehensive documentation** for all objects

### Error Handling
- Use **DIVIDE()** function instead of `/` operator
- Implement **VAR statements** for complex DAX
- **Validate measures immediately** after creation
- **Test time intelligence** with proper date relationships

## Compliance and Best Practices

### Naming Conventions
- **Tables**: Business-friendly names (Sales, Product, Date)
- **Columns**: Readable names with spaces (Order Date, Product Name)
- **Measures**: Clear patterns (Total Sales, Sales YoY Growth %)

### Documentation Requirements
- **Every table** must have business description
- **Every measure** must have calculation description
- **Display folders** for measure organization
- **Adventure Works business context** in descriptions

### Format Strings
- Currency: `"\\$#,##0.00"`
- Percentage: `"0.00%"`
- Integer: `"#,##0"`
- Thousands: `"#,##0,K"`

## Validation Criteria

### Functional Validation
- [ ] Total Sales Amount correctly combines Internet + Reseller
- [ ] YoY and MoM growth calculations work with time intelligence
- [ ] Product ranking displays top 10 products accurately
- [ ] All relationships filter correctly

### Technical Validation
- [ ] All BPA critical errors resolved
- [ ] No implicit measures used
- [ ] Star schema properly implemented
- [ ] All foreign keys hidden
- [ ] Date table marked as Time dimension

### Business Validation
- [ ] Sales Manager can view total sales performance
- [ ] Executive Leadership can analyze growth trends
- [ ] Product Manager can identify top performing products
- [ ] All KPIs display with proper formatting

## Risk Assessment

### High Risk Items
- **SQL Server connectivity** - Fallback to CSV schema available
- **Time intelligence accuracy** - Requires proper Date table setup
- **Cross-channel aggregation** - Complex DAX for combined measures

### Mitigation Strategies
- Use schema CSV if database unavailable
- Validate Date table before creating time intelligence
- Test combined measures with simple queries
- Implement measures in small batches for easier debugging

## Success Metrics

The implementation will be considered successful when:
1. All three business requirements (SALES-001, SALES-002, SALES-003) are fully met
2. BPA script passes with zero critical errors
3. Report displays all KPIs with correct values and formatting
4. Model follows all documented best practices and guidelines
5. Performance meets expected standards for executive reporting

## Next Steps

Upon approval of this specification:
1. Begin Phase 1 implementation with environment setup
2. Validate powerbi-modeling-mcp tool availability
3. Create initial PBIP structure in src/ folder
4. Proceed with iterative development following defined phases

---
*This specification document serves as the technical blueprint for implementing the Adventure Works Sales Analytics Power BI Project. All implementation decisions should reference back to this document to ensure consistency with business requirements and technical standards.*