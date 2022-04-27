# UPLOAD JSON FILE USING THE POWERSHELL SCRIPT

## **Prerequisites**:  

donotdelete folder, upload folder and ps1 script in local system. 
    
**donotdelete folder:** contains the below two files. 

1. properties.json File
2. status.done
    
**properties.json:**  contains http, container and SAS token. 

    http : "https://{storageaccount}.blob.core.windows.net"
    container : "{container_name}/mapping/upload"
    SAStoken : "container sas token"

Refer this link to create container level SAS token. 
    [SAS Token creation](https://docs.microsoft.com/en-us/azure/cognitive-services/translator/document-translation/create-sas-tokens?tabs=Containers)

**staus.done** is an empty file, this file will be transferred along with the JSON files and used to create an storage even trigger in Azure Data Factory. 


**Upload folder:** Keep all Json files required to transfer to {container_name}/mapping/upload/ blob storage. 

**.ps1 file:** 
     Right click on this .ps1 file and choose "Run with PowerShell" to complete transfer JSON files from upload folder to azure blob storage. 




# Azure Data Factory

 **{datapipeline}** is created to trigger the azure databricks notebook **{azure databricks notebook name}** based on the storage event created using status.done

 The status.done file will be transfered to {container_name}/mapping/upload/ blob storage after the successful completion of powershell script execution.

# Azure Databricks Notebook

## Command1

To install the prequisites wheel files and pip install modules.
1. **nr_ii_azmart-0.0.1-py3-none-any.whl**  to load JSON validation .whl file (), this module checks the JSON file
2. **NRLogger-0.0.7-py3-none-any.whl** to load the NP logger module and push logs into Log Analytics
3. pip install pyodbc  -- To establish connection with Azure SQL Database.
4. pip install azure.storage.blob -- To list, copy and remove blobs in the mapping/upload, mapping/live and mapping/archive folders

```shell
%pip install /dbfs/mnt/route-pocs/NRLogger-WHL/NRLogger-0.0.7-py3-none-any.whl --force-reinstall
%pip install /dbfs/FileStore/real-time-ingestion/parser/whl/nr_ii_azmart-0.0.1-py3-none-any.whl
!pip install azure.storage.blob
!pip install pyodbc
```



## Command2

This command will import NR Logger from NRLogging module , this module is present in the "**NRLogger-0.0.7-py3-none-any.whl**" installed in **command1**


```Python
    """ Importing logging and setting display statements"""
#from NRLogging import NRLogger

import logging

#logger = NRLogger.getLogger(name=__name__, instrumentationKey='xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')

logger = logging.getLogger(__name__)

logger.setLevel(logging.DEBUG)

debug = 1

"""p = {'dlevel':NRLogger.D_LEVEL[1],
     'debug':debug,
     'notebook_path':dbutils.notebook.entry_point.getDbutils().notebook().getContext().notebookPath().get()}"""
```

## Command3
This command will fetch data from the blob storage and
lists the all the json files loaded {container}/mapping/upload and {container}/mapping/live folders. This upload files list is used validating the JSON files and load into **SQL DATABASE** after successful validation.



```markdown
import os
import re
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient, __version__
connect_str ={"connection string"}
container_name = "{container_name}"
try:
    blob_service_client = BlobServiceClient.from_connection_string(connect_str)
   
    container_client = blob_service_client.get_container_client(container_name)
       
    upload_blob_list = container_client.list_blobs()
    upload_list_files = []
    live_list_files = []
    for blob in upload_blob_list:                    
      if blob.name.startswith("mapping/upload") and blob.name.endswith(".json"):
        upload_list_files.append(blob.name)
      elif blob.name.startswith("mapping/live") and blob.name.endswith(".json"):
        live_list_files.append(blob.name)
    logger.debug(upload_list_files)
    logger.debug(live_list_files)
       
except Exception as ex:
    logger.error(ex)
```

## Command4

This command will mount the {container} in databricks file system with **"mnt/datamartingestion"** name. 

First it will try to **mount** with **"mnt/datamartingestion"** name, system will throw error if it is already existed and the same is handled in the exception to **Unmount** first and again mounts with **"mnt/datamartingestion"** name.


```markdown
storage_account ="{storage account}"
mount = "datamartingestion"

conf = "fs.azure.account.key." + storage_account + ".blob.core.windows.net"

key = "{account key}"

try:
  dbutils.fs.mount(
  source = "wasbs://"+container_name + "@"+storage_account+".blob.core.windows.net",
  mount_point = "/mnt/" + mount,
  extra_configs = {conf:key})
  logger.info("/mnt/datamartingestion/ is mouted")
except Exception as e:
  dbutils.fs.unmount("/mnt/datamartingestion/")
  logger.info("/mnt/datamartingestion/ has been unmounted")
  dbutils.fs.mount(
    source = "wasbs://"+container_name + "@"+storage_account+".blob.core.windows.net",
    mount_point = "/mnt/" + mount,
    extra_configs = {conf:key})
  logger.info("/mnt/datamartingestion/ is mouted")
```

## Command5

The following shell  command will install the necessary sql driver required for the odbc connection. 

```markdown
%sh
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get -q -y install msodbcsql17
sudo apt-get update
```

## Command6
This command defines function **updateCOntrolDBs**, this function takes one argument i.e. file name from the **upload file list**, the list is created in **command2**

Database used is **ControlDB**

SQL Server: **sqluksnprdiidevshd6001.database.windows.net**

The function does the following steps:

1. checks the target table is present in **CRT_NRT.AZ_DM_TABLE** table
2. If target table is not present, then follwing sql updates will be performed and issue commit. 

    a. Inserts into **CRT_NRT.AZ_DM_TABLE** with **max(tableid)+1, target table name and current timestamp**
    b. Inserts into **CRT_NRT.AZ_FND_MAPPING** with **id, new table id , mapping file name, version, status as "Y" , current timestamp**

3. If target table is present then the follwing sql operations will be performed and issued commit. 

    a. Updates all rows with Active status 'N' data with "Y" for the processing target table name using the table_id from **CRT_NRT.AZ_DM_TABLE** table. 

    b. Insert into **CRT_NRT.AZ_FND_MAPPING** with **max(id)+1, existing table id , mapping file name, version, status as "Y" , current timestamp**

If the above operations are successful then it will return **True** to calling function else returns **False**


```markdown
def updateCOntrolDBs(file):
  path = "/dbfs/mnt/datamartingestion/mapping/upload/" + file
  with open(path, 'r') as file_data:
    json_file_data = json.load(file_data)
    file_name = json_file_data['name'] + "_v" + json_file_data["version"]
    file_verion = json_file_data["version"]
    table_name = json_file_data['target']['table']
    server = 'tcp:{sql service id}'
    database = 'ControlDB'
    username = '{username}'
    password = '{password}'
   
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
   
    """ This below condition will check if the table name is already exists or not"""
   
    cursor = cnxn.cursor()
    query = "select count(*) from CRT_NRT.AZ_DM_TABLE where name = \'{}\'".format(table_name)
    data = cursor.execute(query)
    row = cursor.fetchone()
 
    if row[0] == 0:
      """Insert New data into table"""
      query = "select max(id)+1 from CRT_NRT.AZ_DM_TABLE"
      data = cursor.execute(query)
      new_table_id = cursor.fetchone()[0]
      query = "insert into CRT_NRT.AZ_DM_TABLE values ({},\'{}\','',current_timestamp) ".format(new_table_id,table_name)
      cursor.execute(query)
      cursor.commit()
      query = "select max(id)+1 from CRT_NRT.AZ_FND_MAPPING"
      data = cursor.execute(query)
      old_max_id = cursor.fetchone()[0]
      query = "insert into CRT_NRT.AZ_FND_MAPPING (id,table_id,mapping_name,version,active,effective_start_dt, effective_end_dt) values({},\'{}\',\'{}\',\'{}','Y',current_timestamp,current_timestamp)".format(old_max_id,new_table_id,file_name,file_verion)
      cursor.execute(query)
      cursor.commit()
      cursor.close()
      cnxn.close()
      return True
    else:      
      query = "select count(*) from CRT_NRT.AZ_FND_MAPPING where mapping_name = \'{}\'".format(file_name)
      data = cursor.execute(query)
      version_count = cursor.fetchone()[0]
      if version_count == 0:            
        #query = "update CRT_NRT.AZ_FND_MAPPING set active = 'N' where mapping_name like \'{}%\' ".format(table_name)
        query = "update CRT_NRT.AZ_FND_MAPPING set active = 'N' where table_id in (select distinct id from CRT_NRT.AZ_DM_TABLE where name = \'{}\')".format(table_name)
        cursor.execute(query)
        cursor.commit()
        query = "select id from CRT_NRT.AZ_DM_TABLE where name = \'{}\'".format(table_name)
        data = cursor.execute(query)
        old_table_id = cursor.fetchone()[0]
        query = "select max(id)+1 from CRT_NRT.AZ_FND_MAPPING"
        data = cursor.execute(query)
        old_max_id = cursor.fetchone()[0]
        query = "insert into CRT_NRT.AZ_FND_MAPPING (id,table_id,mapping_name,version,active,effective_start_dt, effective_end_dt) values({},\'{}\',\'{}\',\'{}','Y',current_timestamp,current_timestamp)".format(old_max_id,old_table_id,file_name,file_verion)
        cursor.execute(query)
        cursor.commit()
        cursor.close()
        cnxn.close()
        return True
      else:
        return False
```

## Command7

The follwing command defines **parse_mapping_documents** function which takes **filename** as argument and validates the JSON file uploaded in the {container_name}/mapping/upload.

**nr_ii_azmart module** will be imported from the **nr_ii_azmart-0.0.1-py3-none-any.whl** wheel file installed in **Command1**. 

Input Arguments:  **"Filename"**

return data: **Returns True if validation is successful, returns False otherwise**



```markdown
from nr_ii_azmart import parser
import glob
import logging
import pyodbc
import json

def parse_mapping_documents(file):
    """
        parse_mapping_documents - read in and parse all mapping documents currently based on documents
            from on the file system.
           
        Returns a dictionary with an entry for each data mart table.  Each entry is itself a dictionary with SQL content as below:
       
        '[schema].[table]': {
            'create_staging_table': '<sql CREATE TABLE statement to create the staging table>',
            'create_target_table': '<sql CREATE TABLE statement to create the DIM/FACT table>',
            'source_select_driving_table': {
                  'ELLIPSE': {
                      'alias': '<if provided, alias assigned to the driving table, otherwise same as driving tbale>',
                      'schema': '<schema of the driving table - e.g. AZ_FH_ELLIPSE>'
                      'table': '<driving table e.g. AZ_FND_MSF620>'
                  }
            },
            'source_selects': {
                  'ELLIPSE': '<sql-statement to select from Ellipse source'                
            },
            'staging_table': '[<schema>].[<table_name>]',
            'target_merges': {
                  'ELLIPSE': '<sql-statement to UPSERT into target'
            },
        }          
       
    """
    generated_sql = {}
   
    # enumerate all the mapping documents
   
    doc = "/dbfs/mnt/datamartingestion/mapping/upload/" + file
    #mapping_doc = '/dbfs/FileStore/real-time-ingestion/parser/json/dm_DIM_REFERENCE_CODE_v3.0.json'  
    mapping_doc = doc
    logger.info(f'Parsing {mapping_doc}')
    # call the parser
    parse_results = parser.parse_mapping_document(mapping_doc, {})
    # if the document could not be passed, the returned dictionary contains an 'errors' key with a
    # list of errors
    if 'errors' in parse_results:
      logger.error('    Errors in parsing:')
      for error in parse_results['errors']:
        logger.error('        ' + error)
        return False
    else:
      # otherwise parsing was successful
      if parse_results['target_table'] in generated_sql:
        return False
        raise Exception(f"Duplicate table {parse_results['target_table']} in {mapping_doc}")
        #return False
      generated_sql[parse_results['target_table']] = parse_results
      logger.info('Parsed successfully')
```

## Command8
The follwing command will take the list of files uploaded in **mapping/upload** folder and process one file at a time and calls the **parse_mapping_documents** file using the file name and does the following

1. If return value is **True**, it will call **updateCOntrolDBs** using filename and performs the below operations. 

    a. If return value from updateCOntrolDBs is True then appends the filename to the **success_files list**
    b. If return value from updateCOntrolDBs is False then appends the filename to the **failed_files list**

2. If the return value is False, appends the filename to the **failed_files list** with logger information "fiel is failed with JSON Validation.


```markdown
if len(upload_list_files) == 0:
  logger.info("no json files present in the upload folder")
success_files = []
failed_files = []
for filepath in upload_list_files:
  file = os.path.split(filepath)[-1]
  if parse_mapping_documents(file):
    if updateCOntrolDBs(file):
      msg = f" {file} is successfully validated and loaded in the Mapping tables"
      success_files.append(filepath)
    else:
      msg = f" {file} is failed and file version is already existed"
      failed_files.append(filepath)
  else:
    msg = f" {file} is failed with JSON Validation "
    failed_files.append(filepath)
  logger.info(msg)
```

## Command9

The follwing command will perform the following operations

1. Move files from the **success_files** list and moves from **upload folder to live folder** 
2. Move the older version files from **live folder to archive folder** 
3. Removes

```markdown
""" Moving files from live folder to archeive folder"""
blob_service_client = BlobServiceClient.from_connection_string(connect_str)
for file in success_files:
  try:
    upload_file = re.sub("_[vV][\d]*.[\d]*","",file.strip('.json'))
    for file2 in live_list_files:
        live_file = re.sub("_[vV][\d]*.[\d]*","",file2.strip('.json'))
        if os.path.split(upload_file)[-1].upper() == os.path.split(live_file)[-1].upper():
            source_blob = (f"https://{storage_account}.blob.core.windows.net/{container_name}/{file}")
            target_file = file2.replace("live","archive")
           
            copied_blob = blob_service_client.get_blob_client(container_name, target_file)
            copied_blob.start_copy_from_url(source_blob)
            logger.info(f"{file} copied from upload to {target_file}")
           
            remove_blob = blob_service_client.get_blob_client(container_name, f"{file2}")
            remove_blob.delete_blob()
  except Exception as e:
    logger.error(e)
logger.info("Moving files from upload folder to Live Folder")
for i in success_files:
  try:
    blob_client = blob_service_client.get_blob_client(container_name,blob=i)
    source_blob = (f"https://{storage_account}.blob.core.windows.net/{container_name}/{i}")
    target_file = i.replace("upload","live")
    copied_blob = blob_service_client.get_blob_client(container_name, target_file)
    copied_blob.start_copy_from_url(source_blob)
    logger.info(f"{i} copied from upload to {target_file}")
    remove_blob = blob_service_client.get_blob_client(container_name, f"{i}")
    remove_blob.delete_blob()
    logger.info(f"{i} is removed")
  except Exception as e:
    logger.error(e)
       
logger.info("Remove failed files from Upload Folder")

for file in failed_files:
  try:
    remove_blob = blob_service_client.get_blob_client(container_name, file)
    remove_blob.delete_blob()
    logger.info(f"{file} is removed")
  except Exception as e:
    logger.error(e)
```

# Command10

The following command will **Unmount** the **/mnt/datamartingestion/**, the mount storage is not required for th next storage trigger. 

```Bash
dbutils.fs.unmount("/mnt/datamartingestion/")
```
