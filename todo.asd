(in-package :asdf)

(defsystem "todo"
  :author "Dan Miller"
  :license ""
  :depends-on ("reblocks" "reblocks-ui/form" "reblocks/html")
  :components ((:file "todo"))
  :description "Reblocks test TODO app")
