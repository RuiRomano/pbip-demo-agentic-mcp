# Adventure Works Power BI Project - Technical Development Specification

## Document Information
- **Document**: dev-spec.md
- **Project**: Adventure Works Power BI Project (PBIP)
- **Version**: 1.0
- **Date**: September 13, 2025
- **Author**: AI Development Assistant

## Executive Summary

This document outlines the technical specification for developing a Power BI Project (PBIP) for Adventure Works company. The project will create a comprehensive sales analytics solution that combines Internet and Reseller sales data to provide unified business insights across multiple dimensions including products, customers, territories, and time.

## Business Requirements Analysis

### Identified Requirements

| Requirement ID | Business Need | Technical Implementation |
|---------------|---------------|-------------------------|
| **SALES-001** | Total Sales Performance Overview | Create unified [Total Sales Amount] measure combining Internet + Reseller sales with star schema relationships |
| **SALES-002** | Sales Growth Analysis | Implement time intelligence measures: [Sales YoY Growth %] and [Sales MoM Growth %] using SAMEPERIODLASTYEAR and PREVIOUSMONTH functions |
| **SALES-003** | Top Performing Products | Create [Product Sales Rank] measure using RANKX function with proper fact-to-dimension relationships |

### Key Business Metrics
- **Total Sales Amount**: Combined revenue from Internet and Reseller channels
- **Year-over-Year Growth**: Percentage change from previous year same period
- **Month-over-Month Growth**: Percentage change from previous month
- **Product Performance Rankings**: Top 10 products by sales amount and category

## Data Architecture

### Data Source
- **Server**: `dummyserver.database.windows.net`
- **Database**: `AdventureWorksDW`
- **Schema**: Provided in `AzureSQLSchema.csv` (397 tables/columns analyzed)

### Star Schema Design

#### Fact Tables
1. **Internet Sales** (FactInternetSales)
   - Primary measures: SalesAmount, OrderQuantity, ExtendedAmount
   - Key relationships: CustomerKey, ProductKey, OrderDateKey, PromotionKey, CurrencyKey, SalesTerritoryKey

2. **Reseller Sales** (FactResellerSales)
   - Primary measures: SalesAmount, OrderQuantity, ExtendedAmount
   - Key relationships: ResellerKey, ProductKey, OrderDateKey, EmployeeKey, PromotionKey, CurrencyKey, SalesTerritoryKey

#### Dimension Tables
1. **Calendar** (DimDate)
   - Primary key: DateKey
   - Attributes: FullDateAlternateKey, CalendarYear, CalendarQuarter, MonthNumberOfYear, EnglishMonthName
   - Time intelligence support: Fiscal/Calendar periods

2. **Products** (DimProduct + DimProductSubcategory + DimProductCategory)
   - Consolidated single dimension (avoiding snowflake)
   - Primary key: ProductKey
   - Attributes: EnglishProductName, Color, ListPrice, ProductLine, Category, Subcategory

3. **Customers** (DimCustomer)
   - Primary key: CustomerKey
   - Attributes: FirstName, LastName, EmailAddress, YearlyIncome, Education

4. **Geography** (DimGeography)
   - Primary key: GeographyKey
   - Attributes: City, StateProvinceName, EnglishCountryRegionName, PostalCode

5. **Sales Territory** (DimSalesTerritory)
   - Primary key: SalesTerritoryKey
   - Attributes: SalesTerritoryRegion, SalesTerritoryCountry, SalesTerritoryGroup

6. **Resellers** (DimReseller)
   - Primary key: ResellerKey
   - Attributes: ResellerName, BusinessType, ResellerType

## Technical Implementation Plan

### Phase 1: Environment Preparation
1. **Verify powerbi-modeling-mcp availability**
   - Ensure MCP tools are accessible
   - Prioritize batch operations for efficiency

2. **Create PBIP folder structure**
   ```
   AdventureWorks.SemanticModel/
   ├── definition/ (empty - will hold TMDL)
   └── definition.pbism
   
   AdventureWorks.Report/
   ├── definition/ (empty - will hold PBIR)
   └── definition.pbir
   
   AdventureWorks.pbip
   ```

3. **Initialize configuration files**
   - definition.pbism with qnaEnabled: true
   - definition.pbir with relative byPath reference
   - AdventureWorks.pbip with report artifact reference

### Phase 2: Semantic Model Development

#### Data Source Configuration
1. **Create semantic model parameters**
   - ServerName: "dummyserver.database.windows.net"
   - DatabaseName: "AdventureWorksDW"

2. **Create Power Query expressions for tables**
   - Use parameterized connections
   - Implement efficient queries with necessary columns only
   - No named expressions - direct table queries

#### Table Creation Priority
1. **Calendar table** (DimDate) - Foundation for time intelligence
2. **Products table** - Consolidated from Product + Subcategory + Category
3. **Customers table** (DimCustomer)
4. **Geography table** (DimGeography)
5. **Sales Territory table** (DimSalesTerritory)
6. **Resellers table** (DimReseller)
7. **Internet Sales table** (FactInternetSales)
8. **Reseller Sales table** (FactResellerSales)

