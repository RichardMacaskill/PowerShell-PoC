
  Id CommandLine                                                                                                                                              
  -- -----------                                                                                                                                              
   1 $srv = New-Object microsoft.management.sqlserver.smo .                                                                                                   
   2 cls                                                                                                                                                      
   3 Get-Module sqlserver                                                                                                                                     
   4 import-module sqlserver                                                                                                                                  
   5 get-module sqlserver                                                                                                                                     
   6 $srv = new-object Microsoft.sqlserver.management.smo.server .                                                                                            
   7 $srv.Databases.name                                                                                                                                      
   8 $srv = new-object Microsoft.sqlserver.management.smo.server .dev                                                                                         
   9 $srv = new-object Microsoft.sqlserver.management.smo.server .\dev                                                                                        
  10 $srv.version                                                                                                                                             
  11 $srv.Databases.name                                                                                                                                      
  12 $srv.Databases['_SO_Clone1']                                                                                                                           
  13 $db = $srv.Databases['my new clone']                                                                                                                     
  14 $db | select *                                                                                                                                           
  15 $db | select *                                                                                                                                           
  16 $DB.PrimaryFilePath                                                                                                                                      
  17 $DB.FileGroups                                                                                                                                           
  18 $DB.FileGroups[0] | gm                                                                                                                                   
  19 $DB.FileGroups[0].Files                                                                                                                                  
  20 $DB.FileGroups[0].Files[0]                                                                                                                               
  21 $DB.FileGroups[0].Files[0].AvailableSpace                                                                                                                
  22 $DB.FileGroups[0].Files[0].FileName                                                                                                                      
  23 $DB.LastBackupDate                                                                                                                                       
  24 $DB.LastDifferentialBackupDate                                                                                                                           
  25 $DB.LastLogBackupDate                                                                                                                                    


