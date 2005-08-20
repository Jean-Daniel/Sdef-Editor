#!/bin/sh
SDEF_EDITOR_EXEC="Sdef Editor.app/Contents/MacOS/Sdef Editor"

lipo "build/Deployment/${SDEF_EDITOR_EXEC}" "build/Deployment Intel/${SDEF_EDITOR_EXEC}" -create -output "build/Deployment/${SDEF_EDITOR_EXEC}"

file "build/Deployment/${SDEF_EDITOR_EXEC}"