#### Column Configuration
- **Data types**: Int64 for keys, Decimal for currency, DateTime for dates
- **Visibility**: Hide all technical keys and foreign key columns
- **Summarization**: Set SummarizeBy = None for numeric non-measure columns
- **Source mapping**: Ensure sourceColumn properties map correctly

#### Relationships
- **Single-directional relationships** (CrossFilteringBehavior = "OneDirection")
- **Integer keys preferred** for performance
- **Star schema pattern**: Facts connect to dimensions, dimensions don't connect to each other

Key relationships to create:
- Calendar ↔ Internet Sales (DateKey ↔ OrderDateKey)
- Calendar ↔ Reseller Sales (DateKey ↔ OrderDateKey)
- Products ↔ Internet Sales (ProductKey ↔ ProductKey)
- Products ↔ Reseller Sales (ProductKey ↔ ProductKey)
- Customers ↔ Internet Sales (CustomerKey ↔ CustomerKey)
- Resellers ↔ Reseller Sales (ResellerKey ↔ ResellerKey)
- Geography ↔ Customers (GeographyKey ↔ GeographyKey)
- Sales Territory ↔ Internet Sales (SalesTerritoryKey ↔ SalesTerritoryKey)
- Sales Territory ↔ Reseller Sales (SalesTerritoryKey ↔ SalesTerritoryKey)

### Phase 3: Measures Implementation

#### Create dedicated Measures table
- Logical table for organizing all calculations
- No physical data source
- Organized with display folders

#### Core Measures (Batch 1)
```dax
Total Internet Sales = SUM('Internet Sales'[SalesAmount])
Total Reseller Sales = SUM('Reseller Sales'[SalesAmount])
Total Sales Amount = [Total Internet Sales] + [Total Reseller Sales]
Total Quantity = SUM('Internet Sales'[OrderQuantity]) + SUM('Reseller Sales'[OrderQuantity])
```

#### Time Intelligence Measures (Batch 2)
```dax
Total Sales Amount (ly) = CALCULATE([Total Sales Amount], SAMEPERIODLASTYEAR('Calendar'[Date]))
Sales YoY Growth % = 
VAR __CurrentPeriod = [Total Sales Amount]
VAR __PreviousYear = [Total Sales Amount (ly)]
RETURN
    IF(
        __PreviousYear <> 0,
        DIVIDE(__CurrentPeriod - __PreviousYear, __PreviousYear, 0),
        BLANK()
    )

Total Sales Amount (pm) = CALCULATE([Total Sales Amount], PREVIOUSMONTH('Calendar'[Date]))
Sales MoM Growth % = 
VAR __CurrentMonth = [Total Sales Amount]
VAR __PreviousMonth = [Total Sales Amount (pm)]
RETURN
    IF(
        __PreviousMonth <> 0,
        DIVIDE(__CurrentMonth - __PreviousMonth, __PreviousMonth, 0),
        BLANK()
    )
```

#### Product Analysis Measures (Batch 3)
```dax
Product Sales Rank = 
RANKX(
    ALL('Products'[Product]),
    [Total Sales Amount],
    ,
    DESC,
    DENSE
)

Top 10 Products = 
IF(
    [Product Sales Rank] <= 10,
    [Total Sales Amount],
    BLANK()
)
```

#### Measure Properties
- **Format strings**: Currency ("\\$#,##0.00"), Percentage ("0.00%")
- **Display folders**: "Sales Metrics", "Time Intelligence", "Product Analysis"
- **Descriptions**: Business-friendly explanations with Adventure Works context

### Phase 4: Data Model Optimization

#### Best Practices Application
1. **Star schema enforcement** - No snowflake dimensions
2. **Relationship optimization** - Single direction, integer keys
3. **Column optimization** - Hide technical columns, proper data types
4. **Measure organization** - Display folders, descriptions
5. **Documentation** - Table and measure descriptions

#### Best Practice Analysis (BPA)
1. **Run BPA script**: `.bpa/bpa.ps1 -src [semantic model path]`
2. **Resolve critical errors** identified by BPA
3. **Serialize changes** back to TMDL format
4. **Validate implementation** against development guidelines

### Phase 5: Report Implementation

#### Template Application
1. **Copy template report** from `.kb/templateReport` to `AdventureWorks.Report/definition/`
2. **Adapt visual configurations**:
   - **title**: "Adventure Works Sales Analytics"
   - **topCard**: Display main KPIs (Total Sales Amount, Total Quantity, Sales YoY Growth %, Sales MoM Growth %)
   - **dateSlicer**: Connect to Calendar[Date] column
   - **barChart**: Product categories vs Total Sales Amount

#### Visual Configuration
- **Data connections**: Reference semantic model measures and dimensions
- **Interactivity**: Cross-filtering between visuals
- **Formatting**: Adventure Works branding and color scheme

## Data Model Details

### Table Specifications

