#INCLUDE "../iguanacms.bi"

'##############################
'Module Definitions
'##############################

TYPE IguanaModule
  Name AS STRING
  ListedForUser AS LONG = -1
  ListedForAdmin AS LONG = -1
  HasOwnTemplate AS LONG
  MainLoader AS INTEGER
  AdminLoader AS INTEGER
  VarsFunction AS INTEGER
END TYPE

'##############################
'Module Functions
'##############################

DECLARE SUB RegisterModule(NewModule AS IguanaModule)
DECLARE SUB LoadAdminModule(ModuleName AS STRING)
DECLARE SUB ListCompiledModules(ArrayModules() AS IguanaModule)
DECLARE SUB RegisterLoader(LoaderPointer AS INTEGER)

'##############################
'Modules Includes
'##############################
