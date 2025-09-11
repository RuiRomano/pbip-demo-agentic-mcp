## CRITICAL

- Before adapting the report to the semantic model, make sure you understand the business requirements and identify the main measures and dimensions
- The report is using the PBIR file format, that is a public format for Power BI reports using JSON files. More information in the [docs](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-report?tabs=v2%2Cdesktop#pbir-format). Each page, visual, bookmark, etc., is organized into a separate, individual file within a folder structure. This format is ideal for codevelopment conflict resolution.

## Report file organization

These are the files you should care about and manipulate when adapting a template report to a semantic model. All the other files, leave them as-is.

    ```
    templateReport/
    ├── definition/ # stores the entire report definition: pages, visuals, bookmarks
    |   ├── /pages # Folder holding all pages of the report.
    |   |   ├── /mainPage
    |   |   |   ├── /visuals
    |   |   |   |   ├── /[visualName] # Folder for each visual, inside the mainPage there are many visuals
    |   |   |   |   |   ├── visual.json # The visual.json that should be edited to reference the semantic model fields
    ```


## Changes to apply to each visual

ONLY CHANGE the following visuals:

- **topCard**
  
  - add all the main semantic model measures to it to the max of 4 measures

  Example of the JSON to modify:

  ```json
  {
    ...
    "visual": {
      "query": {
        "queryState": {
          "Data": {
            "projections": [
              {
                "field": {
                  "Measure": {
                    "Expression": {
                      "SourceRef": {
                        "Entity": "[table name]"
                      }
                    },
                    "Property": "[measure name]"
                  }
                },
                "queryRef": "[table name].[measure name]",
                "nativeQueryRef": "[measure name]"
              }
              ...            
            ]
          }
        }
      }   
    }
    ...
  }
  ```

- **dateSlicer**

    - Add the date column from the Calendar table
    - Only one column

    Example of the JSON to modify:

    ```json
    { 
        ...
        "visual": {    
            "query": {
            "queryState": {
                "Values": {
                "projections": [
                    {
                    "field": {
                        "Column": {
                        "Expression": {
                            "SourceRef": {
                            "Entity": "[table name]"
                            }
                        },
                        "Property": "[column name]"
                        }
                    },
                    "queryRef": "[table name].[column name]",
                    "nativeQueryRef": "[column name]",
                    "active": true
                    }
                ]
                }
            }
            }
        }
        ...  
    }
    ```

- **barChart1**

    - Add a main category column from the model to the Category
    - Add the main measure to the Y axis    

    Example of the JSON to modify:

    ```json
    { 
        ...
        "visual": {    
            "query": {
                "queryState": {
                    "Category": {
                        "projections": [
                            {
                            "field": {
                                "Column": {
                                "Expression": {
                                    "SourceRef": {
                                    "Entity": "[table name]"
                                    }
                                },
                                "Property": "[column name]"
                                }
                            },
                            "queryRef": "[table name].[column name]",
                            "nativeQueryRef": "[column name]",
                            "active": true
                            }
                        ]
                    },
                    "Y": {
                        "projections": [
                            {
                            "field": {
                                "Measure": {
                                "Expression": {
                                    "SourceRef": {
                                    "Entity": "[table name]"
                                    }
                                },
                                "Property": "[measure name]"
                                }
                            },
                            "queryRef": "[table name].[measure name]",
                            "nativeQueryRef": "[measure name]"
                            }
                        ]
                    }
                }
            }
        }
        ...  
    }
    ```

- **timeSeries**

    - Add a date field from the Calendar table to the Category    
    - Add the main measure to the Y axis    

    Example of the JSON to include:

    ```json
    { 
        ...
        "visual": {            
            "query": {
                "queryState": {
                    "Category": {
                        "projections": [
                            {
                            "field": {
                                "Column": {
                                "Expression": {
                                    "SourceRef": {
                                    "Entity": "[table name]"
                                    }
                                },
                                "Property": "[column name]"
                                }
                            },
                            "queryRef": "[table name].[column name]",
                            "nativeQueryRef": "[column name]",
                            "active": true
                            }
                        ]
                    },
                    "Y": {
                        "projections": [
                            {
                            "field": {
                                "Measure": {
                                "Expression": {
                                    "SourceRef": {
                                    "Entity": "[table name]"
                                    }
                                },
                                "Property": "[measure name]"
                                }
                            },
                            "queryRef": "[table name].[measure name]",
                            "nativeQueryRef": "[measure name]"
                            }
                        ]
                    }
                }
            }            
        },
        ...  
    }
    ```