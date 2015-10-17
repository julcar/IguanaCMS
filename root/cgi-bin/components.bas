'##############################################################################
'This file contains an array which enumerates all of the components to be compiled
'If you are planning to add or remove a module, please be careful to edit
'properly this file, with the aim of avoid eventual errors and security issues.
'##############################################################################

COMMON SHARED compiledComponents$()

'The number of elements inside the array must obey to the real amount of
'compiled components present on /components folder.

REDIM compiledComponents$(0)

'This is the list of compiled Components
compiledComponents$(0) = "users"

'Now we have to include the needed files
'$INCLUDE: "components/users.bas"

FUNCTION loadComponent$(component$)
  SELECT CASE component$
    CASE "users"
      loadComponent$ = loadUsers$()
    CASE ELSE
      loadComponent$ = ""
  END SELECT
END FUNCTION
