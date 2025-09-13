# powerbi-pbip-kb

This file defines the **general rules** and **implementation guidelines** an agent must follow when creating Power BI Project.

---

## Ensure your have the right tools

- **Critical**: Make sure `powerbi-modeling-mcp` is available. If not, stop and prompt the user to install it. Learn about the `powerbi-modeling-mcp` tools and always prioritize using Batch tools. For example, when creating columns try to create them in batch using `BatchColumnOperationsTool` instead of one by one using `ColumnOperationsTool`.

## New Power BI Project workflow

- Start by creating the PBIP folder structure. Follow the content in [PBIP file structure](#pbip-file-structure)
- Start by creating a new empty semantic model. You should serialize the database into the `definition/` folder of the semantic model in the PBIP.
- **Critical:** Ensure you follow the development style and best practices in `powerbi-modeling-kb.md`.
- **Critical:** Power BI cannot open the semantic model for edit directly, it must include a report. If there is a `.kb/templateReport` use it instead of the empty report. Follow the instructions in the `template-report-kb.md` to adapt the template report visuals to the created semantic model. Only work in the report when the semantic model development is complete.

## PBIP file structure

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
            "$schema": "https://developer.microsoft.com/json-schemas/fabric/pbip/pbipProperties/1.0.0/schema.json",
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


