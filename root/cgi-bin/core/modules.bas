'##############################################################################
'This file contains an array which enumerates all of the module to be compiled
'If you are planning to add or remove a module, please be careful to edit
'properly this file, with the aim of avoid eventual errors and security issues.
'##############################################################################

COMMON SHARED compiledModules$()

'The number of elements inside the array must obey to the real amount of
'compiled modules present on /modules folder.
REDIM compiledModules$(0)

'This is the list of compiled modules
compiledModules$(0) = "admin"
