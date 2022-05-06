# Foundation DB Migration

**Prerequisities:**
1. All SQL Migration Scripts should be present in **/data-mart-ingestion/mapping/sql-scripts/** folder.
2. **validation_counts.sql** is mandatory file in the above blob storage. And this sql file will be given in the last batch.
3. **run_sql_files.json** configuration file needed to run the piepline in sequential or in parllel process.

# Understanding the Configuration File

The configuration file will process the batchNo in the sequential manner and the files present for batch will be processed in parllel manner.
There is no restriction on the keying the number of batches and also no restriction on adding the number of  .sql files for each batch.
The last batch should have validation sql.


## Sample Configuration File

```markdown
run_sql_files.json

{
"Application": "Run SQL Migration queries in batches",
"version": 1.0,
"data": [{
"batchNO": 1,
"files": [{
"name": "custom_mig_MSF071.sql"
}]
},
{
"batchNO": 2,
"files": [{
"name": "custom_mig_MSF620.sql"
}]
},
{
"batchNO": 3,
"files": [{
"name": "custom_mig_MSF623.sql"
},
{
"name": "mig_MSF010.sql"
},
{
"name": "mig_MSF096_STD_VOLAT.sql"
}
]
},
{
"batchNO": 4,
"files": [{
"name": "mig_MSF621.sql"
},
{
"name": "mig_MSF010.sql"
},
{
"name": "mig_MSF720.sql"
}
]
},
{
"batchNO": 5,
"files": [{
"name": "validation_counts.sql"
}]
}
]
}

```

# **Azure Data Factory Pipeline**

Two pipelines are configured to run the .sql files in batches.

1. PL_MIGRATION_FOUNDATION_TABLES
2. PL_MIGRATION_FOUNDATION_TABLES_PARALLEL_RUN

### **PL_MIGRATION_FOUNDATION_TABLES:**  
This is main pipeline used to trigger the process, the following activities are configured sequentially. 

#### **Activities:**
1. **VAL_VALIDATION_COUNTS_SQL :**  Pipeline process starts with **Validation** activity, this activity checks the **validation_counts.sql** exists in the above blob storage.  If file exists then this activity completes then start with activity-2. 
And if the file doesn't exists then it activity goes to timeout status after 3 minutes and the complete pipeline will be bypassed.

2. **WEB_GET_RUN_SQL_CONFIG_FILE :**  Web activity to get the config file **run_sql_files.json** and passes this file content to the Activity-3

3. **FEH_READ_BATCH_CONFIG_JSON :** For Each Activity to process the batches (refer the Configuration file to understand the batches) in the sequential manner. 
For each batch, activity executes EXP_FOUNDATION_DATA_BATCH_EXEC activity to call the pipeline PL_MIGRATION_FOUNDATION_TABLES_PARALLEL_RUN by passing the files data present for the processing batch. 


### **PL_MIGRATION_FOUNDATION_TABLES_PARALLEL_RUN**

This is inner pipeline executes from **FEH_READ_BATCH_CONFIG_JSON** activity from above pipeline. This pipeline has one activity i.e. **FEH_MIG_SQL_FILE_PROCESS**. this activity gets file names configured for each batch and executes the activities inside this For Each activity. Below are the following activities inside FEH_MIG_SQL_FILE_PROCESS. 

1. **VAL_SQL_MIG_SCRIPT :** Validation Activity to check the sql file present in the above blob storage. If file exists then this activity completes then next activity will start processing.

    And if the file doesn't exists then this activity goes to timeout status after 1 minute and the next activities for this run will be bypassed.

2. **WEB_GET_SQL_MIGRATION_FILE :** Web activity to get the sql file and passes this file content to the below activity

3. **LKP_RUN_SQL_MIGRATION_SCRIPT** Lookup Acitivity to run the sql files. This activity settings are configured to update only the **Foundation DB** 


The following Datasets and the Linked services are configured. 


| Activity Type | Activity Name | Data Set | Linked Service |
| --- | :-- | :--  | :--  |
| Validaton | VAL_VALIDATION_COUNTS_SQL | DS_ABLB_SQL_FILES_READ | LS_ABLB_SQL_FILES_READ |
| Validation | VAL_SQL_MIG_SCRIPT |  DS_ABLB_SQL_FILES_READ | LS_ABLB_SQL_FILES_READ |
|Lookup | LKP_RUN_SQL_MIGRATION_SCRIPT | DS_ASQL_FOUNDATION_TABLE | LS_ASQL_FOUNDATION_TABLE |
