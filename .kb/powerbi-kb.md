
## CRITICAL
- If `powerbi-modeling-mcp` MCP server is not available, stop and prompt the user to install it.

## Semantic model development

### New Semantic Model workflow

- Start by creating the semantic model folder structure. Follow the content in [Semantic Model PBIP files](#semantic-model-pbip-files)
- Use the `powerbi-modeling-mcp` MCP server to create an empty model and tools provided by the server for modeling operations. In the end serialize the database to the `definition/` folder of the semantic model.
- After the creation of the semantic model perform the following:
  - Run the **Best Practice Analysis** by calling the script `.bpa/bpa.ps1` with arguments `-src [path to the semantic model]` and resolve critical errors found. No need to create build automation pipeline, just run the script directly as part of the development phase.
  - Copy the `templateReport` available in the `.kb` folder to the `*.Report` folder of the semantic model report - overwrite the files that already exist with same name. Adapt the report to the semantic model, follow the instructions in `templateReport/instructions.md`. 

### Semantic model development rules

- Whenever there is a data source, always always create a semantic model parameter as named expression to configure the data source location.
- Always prefer simple star-schema modeling and not snowflake. For example if you find tables like Product, ProductSubCategory and ProductCategory. Prefer to create a single Product table that joins these tables.
- It's ok to have partitions in 'NoData' state. Attempting to refresh might fail because there is no credential defined. 
- Don't try to test the semantic model data, the user must do it with Power BI Desktop after authentication to the data source.
- The relationship between Calendar and fact table should be made using a datetime column. If the fact table  dont have a datetime or date column make sure you create one using PowerQuery language
- Make sure you set descriptions on all created measures. Follow [Semantic model descriptions rules](#semantic-model-descriptions-rules)
- If required to create a Calendar table for time-intelligence, create it with at least the following time attributes: Year, Month, Day, Date.
- Use named expressions primarily for parameters and data source location configuration, for the query expression prefer to add it directly in the M expression of the table.
- Unless specified otherwise, adhere to the following naming convention in [semantic-model-naming-convention](#semantic-model-naming-convention)
- Make sure you adhere to the DAX rules described in [DAX rules](#dax-rules)

#### Semantic Model Table creation workflow
1. Create tables with Power Query expressions, do not create named expressions for the table query. 
2. For each table, manually create all required columns with proper data types. The `sourceColumn` column property must map to the column name from the Power Query expression.
3. Columns are NOT automatically inferred from Power Query expressions
4. The column `dataType` if available can be inferred from source column data type from the data source.
5. Set appropriate column properties (hidden, dataType, formatString, etc.)
6. Only then create relationships between tables

### Semantic Model PBIP files

- When creating a new semantic model, ensure you start by creating a PBIP folder structure like the following:

    ```text
    root/
    ├── [Name].SemanticModel/
    |   ├── /definition # Empty folder that will hold the TMDL definition of the semantic model
    |   ├──  definition.pbism # The semantic model definition file
    ├── [Name].Report/        
    |   ├── /definition # Empty folder that will hold the PBIR definition of the report
    |   ├──  definition.pbir # The report definition file with a byPath relative reference to the semantic model folder
    └── [Name].pbip # A shortcut file to the report folder
    ```    

    **Example of a definition.pbism file**

    No modifications are needed—just create the file exactly as shown in the example.

    ```json
    {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/semanticModel/definitionProperties/1.0.0/schema.json",
        "version": "4.2",
        "settings": {
            "qnaEnabled": true
        }
    }
    ```

    **Example of a definition.pbir file**

    The `byPath` property should reference the semantic model folder using a relative path like below.

    ```json
    {
        "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definitionProperties/2.0.0/schema.json",
        "version": "4.0",
        "datasetReference": {
            "byPath": {
                "path": "../{Name of the Semantic Model}.SemanticModel"
            }
        }
    }
    ```

     **Example of a {Name of the Semantic Model}.pbip file**

     ```json
        {
            "version": "1.0",
            "artifacts": [
                {
                "report": {
                    "path": "{Name of the Semantic Model}.Report"
                }
                }
            ],
            "settings": {
                "enableAutoRecovery": true
            }
        }
     ```

### Semantic model descriptions rules

- Use concise and meaningful descriptions that align with the purpose of the measure or column.
- Ensure comments provide clear explanations of the definitions and purpose of the table, column or measure, incorporating **COMPANY** business and data practices where applicable.

### Semantic Model Naming convention

- Use singular names for dimension tables
- Use plural names for fact tables
- All object names should be lower case
- Don't use 'fact' or 'dim' in the table or column names. Prefer business friendly representation
- Don't use column names like 'product name' prefer 'product' instead
- Measure names should follow a consistent naming convention: 
  - [measure name] for base measure
  - [measure name (ly)] for last year value of the base measure
  - [measure name (ytd)] for ytd value for the base measure

### DAX code rules

- Avoid nesting CALCULATE excessively
- Avoid conflicts with builtin functions and table names, prefix the variable name with __

## COMPANY specific context for description generation 🏢

- COMPANY sells products from a series of brands across multiple countries.
- COMPANY operates physical retail stores and an online platform to reach global customers.
- COMPANY offers a wide range of products including clothing, home goods, and electronics.
- COMPANY serves millions of customers annually through both digital and in-store experiences.
- COMPANY uses data and technology to personalize the shopping experience.
- COMPANY partners with manufacturers and suppliers to ensure product quality and availability.
- COMPANY invests in sustainable practices across its supply chain and packaging.
- COMPANY has a global workforce and local teams to support regional markets.
- COMPANY adapts its product offerings to meet the cultural and seasonal needs of each market.
- COMPANY runs marketing campaigns tailored to specific audiences across different countries.
- COMPANY manages a loyalty program to reward repeat customers and drive retention.
- COMPANY constantly evaluates trends to introduce new brands and product lines.
- COMPANY integrates inventory and logistics systems for efficient order fulfillment.
- COMPANY participates in corporate social responsibility initiatives around the world.