#### Calendar Table
- **Source**: DimDate
- **Key column**: DateKey (isKey = true, dataType = Int64)
- **Display columns**: Date, Year, Quarter, Month, Month Name
- **Hidden columns**: DateKey, fiscal period columns
- **Data category**: "Time" for Date column

#### Products Table (Consolidated)
- **Sources**: DimProduct + DimProductSubcategory + DimProductCategory (joined)
- **Key column**: ProductKey (isKey = true, dataType = Int64)
- **Display columns**: Product, Category, Subcategory, Color, List Price
- **Hidden columns**: ProductKey, subcategory keys, foreign keys
- **Power Query**: LEFT JOIN operations to denormalize

#### Internet Sales Table
- **Source**: FactInternetSales
- **Key columns**: None (fact table)
- **Measure columns**: SalesAmount, OrderQuantity, ExtendedAmount
- **Foreign key columns**: CustomerKey, ProductKey, OrderDateKey (all hidden)
- **Data types**: Decimal for amounts, Int64 for quantities and keys

#### Reseller Sales Table
- **Source**: FactResellerSales
- **Key columns**: None (fact table)
- **Measure columns**: SalesAmount, OrderQuantity, ExtendedAmount
- **Foreign key columns**: ResellerKey, ProductKey, OrderDateKey (all hidden)
- **Data types**: Decimal for amounts, Int64 for quantities and keys

### Security & Performance Considerations
- **No Row-Level Security** required for initial implementation
- **Aggregations**: Not implemented in initial version
- **Partitioning**: Single partition per table (PBIP development limitation)
- **Refresh strategy**: Manual refresh only (no gateway connectivity)

## Development Guidelines Compliance

### PBIP Structure Compliance
✅ Follows prescribed folder structure
✅ Uses relative byPath references
✅ Implements proper schema versioning

### Modeling Best Practices Compliance
✅ Star schema implementation
✅ Single-directional relationships
✅ Integer keys for performance
✅ Proper data types and formatting
✅ Explicit measures only
✅ Time intelligence implementation
✅ Display folder organization
✅ Comprehensive documentation

### Naming Convention Compliance
✅ Business-friendly table names (no "Fact"/"Dim" prefixes)
✅ Readable column names with spaces
✅ Consistent measure naming patterns
✅ Case-sensitive reference accuracy

## Testing Strategy

### Data Validation
- **Relationship integrity**: Verify all relationships are properly created and active
- **Measure accuracy**: Validate measure calculations against expected business logic
- **Time intelligence**: Test YoY and MoM calculations across multiple time periods
- **Ranking functionality**: Verify product ranking calculations

### Performance Testing
- **Model size**: Monitor semantic model size and optimization opportunities
- **Query performance**: Assess visual rendering speed with sample data
- **Memory usage**: Evaluate model efficiency within Power BI limitations

### Business Validation
- **Requirement mapping**: Ensure all business requirements are addressed
- **User experience**: Validate report usability and visual effectiveness
- **Data accuracy**: Verify calculations match business expectations

## Deployment Considerations

### Version Control
- **PBIP format**: Enables Git-based version control
- **TMDL serialization**: Readable metadata format
- **Report definitions**: JSON-based PBIR format

### Environment Management
- **Development**: Local PBIP environment
- **Testing**: Power BI Desktop validation
- **Production**: Power BI Service deployment (future phase)

### Documentation
- **Technical documentation**: This specification document
- **User documentation**: Report usage guidelines (future phase)
- **Maintenance documentation**: Refresh and update procedures (future phase)

## Success Criteria

### Functional Requirements
- ✅ Unified sales reporting across Internet and Reseller channels
- ✅ Time intelligence calculations (YoY, MoM growth)
- ✅ Product performance ranking and analysis
- ✅ Interactive report with filtering and drill-down capabilities

### Technical Requirements
- ✅ Star schema data model implementation
- ✅ Optimized relationships and measures
- ✅ BPA compliance with critical issues resolved
- ✅ PBIP format with proper version control support

### Quality Requirements
- ✅ Comprehensive documentation for all model objects
- ✅ Consistent naming conventions throughout
- ✅ Proper data types and formatting
- ✅ Error-free measure calculations

## Risk Mitigation

### Technical Risks
- **Data source connectivity**: Fallback to schema file if SQL Server unavailable
- **Measure complexity**: Batch creation approach to minimize error propagation
- **Relationship conflicts**: Sequential creation with validation at each step

### Business Risks
- **Requirement misinterpretation**: Regular validation against business requirements
- **Performance issues**: Monitoring model size and query complexity
- **User adoption**: Intuitive report design following template guidelines

## Conclusion

This technical specification provides a comprehensive roadmap for implementing the Adventure Works Power BI Project. The approach emphasizes best practices, proper data modeling, and adherence to established development guidelines while meeting the specific business requirements identified in the requirements document.

The implementation will follow a phased approach ensuring quality at each stage, from environment preparation through final report delivery. The resulting solution will provide Adventure Works with a robust, scalable, and maintainable sales analytics platform.